import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/providers/user_provider.dart';
import 'signup_screen.dart'; // Import PasswordField from signup_screen
import '../theme.dart';

/**
 * Màn hình Đặt lại mật khẩu.
 * Yêu cầu người dùng nhập token (lấy từ console backend)
 * và mật khẩu mới để đặt lại.
 */
class ResetPasswordScreen extends StatefulWidget {
  // Optionally accept token via constructor if navigating with arguments
  // final String? initialToken;
  // const ResetPasswordScreen({super.key, this.initialToken});

  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Nếu token được truyền qua arguments, điền sẵn vào ô nhập
    // final args = ModalRoute.of(context)?.settings.arguments as Map?;
    // if (args != null && args['token'] != null) {
    //   _tokenController.text = args['token'];
    // }
  }

  /**
   * Hàm xử lý sự kiện nhấn nút "Đặt lại mật khẩu".
   * Validate form, gọi UserProvider.resetPassword và xử lý kết quả.
   */
  void _submitReset() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final message = await Provider.of<UserProvider>(context, listen: false)
            .resetPassword(
          token: _tokenController.text,
          newPassword: _newPasswordController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message), // Display success message from backend
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to login screen after successful reset
        if (mounted) {
            Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        }

      } catch (e) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst("Exception: ", "")),
            backgroundColor: Colors.red,
          ),
        );
      }

      if (mounted) {
         setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    // Giải phóng controllers
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /**
   * Xây dựng giao diện người dùng cho màn hình Đặt lại mật khẩu.
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
                // Logo ở đầu màn hình đặt lại mật khẩu
                Image.asset('assets/images/image1.png', height: 100),
                const SizedBox(height: 10),
                const Text(
                  'Đặt lại mật khẩu',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                ),
                const SizedBox(height: 15),
                const Text(
                  'Vui lòng kiểm tra console backend để lấy mã token và nhập vào đây.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 15),
                // Input Token
                TextFormField(
                  controller: _tokenController,
                  decoration: InputDecoration(
                    labelText: 'Mã Token',
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
                      return 'Vui lòng nhập mã token';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),
                // Input New Password
                PasswordField( // Reusing PasswordField from signup_screen
                   controller: _newPasswordController,
                   labelText: 'Mật khẩu mới',
                 ),
                const SizedBox(height: 15),
                // Confirm New Password
                PasswordField(
                  controller: _confirmPasswordController,
                  labelText: 'Xác nhận mật khẩu mới',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng xác nhận mật khẩu mới';
                    }
                    if (value != _newPasswordController.text) {
                      return 'Mật khẩu xác nhận không khớp';
                    }
                    if (value.length < 6) {
                         return 'Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Submit Button
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.purple)
                    : ElevatedButton(
                        onPressed: _submitReset,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[400],
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text(
                          'Đặt lại mật khẩu',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                 const SizedBox(height: 10),
                // Back to Login Button
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
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