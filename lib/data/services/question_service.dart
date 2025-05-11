import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class QuestionService {
  static const String baseUrl = 'http://localhost:8080/api/questions'; // API Gateway URL

  // Create a new question
  Future<Map<String, dynamic>> createQuestion({
    required String question,
    String? details,
    required String category,
    required String difficulty,
    required List<String> options,
    required int correctAnswerIndex,
    String? explanation,
  }) async {
    try {
      final Map<String, dynamic> payload = {
        'questionText': question,
        'category': category,
        'difficulty': difficulty,
        'options': options,
        'correctAnswerIndex': correctAnswerIndex,
      };
      if (details != null && details.isNotEmpty) payload['details'] = details;
      if (explanation != null && explanation.isNotEmpty) payload['explanation'] = explanation;

      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': jsonDecode(response.body),
        };
      } else {
        print('Create question error: ${response.body}');
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'error': errorData['message'] ?? 'Failed to create question',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Error creating question: $e',
      };
    }
  }

  // Get questions with optional filters
  Future<List<Question>> getQuestions({
    String? category,
    String? difficulty,
    int page = 0,
    int size = 10,
  }) async {
    try {
      final queryParams = {
        if (category != null) 'category': category,
        if (difficulty != null) 'difficulty': difficulty,
        'page': page.toString(),
        'size': size.toString(),
      };

      final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Question.fromJson(json)).toList();
      } else {
        throw Exception('Failed to get questions: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error getting questions: $e');
    }
  }

  Future<Question> getQuestionById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return Question.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load question: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error loading question: $e');
    }
  }
} 