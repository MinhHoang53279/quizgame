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
  final QuestionSummaryDTO questions;
  final NotificationSummaryDTO notifications;

  DashboardSummaryDTO({
    required this.users,
    required this.quizzes,
    required this.questions,
    required this.notifications,
  });

  factory DashboardSummaryDTO.fromJson(Map<String, dynamic> json) {
    return DashboardSummaryDTO(
      users: UserSummaryDTO.fromJson(json['users']),
      quizzes: QuizSummaryDTO.fromJson(json['quizzes']),
      questions: QuestionSummaryDTO.fromJson(json['questions']),
      notifications: NotificationSummaryDTO.fromJson(json['notifications']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users.toJson(),
      'quizzes': quizzes.toJson(),
      'questions': questions.toJson(),
      'notifications': notifications.toJson(),
    };
  }
}

class UserSummaryDTO {
  final int total;
  final int active;
  final int newUsers;

  UserSummaryDTO({
    required this.total,
    required this.active,
    required this.newUsers,
  });

  factory UserSummaryDTO.fromJson(Map<String, dynamic> json) {
    return UserSummaryDTO(
      total: json['total'],
      active: json['active'],
      newUsers: json['newUsers'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'active': active,
      'newUsers': newUsers,
    };
  }
}

class QuizSummaryDTO {
  final int total;
  final int active;
  final int completed;

  QuizSummaryDTO({
    required this.total,
    required this.active,
    required this.completed,
  });

  factory QuizSummaryDTO.fromJson(Map<String, dynamic> json) {
    return QuizSummaryDTO(
      total: json['total'],
      active: json['active'],
      completed: json['completed'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'active': active,
      'completed': completed,
    };
  }
}

class QuestionSummaryDTO {
  final int total;
  final int active;
  final int pending;

  QuestionSummaryDTO({
    required this.total,
    required this.active,
    required this.pending,
  });

  factory QuestionSummaryDTO.fromJson(Map<String, dynamic> json) {
    return QuestionSummaryDTO(
      total: json['total'],
      active: json['active'],
      pending: json['pending'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'active': active,
      'pending': pending,
    };
  }
}

class NotificationSummaryDTO {
  final int total;
  final int unread;
  final int sent;

  NotificationSummaryDTO({
    required this.total,
    required this.unread,
    required this.sent,
  });

  factory NotificationSummaryDTO.fromJson(Map<String, dynamic> json) {
    return NotificationSummaryDTO(
      total: json['total'],
      unread: json['unread'],
      sent: json['sent'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'unread': unread,
      'sent': sent,
    };
  }
}

class UserActivityDTO {
  final String id;
  final String type;
  final String description;
  final DateTime timestamp;
  final String userId;
  final String? userName;

  UserActivityDTO({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.userId,
    this.userName,
  });

  factory UserActivityDTO.fromJson(Map<String, dynamic> json) {
    return UserActivityDTO(
      id: json['id'],
      type: json['type'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
      userName: json['userName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'userName': userName,
    };
  }
}

class TopUserDTO {
  final String id;
  final String name;
  final int points;
  final int rank;
  final String? avatarUrl;

  TopUserDTO({
    required this.id,
    required this.name,
    required this.points,
    required this.rank,
    this.avatarUrl,
  });

  factory TopUserDTO.fromJson(Map<String, dynamic> json) {
    return TopUserDTO(
      id: json['id'],
      name: json['name'],
      points: json['points'],
      rank: json['rank'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'points': points,
      'rank': rank,
      'avatarUrl': avatarUrl,
    };
  }
} 