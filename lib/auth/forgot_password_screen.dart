// Nhập thư viện Flutter cơ bản
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add provider
import '../data/providers/user_provider.dart'; // Import UserProvider
import '../theme.dart';

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
  void _submitRequest() async {
    // Hide keyboard
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Bật loading khi bắt đầu xử lý
      });

      try {
         // Call UserProvider to handle forgot password request
        final message = await Provider.of<UserProvider>(context, listen: false)
            .forgotPassword(email: _emailController.text);

        // Display the message from the backend (e.g., check console message)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green, // Indicate success/info
          ),
        );

        // Optionally navigate back or stay on the screen
        // if (mounted) Navigator.pop(context);

      } catch (e) {
        // Display error message from provider
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }

       // Ensure loading is turned off
       if (mounted) {
          setState(() {
            _isLoading = false;
          });
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
      backgroundColor: AppTheme.primaryColor, // Màu nền
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 300,
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(10), // Bo góc khung form
          ),
          child: Form(
            key: _formKey, // Gắn form key để xác thực nhập liệu
            child: Column(
              mainAxisSize: MainAxisSize.min, // Tự co giãn theo nội dung
              children: [
                // Logo ở đầu màn hình quên mật khẩu
                Image.asset('assets/images/image1.png', height: 100),
                const SizedBox(height: 10),
                const Text(
                  'Quên mật khẩu',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
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
                      onPressed: _submitRequest, // Call the updated function
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
