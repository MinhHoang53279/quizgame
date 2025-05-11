import 'package:flutter/material.dart';
import '../theme.dart';

class RoomQuizScreen extends StatelessWidget {
  final String roomId;
  const RoomQuizScreen({super.key, required this.roomId});

  @override
  Widget build(BuildContext context) {
    // TODO: Lấy danh sách câu hỏi của phòng từ backend, hiển thị quiz cho từng thành viên
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz trong phòng')),
      body: Center(child: Text('Quiz cho phòng: $roomId')),
    );
  }
} 