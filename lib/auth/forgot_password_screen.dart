// Nhập thư viện Flutter cơ bản
import 'package:flutter/material.dart';

// Import dữ liệu người dùng để kiểm tra email tồn tại
import '../data/user_data.dart' show UserData;

// Màn hình "Quên mật khẩu" sử dụng StatefulWidget vì có sự thay đổi trạng thái (loading, xử lý)
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Controller để lấy dữ liệu từ trường nhập email
  final TextEditingController _emailController = TextEditingController();
  final _formKey =
      GlobalKey<FormState>(); // Key quản lý Form để kiểm tra hợp lệ
  bool _isLoading = false; // Biến xử lý hiển thị loading khi gửi yêu cầu

  // Hàm xử lý gửi yêu cầu đặt lại mật khẩu
  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Bật loading khi bắt đầu xử lý
      });

      String email = _emailController.text;

      // Biến kiểm tra email có trong danh sách người dùng không
      bool emailExists = false;
      for (var user in UserData.users) {
        if (user['email'] == email) {
          emailExists = true;
          break; // Dừng kiểm tra khi tìm thấy email
        }
      }

      // Giả lập độ trễ xử lý (1 giây) – thực tế có thể là API
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isLoading = false; // Tắt loading sau khi xử lý xong
      });

      if (emailExists) {
        // Nếu email hợp lệ, thông báo đã gửi liên kết đặt lại mật khẩu
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Đã gửi liên kết đặt lại mật khẩu đến email của bạn!',
            ),
          ),
        );
        // Quay lại màn hình đăng nhập
        Navigator.pop(context);
      } else {
        // Nếu email không tồn tại, thông báo lỗi
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Email không tồn tại!')));
      }
    }
  }

  // Huỷ controller khi màn hình bị đóng để tránh rò rỉ bộ nhớ
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Giao diện chính của màn hình quên mật khẩu
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[400], // Màu nền
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10), // Bo góc khung form
          ),
          child: Form(
            key: _formKey, // Gắn form key để xác thực nhập liệu
            child: Column(
              mainAxisSize: MainAxisSize.min, // Tự co giãn theo nội dung
              children: [
                // Tiêu đề màn hình
                const Text(
                  'Quên mật khẩu',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Trường nhập email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[200],
                    // Nền nhập liệu
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập email';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Vui lòng nhập email hợp lệ';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Nút gửi yêu cầu hoặc loading
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.purple)
                    : ElevatedButton(
                      onPressed: _resetPassword, // Gọi hàm gửi yêu cầu
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[400],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        'Gửi yêu cầu',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                const SizedBox(height: 10),

                // Nút quay lại đăng nhập
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Quay về màn hình trước đó
                  },
                  child: Text(
                    'Quay lại đăng nhập',
                    style: TextStyle(color: Colors.purple[400]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
