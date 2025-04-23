import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quiz_model.dart';

class QuizService {
  final String baseUrl;

  QuizService({required this.baseUrl});

  Future<StartQuizResponse> createQuiz(CreateQuizRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/quizzes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      return StartQuizResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create quiz: ${response.body}');
    }
  }
} 