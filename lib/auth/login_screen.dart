// Màn hình Đăng nhập trong ứng dụng Flutter sử dụng StatefulWidget để xử lý giao diện động.

// Nhập thư viện Flutter và dữ liệu người dùng (UserData) để kiểm tra đăng nhập
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/providers/user_provider.dart';
import '../data/providers/settings_provider.dart';
import '../data/services/auth_service.dart'; // <<< IMPORT AuthService
import 'forgot_password_screen.dart'; // Import màn hình Quên mật khẩu
import '../theme.dart';

/**
 * Màn hình Đăng nhập.
 * Cho phép người dùng nhập username/password và gọi UserProvider để đăng nhập.
 */
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controllers để lấy dữ liệu từ các trường nhập liệu
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Key để quản lý trạng thái của Form
  bool _isPasswordVisible = false; // Ẩn/hiện mật khẩu
  bool _isLoading = false; // Trạng thái loading

  /**
   * Hàm xử lý sự kiện nhấn nút Đăng nhập.
   * Validate form, gọi UserProvider.login và điều hướng đến home nếu thành công.
   */
  void _login() async {
    // Ẩn bàn phím
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Bật trạng thái loading
      });

      try {
        // Gọi UserProvider để xử lý đăng nhập
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final success = await userProvider.login(
          username: _usernameController.text,
          password: _passwordController.text,
        );

        if (success && mounted) {
          // Đăng nhập thành công, lấy token từ AuthService và cập nhật SettingsProvider
          final authService = AuthService(); // <<< CREATE AuthService INSTANCE
          final token = await authService.getToken(); // <<< GET TOKEN FROM AuthService
          if (token != null) {
            Provider.of<SettingsProvider>(context, listen: false).updateToken(token);
          } else {
             print('Warning: Login successful but could not retrieve token from AuthService.');
          }

          // Kiểm tra vai trò để điều hướng
          final roles = userProvider.currentUser?.roles ?? [];
          
          // DEBUG: In ra danh sách vai trò
          print('User roles after login: $roles'); 

          if (roles.contains('ADMIN')) {
            print('Navigating to /admin_dashboard'); // DEBUG
            Navigator.pushReplacementNamed(context, '/admin_dashboard'); // Điều hướng đến trang admin
          } else {
            print('Navigating to /home'); // DEBUG
            Navigator.pushReplacementNamed(context, '/home'); // Điều hướng đến trang home thông thường
          }
          
        } else if (mounted) {
          // Hiển thị lỗi từ UserProvider
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(userProvider.error ?? 'Đăng nhập thất bại.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        // Xử lý lỗi không mong đợi
         if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã xảy ra lỗi: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
         }
      }

      // Tắt loading
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Giải phóng bộ nhớ khi màn hình bị huỷ
  @override
  void dispose() {
    // Giải phóng controllers
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Giao diện chính của màn hình đăng nhập
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    
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
                // Logo ở đầu màn hình đăng nhập
                Image.asset('assets/images/image1.png', height: 100),
                const SizedBox(height: 10),
                const Text(
                  'Đăng nhập',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 20),

                // Trường nhập email hoặc ID
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Tên đăng nhập',
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
                      return 'Vui lòng nhập tên đăng nhập';
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
                        'Đăng ký tại đây',
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
