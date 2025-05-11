class Question {
  final String id;
  final String question;
  final String? details;
  final String category;
  final String difficulty;
  final List<String> options;
  final int correctAnswerIndex;
  final String? explanation;
  final String createdBy;
  final DateTime createdAt;

  Question({
    required this.id,
    required this.question,
    this.details,
    required this.category,
    required this.difficulty,
    required this.options,
    required this.correctAnswerIndex,
    this.explanation,
    required this.createdBy,
    required this.createdAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      question: json['question'] as String,
      details: json['details'] as String?,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswerIndex: json['correctAnswerIndex'] as int,
      explanation: json['explanation'] as String?,
      createdBy: json['createdBy'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'details': details,
      'category': category,
      'difficulty': difficulty,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'explanation': explanation,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
    };
  }
} 