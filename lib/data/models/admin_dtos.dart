// lib/data/models/admin_dtos.dart

// DTO for User data from admin perspective
class AdminUserDTO {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final int score;
  final List<String> roles;

  AdminUserDTO({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.score,
    required this.roles,
  });

  factory AdminUserDTO.fromJson(Map<String, dynamic> json) {
    return AdminUserDTO(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      score: json['score'] as int? ?? 0,
      roles: json['roles'] != null ? List<String>.from(json['roles']) : ['.USER'], // Default role if missing
    );
  }
}

// DTO for Quiz data from admin perspective (assuming similar structure to backend)
class AdminQuizDTO {
  final String id;
  final String userId; // Assuming backend returns userId
  final List<String> questionIds;
  final Map<String, String> answers; // User's answers
  final int score;
  final DateTime createdAt; // Or use String if backend returns String

  AdminQuizDTO({
    required this.id,
    required this.userId,
    required this.questionIds,
    required this.answers,
    required this.score,
    required this.createdAt,
  });

  factory AdminQuizDTO.fromJson(Map<String, dynamic> json) {
    return AdminQuizDTO(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '', // Adjust based on actual backend field name
      questionIds: json['questionIds'] != null ? List<String>.from(json['questionIds']) : [],
      answers: json['answers'] != null ? Map<String, String>.from(json['answers']) : {},
      score: json['score'] as int? ?? 0,
      // Handle potential null or incorrect format for timestamp
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now()
          : DateTime.now(),
    );
  }
}


// DTO for Question data from admin perspective
class AdminQuestionDTO {
  final String id;
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  final String category;
  final String difficulty;

  AdminQuestionDTO({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
    required this.difficulty,
  });

  factory AdminQuestionDTO.fromJson(Map<String, dynamic> json) {
    return AdminQuestionDTO(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      options: json['options'] != null ? List<String>.from(json['options']) : [],
      correctAnswerIndex: json['correctAnswerIndex'] as int? ?? 0,
      category: json['category'] as String? ?? 'Unknown',
      difficulty: json['difficulty'] as String? ?? 'Unknown',
    );
  }
}

// --- New DTOs for Summary Data ---

class DashboardSummaryDTO {
  final UserSummaryDTO users;
  final QuizSummaryDTO quizzes;
  final List<RecentActivityDTO> recentActivity;

  DashboardSummaryDTO({
    required this.users,
    required this.quizzes,
    required this.recentActivity,
  });

  factory DashboardSummaryDTO.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryDTO(
      users: UserSummaryDTO.fromJson(json['users'] ?? {}),
      quizzes: QuizSummaryDTO.fromJson(json['quizzes'] ?? {}),
      recentActivity: (json['recent_activity'] as List<dynamic>? ?? [])
          .map((item) => RecentActivityDTO.fromJson(item as Map<String, dynamic>? ?? {}))
          .toList(),
    );
  }
}

class UserSummaryDTO {
  final int total;
  final int newToday;

  UserSummaryDTO({required this.total, required this.newToday});

  factory UserSummaryDTO.fromJson(Map<String, dynamic> json) {
    return UserSummaryDTO(
      total: json['total'] as int? ?? 0,
      newToday: json['new_today'] as int? ?? 0,
    );
  }
}

class QuizSummaryDTO {
  final int total;
  final int active;

  QuizSummaryDTO({required this.total, required this.active});

  factory QuizSummaryDTO.fromJson(Map<String, dynamic> json) {
    return QuizSummaryDTO(
      total: json['total'] as int? ?? 0,
      active: json['active'] as int? ?? 0,
    );
  }
}

class RecentActivityDTO {
  final String user;
  final String action;
  final DateTime timestamp;

  RecentActivityDTO({
    required this.user,
    required this.action,
    required this.timestamp,
  });

  factory RecentActivityDTO.fromJson(Map<String, dynamic> json) {
    return RecentActivityDTO(
      user: json['user'] as String? ?? 'Unknown User',
      action: json['action'] as String? ?? 'Unknown Action',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now()
          : DateTime.now(),
    );
  }
} 