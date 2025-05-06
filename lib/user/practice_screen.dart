import 'package:flutter/material.dart';

// Lớp mô hình đơn giản cho danh mục luyện tập (dummy data)
class PracticeCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const PracticeCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  // Danh sách dữ liệu mẫu
  final List<PracticeCategory> _dummyCategories = const [
    PracticeCategory(id: '1', name: 'General Knowledge', icon: Icons.public, color: Colors.blue),
    PracticeCategory(id: '2', name: 'Science: Computers', icon: Icons.computer, color: Colors.green),
    PracticeCategory(id: '3', name: 'History', icon: Icons.history_edu, color: Colors.orange),
    PracticeCategory(id: '4', name: 'Geography', icon: Icons.map, color: Colors.purple),
    PracticeCategory(id: '5', name: 'Sports', icon: Icons.sports_soccer, color: Colors.red),
    PracticeCategory(id: '6', name: 'Movies', icon: Icons.movie, color: Colors.teal),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Practice Topics'), // Đổi title
        backgroundColor: Theme.of(context).primaryColor, // Match home screen theme
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10.0), // Thêm padding
        itemCount: _dummyCategories.length,
        itemBuilder: (context, index) {
          final category = _dummyCategories[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(vertical: 6.0), // Thêm margin
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: category.color,
                child: Icon(category.icon, color: Colors.white),
              ),
              title: Text(category.name, style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Điều hướng đến màn hình QuizPlayScreen với category được chọn
                Navigator.pushNamed(
                  context,
                  '/quiz_play', 
                  arguments: category // Truyền category qua arguments
                );
                print('Selected category: ${category.name} (ID: ${category.id})');
                // SnackBar có thể giữ lại hoặc bỏ đi tùy ý
                // ScaffoldMessenger.of(context).showSnackBar(...);
              },
            ),
          );
        },
      ),
    );
  }
} 