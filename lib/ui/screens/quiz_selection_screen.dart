import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/quiz_provider.dart';
import '../components/custom_button.dart';

class QuizSelectionScreen extends StatefulWidget {
  const QuizSelectionScreen({super.key});

  @override
  State<QuizSelectionScreen> createState() => _QuizSelectionScreenState();
}

class _QuizSelectionScreenState extends State<QuizSelectionScreen> {
  String? selectedCategory;
  String? selectedDifficulty;
  final int questionCount = 10;

  final List<String> categories = [
    'General Knowledge',
    'Science',
    'History',
    'Geography',
    'Sports',
    'Entertainment',
  ];

  final List<String> difficulties = [
    'Easy',
    'Medium',
    'Hard',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn Quiz'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chọn thể loại',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: categories.map((category) {
                        return ChoiceChip(
                          label: Text(category),
                          selected: selectedCategory == category,
                          onSelected: (selected) {
                            setState(() {
                              selectedCategory = selected ? category : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 4,
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
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: difficulties.map((difficulty) {
                        return ChoiceChip(
                          label: Text(difficulty),
                          selected: selectedDifficulty == difficulty,
                          onSelected: (selected) {
                            setState(() {
                              selectedDifficulty = selected ? difficulty : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: 'Bắt đầu Quiz',
              onPressed: () {
                if (selectedCategory != null && selectedDifficulty != null) {
                  final quizProvider = Provider.of<QuizProvider>(context, listen: false);
                  quizProvider.createQuiz(
                    userId: 'current_user_id', // Replace with actual user ID
                    category: selectedCategory,
                    difficulty: selectedDifficulty,
                    count: questionCount,
                  ).then((_) {
                    Navigator.pushNamed(context, '/quiz');
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng chọn thể loại và độ khó'),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
} 