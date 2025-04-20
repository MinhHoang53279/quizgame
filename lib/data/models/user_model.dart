class User {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final List<String> roles;
  final int score;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.roles,
    this.score = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['fullName'],
      roles: List<String>.from(json['roles']),
      score: json['score'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'roles': roles,
      'score': score,
    };
  }
} 