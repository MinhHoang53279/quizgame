import 'package:flutter/material.dart';
import '../data/models/question.dart';
import '../data/models/category.dart';
import '../theme.dart';

// --- Màn hình Quiz Play ---
class QuizPlayScreen extends StatefulWidget {
  final Category category;
  const QuizPlayScreen({super.key, required this.category});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  // TODO: Lấy danh sách câu hỏi từ backend dựa trên category
  // Sử dụng QuestionService().getQuestions(category: widget.category.name)

  @override
  Widget build(BuildContext context) {
    // TODO: Hiển thị quiz thực tế từ backend
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        backgroundColor: Colors.blue, // hoặc widget.category.color nếu có
        elevation: 0,
      ),
      body: Center(
        child: Text('Quiz cho chủ đề: \\${widget.category.name}'),
      ),
    );
  }
} 