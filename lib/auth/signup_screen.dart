import 'package:flutter/material.dart';
import '../data/user_data.dart';

// Màn hình đăng ký tài khoản mới
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Các controller để lấy dữ liệu từ người dùng nhập
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Key để kiểm tra form hợp lệ
  bool _isLoading = false; // Trạng thái đang xử lý đăng ký

  // Hàm xử lý đăng ký người dùng
  void _register() async {
    if (_formKey.currentState!.validate()) {
      // Kiểm tra mật khẩu nhập lại có trùng khớp không
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mật khẩu xác thực không khớp!')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Thêm người dùng mới vào dữ liệu tạm (UserData)
      UserData.addUser(
        _usernameController.text,
        _emailController.text,
        _passwordController.text,
      );

      await Future.delayed(const Duration(seconds: 1)); // Giả lập chờ xử lý

      setState(() {
        _isLoading = false;
      });

      // Thông báo đăng ký thành công và chuyển về trang đăng nhập
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
        ),
      );

      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  void dispose() {
    // Giải phóng tài nguyên khi widget bị hủy
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple[400],
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 300,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Đăng ký',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                // Nhập tên người dùng
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Tên người dùng',
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
                      return 'Vui lòng nhập tên người dùng';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                // Nhập email
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
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
                // Nhập mật khẩu
                PasswordField(controller: _passwordController),
                const SizedBox(height: 15),
                // Nhập lại mật khẩu
                PasswordField(
                  controller: _confirmPasswordController,
                  labelText: 'Xác thực mật khẩu',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập lại mật khẩu';
                    }
                    if (value != _passwordController.text) {
                      return 'Mật khẩu xác thực không khớp';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Nút đăng ký hoặc hiển thị đang tải
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.purple)
                    : ElevatedButton(
                      onPressed: _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[400],
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text(
                        'Đăng ký',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                const SizedBox(height: 10),
                // Chuyển sang trang đăng nhập
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Đã có tài khoản? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: Text(
                        'Đăng nhập tại đây',
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

// Widget tùy biến để nhập mật khẩu (ẩn/hiện mật khẩu)
class PasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String?)? validator;

  const PasswordField({
    super.key,
    required this.controller,
    this.labelText = 'Mật khẩu',
    this.validator,
  });

  @override
  _PasswordFieldState createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: !_isVisible,
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[200],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: BorderSide.none,
        ),
        suffixIcon: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: IconButton(
            onPressed: () {
              setState(() {
                _isVisible = !_isVisible;
              });
            },
            icon: Icon(
              _isVisible ? Icons.visibility : Icons.visibility_off,
              color: _isVisible ? Colors.grey : Colors.grey,
              size: 24,
            ),
          ),
        ),
      ),
      validator:
          widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập mật khẩu';
            }
            if (value.length < 6) {
              return 'Mật khẩu phải có ít nhất 6 ký tự';
            }
            return null;
          },
    );
  }
}
