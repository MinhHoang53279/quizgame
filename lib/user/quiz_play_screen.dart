import 'package:flutter/material.dart';
import 'practice_screen.dart'; // Import để lấy PracticeCategory

// --- Model cho Câu hỏi và Đáp án ---
class Question {
  final String id;
  final String questionText;
  final List<String> options; // Danh sách các lựa chọn
  final String correctAnswer; // Đáp án đúng (giả định là text của option)

  const Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
  });
}

// --- Màn hình Quiz Play ---
class QuizPlayScreen extends StatefulWidget {
  final PracticeCategory category; // Nhận category từ màn hình trước

  const QuizPlayScreen({super.key, required this.category});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  // Danh sách câu hỏi mẫu (sẽ thay bằng API call sau)
  final List<Question> _dummyQuestions = const [
    Question(
      id: 'q1',
      questionText: 'What is the capital of France?',
      options: ['Berlin', 'Madrid', 'Paris', 'Rome'],
      correctAnswer: 'Paris',
    ),
    Question(
      id: 'q2',
      questionText: 'Which planet is known as the Red Planet?',
      options: ['Earth', 'Mars', 'Jupiter', 'Saturn'],
      correctAnswer: 'Mars',
    ),
    Question(
      id: 'q3',
      questionText: 'Who wrote \'Hamlet\'?',
      options: ['Charles Dickens', 'William Shakespeare', 'Leo Tolstoy', 'Mark Twain'],
      correctAnswer: 'William Shakespeare',
    ),
    Question(
      id: 'q4',
      questionText: 'What is the largest ocean on Earth?',
      options: ['Atlantic', 'Indian', 'Arctic', 'Pacific'],
      correctAnswer: 'Pacific',
    ),
  ];

  int _currentQuestionIndex = 0; // Chỉ số câu hỏi hiện tại
  String? _selectedAnswer; // Lựa chọn của người dùng
  int _score = 0; // Điểm số
  bool _isAnswered = false; // Đã trả lời câu hiện tại chưa?

  // --- Hàm xử lý logic ---
  void _handleAnswer(String answer) {
    setState(() {
      _selectedAnswer = answer;
      _isAnswered = true;
      if (answer == _dummyQuestions[_currentQuestionIndex].correctAnswer) {
        _score++; // Tăng điểm nếu đúng
      }
    });

    // (Tùy chọn) Tự động chuyển câu sau 1-2 giây
    // Future.delayed(const Duration(seconds: 1), () {
    //   _nextQuestion();
    // });
  }

  void _nextQuestion() {
    setState(() {
      if (_currentQuestionIndex < _dummyQuestions.length - 1) {
        _currentQuestionIndex++;
        _selectedAnswer = null; // Reset lựa chọn
        _isAnswered = false; // Reset trạng thái trả lời
      } else {
        // Quiz kết thúc - Hiển thị màn hình kết quả
        // TODO: Navigate to a result screen
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Không cho đóng bằng cách nhấn bên ngoài
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quiz Completed!'),
          content: Text('Your score: $_score / ${_dummyQuestions.length}'),
          actions: <Widget>[
            TextButton(
              child: const Text('Play Again'),
              onPressed: () {
                // TODO: Reset state and start over or navigate back
                 Navigator.of(context).pop(); // Đóng dialog
                 setState(() { // Reset state
                   _currentQuestionIndex = 0;
                   _selectedAnswer = null;
                   _score = 0;
                   _isAnswered = false;
                 });
              },
            ),
            TextButton(
              child: const Text('Back to Topics'),
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                Navigator.of(context).pop(); // Quay lại màn hình PracticeScreen
              },
            ),
          ],
        );
      },
    );
  }


  // --- Hàm xây dựng UI ---
  @override
  Widget build(BuildContext context) {
    final currentQuestion = _dummyQuestions[_currentQuestionIndex];
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name), // Lấy tên category
        backgroundColor: widget.category.color, // Dùng màu của category
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tiến trình (vd: Question 1/4)
            Text(
              'Question ${_currentQuestionIndex + 1}/${_dummyQuestions.length}',
              style: textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Thanh tiến trình tuyến tính
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _dummyQuestions.length,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(widget.category.color),
              minHeight: 8,
            ),
            const SizedBox(height: 30),

            // Câu hỏi
            Container(
              padding: const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  )
                ]
              ),
              child: Text(
                currentQuestion.questionText,
                style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),

            // Các lựa chọn trả lời
            ...currentQuestion.options.map((option) {
              bool isSelected = _selectedAnswer == option;
              bool isCorrect = option == currentQuestion.correctAnswer;
              Color? tileColor;
              Color? textColor = Colors.black87;
              Icon? trailingIcon;

              if (_isAnswered) { // Nếu đã trả lời
                if (isSelected) { // Lựa chọn của user
                  tileColor = isCorrect ? Colors.green.shade100 : Colors.red.shade100;
                  trailingIcon = Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: isCorrect ? Colors.green : Colors.red);
                  textColor = isCorrect ? Colors.green.shade900 : Colors.red.shade900;
                } else if (isCorrect) { // Đáp án đúng (nhưng user ko chọn)
                  tileColor = Colors.green.shade50; // Highlight nhẹ đáp án đúng
                  textColor = Colors.green.shade700;
                }
              } else { // Chưa trả lời
                 tileColor = Colors.white;
              }

              return Card(
                 elevation: _isAnswered ? 0 : 2, // Bỏ elevation khi đã trả lời
                 margin: const EdgeInsets.symmetric(vertical: 6.0),
                 color: tileColor,
                 shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: BorderSide(color: isSelected ? (isCorrect ? Colors.green : Colors.red) : Colors.grey.shade300)
                 ),
                 child: ListTile(
                    title: Text(option, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: textColor)),
                    trailing: trailingIcon,
                    onTap: _isAnswered ? null : () => _handleAnswer(option), // Chỉ cho phép nhấn khi chưa trả lời
                 ),
              );
            }).toList(),

            const Spacer(), // Đẩy nút Next xuống dưới

            // Nút Next/Submit
            ElevatedButton(
              onPressed: _isAnswered ? _nextQuestion : null, // Chỉ bật khi đã trả lời
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.category.color,
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              ),
              child: Text(
                _currentQuestionIndex < _dummyQuestions.length - 1 ? 'Next Question' : 'Finish Quiz',
                style: const TextStyle(color: Colors.white), // Thêm màu trắng cho text
              ),
            ),
            const SizedBox(height: 10), // Khoảng cách dưới cùng
          ],
        ),
      ),
    );
  }
} 