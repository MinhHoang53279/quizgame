import 'dart:convert';
import 'package:http/http.dart' as http;

class UserService {
  static const String baseUrl = 'http://localhost:8090/api/users'; // API Gateway URL

  // Create a new user
  Future<Map<String, dynamic>> createUser({
    required String username,
    required String email,
    required String password,
    required String fullName,
    List<String> roles = const ['USER'],
  }) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'fullName': fullName,
          'roles': roles,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  // Get user by username
  Future<Map<String, dynamic>> getUserByUsername(String username) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/username/$username'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

  // Update user score
  Future<Map<String, dynamic>> updateScore(String userId, int scoreChange) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/$userId/score'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(scoreChange),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update score: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error updating score: $e');
    }
  }
} 