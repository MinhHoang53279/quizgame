import 'package:flutter/foundation.dart';
import '../models/quiz_model.dart';
import '../services/quiz_service.dart';

class QuizProvider with ChangeNotifier {
  final QuizService _quizService;
  StartQuizResponse? _currentQuiz;
  bool _isLoading = false;
  String? _error;

  QuizProvider({required QuizService quizService}) : _quizService = quizService;

  StartQuizResponse? get currentQuiz => _currentQuiz;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> createQuiz({
    required String userId,
    String? category,
    String? difficulty,
    int count = 10,
    bool randomOrder = true,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final request = CreateQuizRequest(
        userId: userId,
        category: category,
        difficulty: difficulty,
        count: count,
        randomOrder: randomOrder,
      );

      _currentQuiz = await _quizService.createQuiz(request);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearQuiz() {
    _currentQuiz = null;
    _error = null;
    notifyListeners();
  }
} 