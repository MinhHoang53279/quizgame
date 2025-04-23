import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/providers/user_provider.dart';
import 'data/providers/quiz_provider.dart';
import 'data/services/user_service.dart';
import 'data/services/quiz_service.dart';
import 'auth/login_screen.dart';
import 'auth/signup_screen.dart';
import 'auth/forgot_password_screen.dart';
import 'auth/reset_password_screen.dart';
import 'auth/home_screen.dart';
import 'auth/quiz_screen.dart';
import 'ui/screens/quiz_selection_screen.dart';
import 'ui/screens/quiz_results_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => QuizProvider(
            quizService: QuizService(baseUrl: 'http://localhost:8080'),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Quiz App',
        theme: ThemeData(
          primarySwatch: Colors.purple,
          useMaterial3: true,
          cardTheme: CardTheme(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignUpScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/reset-password': (context) => const ResetPasswordScreen(),
          '/home': (context) => const HomeScreen(),
          '/quiz': (context) => const QuizScreen(),
          '/quiz-selection': (context) => const QuizSelectionScreen(),
          '/quiz-results': (context) => const QuizResultsScreen(),
        },
      ),
    );
  }
}
