import 'package:flutter/foundation.dart';
import '../models/admin_dtos.dart';
import '../services/admin_dashboard_service.dart';

class AdminDashboardProvider with ChangeNotifier {
  final AdminDashboardService _adminService;

  // Private state variables
  List<AdminUserDTO> _users = [];
  List<AdminQuizDTO> _quizzes = [];
  List<AdminQuestionDTO> _questions = [];
  DashboardSummaryDTO? _summaryData;
  bool _isLoading = false;
  String? _error;

  // Constructor
  AdminDashboardProvider({AdminDashboardService? adminService})
      : _adminService = adminService ?? AdminDashboardService();

  // Getters for UI to access state
  List<AdminUserDTO> get users => _users;
  List<AdminQuizDTO> get quizzes => _quizzes;
  List<AdminQuestionDTO> get questions => _questions;
  DashboardSummaryDTO? get summaryData => _summaryData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all necessary data for the dashboard
  Future<void> fetchAdminData() async {
    _isLoading = true;
    _error = null;
    _summaryData = null;
    notifyListeners();

    try {
      // Fetch summary data first
      _summaryData = await _adminService.getDashboardSummary();
      print("Fetched summary data successfully."); // Log success

      // --- REMOVE DETAILED FETCHES FOR NOW ---
      /*
      // TODO: Decide if we still need to fetch all detailed lists 
      // or if the summary is enough for the initial view.
      // For now, let's keep fetching details as well, but consider 
      // removing this if the summary view is sufficient.
      final results = await Future.wait([
        _adminService.getAllUsers(),
        _adminService.getAllQuizzes(),
        _adminService.getAllQuestions(),
      ]);

      _users = results[0] as List<AdminUserDTO>;
      _quizzes = results[1] as List<AdminQuizDTO>;
      _questions = results[2] as List<AdminQuestionDTO>;
      */
      // Clear the detailed lists as they are not fetched anymore
      _users = []; 
      _quizzes = [];
      _questions = [];
      // --- END REMOVAL ---

      _error = null; // Clear error on success
    } catch (e) {
      print('Error fetching admin data: $e');
      _error = e.toString().replaceFirst("Exception: ", "");
      // Clear data on error to avoid showing stale data
      _users = [];
      _quizzes = [];
      _questions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete a user
  Future<bool> deleteUser(String userId) async {
    // Note: We might not want to show loading for delete actions, 
    // or handle it differently in the UI.
    _error = null; // Clear previous errors
    // notifyListeners(); // Optional: notify UI about starting deletion

    try {
      await _adminService.deleteUser(userId);
      // Remove the user from the local list upon successful deletion
      _users.removeWhere((user) => user.id == userId);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      _error = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

   // Delete a quiz
  Future<bool> deleteQuiz(String quizId) async {
     _error = null;
    try {
      await _adminService.deleteQuiz(quizId);
      _quizzes.removeWhere((quiz) => quiz.id == quizId);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting quiz: $e');
      _error = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

   // Delete a question
  Future<bool> deleteQuestion(String questionId) async {
    _error = null;
    try {
      await _adminService.deleteQuestion(questionId);
      _questions.removeWhere((question) => question.id == questionId);
      notifyListeners();
      return true;
    } catch (e) {
      print('Error deleting question: $e');
      _error = e.toString().replaceFirst("Exception: ", "");
      notifyListeners();
      return false;
    }
  }

  // Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
} 