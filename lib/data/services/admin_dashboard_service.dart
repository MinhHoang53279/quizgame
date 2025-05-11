import 'dart:convert';
import 'dart:io' show Platform; // Keep Platform import for non-web
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb
import 'package:http/http.dart' as http;
import '../models/admin_dtos.dart'; // Import the DTOs we just defined
import 'auth_service.dart'; // To get the token

class AdminDashboardService {
  // Base URL for the admin-dashboard-service backend
  // Adjust the IP/port if your backend runs elsewhere
  static String get _baseUrl {
    const String envUrl = String.fromEnvironment('ADMIN_API_BASE_URL'); // Optional env variable
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    // API Gateway is running on 8090 and routes /api/admin/**
    if (kIsWeb) {
        return 'http://localhost:8090/api/admin'; // Trỏ đến API Gateway, cổng 8090
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8090/api/admin'; // Trỏ đến API Gateway, cổng 8090
    } else { // iOS or Desktop
      return 'http://localhost:8090/api/admin'; // Trỏ đến API Gateway, cổng 8090
    }
  }

  final http.Client _client;
  final AuthService _authService;

  // Constructor with dependency injection
  AdminDashboardService({http.Client? client, AuthService? authService})
      : _client = client ?? http.Client(),
        _authService = authService ?? AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }
    return {
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // --- User Management --- 

  Future<List<AdminUserDTO>> getAllUsers() async {
    final Uri url = Uri.parse('$_baseUrl/users');
    print('GET: $url');
    try {
      final headers = await _getHeaders();
      final response = await _client.get(url, headers: headers);
      print('Response Status (GET Users): ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes)); // Handle UTF8
        return data.map((json) => AdminUserDTO.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching users: $e');
      throw Exception('Failed to fetch users: $e');
    }
  }

  Future<void> deleteUser(String userId) async {
    final Uri url = Uri.parse('$_baseUrl/users/$userId');
    print('DELETE: $url');
    try {
      final headers = await _getHeaders();
      final response = await _client.delete(url, headers: headers);
      print('Response Status (DELETE User): ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 204) { // Allow 204 No Content
        throw Exception('Failed to delete user: ${response.statusCode} ${response.body}');
      }
      // No return needed on success
    } catch (e) {
      print('Error deleting user: $e');
      throw Exception('Failed to delete user: $e');
    }
  }

  // --- Quiz Management --- 

  Future<List<AdminQuizDTO>> getAllQuizzes() async {
    final Uri url = Uri.parse('$_baseUrl/quizzes');
     print('GET: $url');
    try {
      final headers = await _getHeaders();
      final response = await _client.get(url, headers: headers);
      print('Response Status (GET Quizzes): ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => AdminQuizDTO.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load quizzes: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching quizzes: $e');
      throw Exception('Failed to fetch quizzes: $e');
    }
  }

  Future<void> deleteQuiz(String quizId) async {
    final Uri url = Uri.parse('$_baseUrl/quizzes/$quizId');
    print('DELETE: $url');
    try {
      final headers = await _getHeaders();
      final response = await _client.delete(url, headers: headers);
      print('Response Status (DELETE Quiz): ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete quiz: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error deleting quiz: $e');
      throw Exception('Failed to delete quiz: $e');
    }
  }

  // --- Question Management --- 

  Future<List<AdminQuestionDTO>> getAllQuestions() async {
    final Uri url = Uri.parse('$_baseUrl/questions');
    print('GET: $url');
    try {
      final headers = await _getHeaders();
      final response = await _client.get(url, headers: headers);
       print('Response Status (GET Questions): ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.map((json) => AdminQuestionDTO.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load questions: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching questions: $e');
      throw Exception('Failed to fetch questions: $e');
    }
  }

  Future<void> deleteQuestion(String questionId) async {
    final Uri url = Uri.parse('$_baseUrl/questions/$questionId');
     print('DELETE: $url');
    try {
      final headers = await _getHeaders();
      final response = await _client.delete(url, headers: headers);
      print('Response Status (DELETE Question): ${response.statusCode}');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete question: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error deleting question: $e');
      throw Exception('Failed to delete question: $e');
    }
  }

  // --- Summary Data --- 

  Future<DashboardSummaryDTO> getDashboardSummary() async {
    final Uri url = Uri.parse('$_baseUrl/summary'); // New endpoint
    print('GET: $url');
    try {
      final headers = await _getHeaders();
      final response = await _client.get(url, headers: headers);
      print('Response Status (GET Summary): ${response.statusCode}');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        return DashboardSummaryDTO.fromJson(data); // Use the new DTO
      } else {
        throw Exception('Failed to load dashboard summary: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching dashboard summary: $e');
      throw Exception('Failed to fetch dashboard summary: $e');
    }
  }
} 