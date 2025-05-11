import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/providers/user_provider.dart';
import '../theme.dart';

/**
  * Màn hình chính sau khi người dùng đăng nhập thành công.
  * Hiển thị thông tin người dùng và nút đăng xuất.
 */
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy thông tin người dùng hiện tại từ UserProvider
    final user = Provider.of<UserProvider>(context).currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // quay lại
          },
        ),
        title: Row(
          children: [
            // Logo ở giữa mũi tên và chữ Quiz App
            Image.asset(
              'assets/images/image1.png',
              height: 50,
            ),
            const SizedBox(width: 10),
            const Text('Quiz App'),
          ],
        ),
        actions: [
          // Nút đăng xuất
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              // Gọi provider để đăng xuất và quay về màn hình login
              await Provider.of<UserProvider>(context, listen: false).logout();
              // Đảm bảo context vẫn hợp lệ trước khi điều hướng
              if (context.mounted) {
                 Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
          ),
        ),
        child: Center(
          child: user == null
              ? const CircularProgressIndicator()
              : Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Chào mừng trở lại, ${user.fullName}!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text('Username: ${user.username}'),
                      Text('Email: ${user.email}'),
                      Text('Vai trò: ${user.roles.join(', ')}'),
                      Text('Điểm: ${user.score}'),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
