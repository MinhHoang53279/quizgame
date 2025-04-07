// Màn hình Đăng nhập trong ứng dụng Flutter sử dụng StatefulWidget để xử lý giao diện động.

// Nhập thư viện Flutter và dữ liệu người dùng (UserData) để kiểm tra đăng nhập
import 'package:flutter/material.dart';
import '../data/user_data.dart';
import 'forgot_password_screen.dart'; // Import màn hình Quên mật khẩu

// Widget chính cho màn hình đăng nhập
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers để lấy dữ liệu từ các trường nhập liệu
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Key để quản lý trạng thái của Form
  bool _isLoading = false; // Biến để hiển thị loading indicator khi đăng nhập
  bool _isPasswordVisible = false; // Ẩn/hiện mật khẩu

  // Hàm xử lý đăng nhập
  void _login() async {
    // Kiểm tra hợp lệ các trường nhập liệu
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Bắt đầu loading
      });

      String email = _emailController.text;
      String password = _passwordController.text;

      // Kiểm tra tài khoản có hợp lệ không từ dữ liệu lưu trữ
      bool isValid = UserData.validateUser(email, password);

      // Giả lập độ trễ (ví dụ đang xử lý mạng)
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isLoading = false; // Tắt loading
      });

      if (isValid) {
        // Nếu hợp lệ, chuyển hướng sang màn hình chính
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // Nếu sai, hiện thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email hoặc mật khẩu không đúng')),
        );
      }
    }
  }

  // Giải phóng bộ nhớ khi màn hình bị huỷ
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Giao diện chính của màn hình đăng nhập
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
            borderRadius: BorderRadius.circular(10), // Bo góc khung nhập
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo ở đầu màn hình đăng nhập
                Image.asset('assets/images/image1.png', height: 100),
                const SizedBox(height: 10),
                const Text(
                  'Đăng nhập',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Trường nhập email hoặc ID
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'ID học viên hoặc Email',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[200],
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
                const SizedBox(height: 15),

                // Trường nhập mật khẩu (có chức năng ẩn/hiện)
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    labelStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Nút đăng nhập hoặc loading nếu đang xử lý
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.purple)
                    : ElevatedButton(
                      onPressed: _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[400],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        'Đăng nhập',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                const SizedBox(height: 10),

                // Nút quên mật khẩu
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ForgotPasswordScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Quên mật khẩu?',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),

                // Liên kết sang màn hình đăng ký
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Không có tài khoản? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: Text(
                        'Đăng ký ngay',
                        style: TextStyle(color: Colors.purple[400]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
