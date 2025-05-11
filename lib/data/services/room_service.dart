import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room.dart';

class RoomService {
  static const String baseUrl = 'http://localhost:8090/api/rooms';

  Future<Room> createRoom(String hostId) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'hostId': hostId}),
    );
    if (response.statusCode == 201) {
      return Room.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create room');
    }
  }

  Future<Room> joinRoom(String code, String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/join'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code, 'userId': userId}),
    );
    if (response.statusCode == 200) {
      return Room.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to join room');
    }
  }

  Future<Room> getRoom(String roomId) async {
    final response = await http.get(Uri.parse('$baseUrl/$roomId'));
    if (response.statusCode == 200) {
      return Room.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get room');
    }
  }

  // Thêm các hàm khác như startQuiz, submitAnswer, getResults nếu cần
} 