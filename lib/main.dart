import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'auth/forgot_password_screen.dart'; // Import màn hình quên mật khẩu
import 'auth/reset_password_screen.dart'; // Import màn hình reset mật khẩu
import 'admin/admin_dashboard_screen.dart'; // Import màn hình admin dashboard
import 'user/home_screen.dart'; // <<< ADD NEW IMPORT
import 'user/practice_screen.dart'; // <<< THÊM IMPORT CHO PRACTICE SCREEN
import 'user/quiz_play_screen.dart'; // <<< THÊM IMPORT CHO QUIZ PLAY SCREEN
import 'user/create_question_screen.dart'; // <<< THÊM IMPORT CHO CREATE QUESTION
import 'data/providers/user_provider.dart';
import 'data/providers/admin_dashboard_provider.dart'; // Import provider admin
import 'data/providers/settings_provider.dart'; // <<< ADD IMPORT FOR SETTINGS PROVIDER
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'data/models/category.dart'; // Thêm import cho Category
import 'theme.dart';

/**
 * Hàm main, điểm khởi đầu của ứng dụng.
 */
void main() {
  runApp(const QuizApp());
}

/**
 * Widget gốc của ứng dụng Quiz App.
 * Cấu hình MaterialApp, MultiProvider và định tuyến (routes).
 */
class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Sử dụng MultiProvider để cung cấp các Provider cho toàn bộ ứng dụng
    return MultiProvider(
      providers: [
        // Cung cấp UserProvider để quản lý trạng thái người dùng
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // Cung cấp AdminDashboardProvider
        ChangeNotifierProvider(create: (_) => AdminDashboardProvider()), 
        ChangeNotifierProvider(create: (_) => SettingsProvider()), // <<< REGISTER SETTINGS PROVIDER
        // Thêm các provider khác nếu cần (ví dụ: QuizProvider, QuestionProvider)
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false, // Ẩn banner debug
        title: 'Quiz App',
        theme: AppTheme.themeData, // Sử dụng theme chung
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          FlutterQuillLocalizations.delegate, // Delegate của Quill
        ],
        supportedLocales: const [
          Locale('en'), // Chỉ cần tiếng Anh cho Quill hoạt động
          // Thêm các ngôn ngữ khác nếu bạn hỗ trợ đa ngôn ngữ
          // Locale('vi'), 
        ],
        initialRoute: '/login', // Route mặc định khi mở ứng dụng
        // Định nghĩa các routes của ứng dụng
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/home': (context) => const UserHomeScreen(),
          '/forgot_password': (context) => const ForgotPasswordScreen(),
          '/reset_password': (context) => const ResetPasswordScreen(),
          '/admin_dashboard': (context) => const AdminDashboardScreen(), // Thêm route admin
          '/practice': (context) => const PracticeScreen(), // <<< THÊM ROUTE PRACTICE
          // Route mới cho màn hình chơi quiz, nhận category làm argument
          '/quiz_play': (context) {
            final category = ModalRoute.of(context)!.settings.arguments as Category;
            return QuizPlayScreen(category: category);
          },
          '/create_question': (context) => const CreateQuestionScreen(), // <<< THÊM ROUTE CREATE QUESTION
        },
      ),
    );
  }
}
