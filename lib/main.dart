import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'auth/home_screen.dart';
import 'auth/forgot_password_screen.dart'; // Import màn hình quên mật khẩu
import 'auth/reset_password_screen.dart'; // Import màn hình reset mật khẩu
import 'data/providers/user_provider.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Quiz App',
        theme: ThemeData(primarySwatch: Colors.purple),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => const HomeScreen(),
          '/forgot_password': (context) => const ForgotPasswordScreen(),
          '/reset_password': (context) => const ResetPasswordScreen(),
        },
      ),
    );
  }
}
