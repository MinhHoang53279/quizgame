import 'package:flutter/foundation.dart';
import '../models/admin_dtos.dart';
import '../services/admin_dashboard_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminDashboardProvider with ChangeNotifier {
  final AdminDashboardService _adminService;

  // Private state variables
  List<AdminUserDTO> _users = [];
  List<AdminQuizDTO> _quizzes = [];
  List<AdminQuestionDTO> _questions = [];
  DashboardSummaryDTO? _summaryData;
  List<UserActivityDTO> _recentActivities = [];
  List<TopUserDTO> _topUsers = [];
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
  List<UserActivityDTO> get recentActivities => _recentActivities;
  List<TopUserDTO> get topUsers => _topUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all necessary data for the dashboard
  Future<void> fetchAdminData() async {
    _isLoading = true;
    _error = null;
    _summaryData = null;
    notifyListeners();

    try {
      // Fetch summary data
      final summaryResponse = await http.get(Uri.parse('http://localhost:8080/api/admin/summary'));
      if (summaryResponse.statusCode == 200) {
        _summaryData = DashboardSummaryDTO.fromJson(json.decode(summaryResponse.body));
      }

      // Fetch recent activities
      final activitiesResponse = await http.get(Uri.parse('http://localhost:8080/api/admin/activities'));
      if (activitiesResponse.statusCode == 200) {
        final List<dynamic> activitiesJson = json.decode(activitiesResponse.body);
        _recentActivities = activitiesJson.map((json) => UserActivityDTO.fromJson(json)).toList();
      }

      // Fetch top users
      final usersResponse = await http.get(Uri.parse('http://localhost:8080/api/admin/top-users'));
      if (usersResponse.statusCode == 200) {
        final List<dynamic> usersJson = json.decode(usersResponse.body);
        _topUsers = usersJson.map((json) => TopUserDTO.fromJson(json)).toList();
      }

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

  // Add new activity
  Future<void> addActivity(UserActivityDTO activity) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:8080/api/admin/activities'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(activity.toJson()),
      );

      if (response.statusCode == 201) {
        _recentActivities.insert(0, activity);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Update user points
  Future<void> updateUserPoints(String userId, int points) async {
    try {
      final response = await http.put(
        Uri.parse('http://localhost:8080/api/admin/users/$userId/points'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'points': points}),
      );

      if (response.statusCode == 200) {
        // Refresh data after update
        await fetchAdminData();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  // Delete activity
  Future<void> deleteActivity(String activityId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:8080/api/admin/activities/$activityId'),
      );

      if (response.statusCode == 200) {
        _recentActivities.removeWhere((activity) => activity.id == activityId);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
} 