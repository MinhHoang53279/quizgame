/**
 * Model đại diện cho dữ liệu người dùng trong ứng dụng Flutter.
 */
class User {
  final String id;
  final String username;
  final String email;
  final String fullName;
  final List<String> roles;
  final int score;

  /**
   * Constructor để tạo đối tượng User.
   */
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.roles,
    this.score = 0,
  });

  /**
   * Factory constructor để tạo đối tượng User từ dữ liệu JSON (thường từ API response).
   * @param json Map chứa dữ liệu JSON.
   * @return Đối tượng User.
   */
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '', // Xử lý null an toàn hơn
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      roles: json['roles'] != null ? List<String>.from(json['roles']) : [], // Xử lý null an toàn hơn
      score: json['score'] as int? ?? 0,
    );
  }

  /**
   * Chuyển đổi đối tượng User thành Map JSON (thường để gửi lên API).
   * @return Map biểu diễn đối tượng User.
   */
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