class QuizQuestion {
  final String id;
  final String questionText;
  final List<String> options;
  final String category;
  final String difficulty;
  final String correctAnswer;
  String? userAnswer;

  QuizQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.category,
    required this.difficulty,
    required this.correctAnswer,
    this.userAnswer,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      questionText: json['questionText'],
      options: List<String>.from(json['options']),
      category: json['category'],
      difficulty: json['difficulty'],
      correctAnswer: json['correctAnswer'],
      userAnswer: json['userAnswer'],
    );
  }
}

class StartQuizResponse {
  final String quizId;
  final List<QuizQuestion> questions;

  StartQuizResponse({
    required this.quizId,
    required this.questions,
  });

  factory StartQuizResponse.fromJson(Map<String, dynamic> json) {
    return StartQuizResponse(
      quizId: json['quizId'],
      questions: (json['questions'] as List)
          .map((q) => QuizQuestion.fromJson(q))
          .toList(),
    );
  }
}

class CreateQuizRequest {
  final String userId;
  final String? category;
  final String? difficulty;
  final int count;
  final bool randomOrder;

  CreateQuizRequest({
    required this.userId,
    this.category,
    this.difficulty,
    this.count = 10,
    this.randomOrder = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'category': category,
      'difficulty': difficulty,
      'count': count,
      'randomOrder': randomOrder,
    };
  }
} 