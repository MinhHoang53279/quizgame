class Category {
  final String id;
  final String name;
  final String? icon; // Tên icon hoặc url nếu backend trả về
  final String? color; // Mã màu hex nếu backend trả về

  Category({
    required this.id,
    required this.name,
    this.icon,
    this.color,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'],
      color: json['color'],
    );
  }
} 