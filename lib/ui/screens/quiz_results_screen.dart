import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/providers/quiz_provider.dart';
import '../../data/models/quiz_model.dart';
import '../components/custom_button.dart';

class QuizResultsScreen extends StatelessWidget {
  const QuizResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizProvider = Provider.of<QuizProvider>(context);
    final quiz = quizProvider.currentQuiz;

    if (quiz == null || quiz.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Kết quả Quiz'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
        body: const Center(
          child: Text('Không có kết quả quiz để hiển thị.'),
        ),
      );
    }

    int correctAnswers = 0;
    for (var question in quiz.questions) {
      if (question.userAnswer == question.correctAnswer) {
        correctAnswers++;
      }
    }
    final totalQuestions = quiz.questions.length;
    final score = totalQuestions == 0 ? 0 : (correctAnswers / totalQuestions * 100).round();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả Quiz'),
        backgroundColor: Theme.of(context).primaryColor,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Text(
                        'Kết quả của bạn',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$score%',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: _getScoreColor(score),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '$correctAnswers/$totalQuestions câu đúng',
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Chi tiết câu hỏi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: quiz.questions.length,
                itemBuilder: (context, index) {
                  final question = quiz.questions[index];
                  final isCorrect = question.userAnswer == question.correctAnswer;
                  final userAnswerDisplay = question.userAnswer ?? 'Chưa trả lời';

                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Câu ${index + 1}: ${question.questionText}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Đáp án của bạn: $userAnswerDisplay',
                            style: TextStyle(
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                          ),
                          if (!isCorrect)
                            Text(
                              'Đáp án đúng: ${question.correctAnswer}',
                              style: const TextStyle(
                                color: Colors.green,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Làm quiz mới',
                onPressed: () {
                  quizProvider.clearQuiz();
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
} 