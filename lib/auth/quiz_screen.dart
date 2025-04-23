import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/providers/quiz_provider.dart';
import '../data/providers/user_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  String? selectedCategory;
  String? selectedDifficulty;
  bool randomOrder = true;
  final int questionCount = 10;

  final List<String> categories = ['Toán', 'Lý', 'Hóa', 'Sinh', 'Sử', 'Địa'];
  final List<String> difficulties = ['Dễ', 'Trung bình', 'Khó'];

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[400],
        title: const Text('Tạo Quiz Mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Chọn chế độ
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chế độ câu hỏi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Thứ tự câu hỏi giống nhau'),
                            value: false,
                            groupValue: randomOrder,
                            onChanged: (value) {
                              setState(() {
                                randomOrder = value!;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<bool>(
                            title: const Text('Thứ tự câu hỏi khác nhau'),
                            value: true,
                            groupValue: randomOrder,
                            onChanged: (value) {
                              setState(() {
                                randomOrder = value!;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Chọn chủ đề
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chọn chủ đề',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Chọn chủ đề',
                      ),
                      items: categories.map((category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Chọn độ khó
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chọn độ khó',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedDifficulty,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Chọn độ khó',
                      ),
                      items: difficulties.map((difficulty) {
                        return DropdownMenuItem<String>(
                          value: difficulty,
                          child: Text(difficulty),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedDifficulty = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Nút bắt đầu
            ElevatedButton(
              onPressed: quizProvider.isLoading
                  ? null
                  : () {
                      quizProvider.createQuiz(
                        userId: userProvider.currentUser!.id,
                        category: selectedCategory,
                        difficulty: selectedDifficulty,
                        count: questionCount,
                        randomOrder: randomOrder,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[400],
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: quizProvider.isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Bắt đầu Quiz',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
            ),
            if (quizProvider.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  quizProvider.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 