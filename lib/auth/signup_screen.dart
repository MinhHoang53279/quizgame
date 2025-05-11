import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/providers/user_provider.dart';
import '../theme.dart';

/**
 * Màn hình Đăng ký tài khoản.
 * Cho phép người dùng nhập thông tin và gọi UserProvider để tạo tài khoản.
 */
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
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Key để kiểm tra form hợp lệ
  bool _isLoading = false; // Trạng thái đang xử lý đăng ký

  /**
   * Hàm xử lý sự kiện nhấn nút Đăng ký.
   * Validate form, gọi UserProvider.createUser và xử lý kết quả.
   */
  void _register() async {
    // Ẩn bàn phím
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      // Mật khẩu xác thực đã được kiểm tra bởi validator
      setState(() {
        _isLoading = true; // Bật trạng thái loading
      });

      try {
        // Gọi UserProvider để đăng ký thông qua backend
        final success = await Provider.of<UserProvider>(context, listen: false)
            .createUser(
          username: _usernameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          fullName: _fullNameController.text,
        );

        if (success && mounted) { // Kiểm tra mounted trước khi thao tác context
          // Thông báo thành công và chuyển về trang đăng nhập
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đăng ký thành công! Vui lòng đăng nhập.'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else if (mounted) {
          // Hiển thị lỗi từ UserProvider
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(Provider.of<UserProvider>(context, listen: false).error ?? 'Đăng ký thất bại.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Xử lý lỗi không mong đợi từ Provider
         if (mounted) {
             ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã xảy ra lỗi: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
             );
         }
      }

      // Đảm bảo tắt loading ngay cả khi có lỗi hoặc widget bị unmount
      if (mounted) {
         setState(() {
           _isLoading = false;
         });
      }
    }
  }

  @override
  void dispose() {
    // Giải phóng các controller khi widget bị hủy
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  /**
   * Xây dựng giao diện người dùng cho màn hình Đăng ký.
   */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 300,
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo ở đầu màn hình đăng ký
                Image.asset('assets/images/image1.png', height: 100),
                const SizedBox(height: 10),
                const Text(
                  'Đăng ký',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
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
                // Input Full Name
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Họ và tên',
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
                      return 'Vui lòng nhập họ và tên';
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

/**
 * Widget tùy chỉnh cho trường nhập mật khẩu với chức năng ẩn/hiện.
 */
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
  bool _isVisible = false; // Trạng thái ẩn/hiện mật khẩu

  /**
   * Xây dựng giao diện cho trường mật khẩu.
   */
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
