import 'package:flutter/material.dart';
import '../data/models/category.dart';
import '../data/services/category_service.dart';
import '../theme.dart';

class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: CategoryService().getCategories(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: \\${snapshot.error}'));
        }
        final categories = snapshot.data ?? [];
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            return ListTile(
              leading: Icon(Icons.category, color: AppTheme.primaryColor),
              title: Text(cat.name),
              onTap: () {
                // TODO: Chuyển sang màn hình quiz theo category
              },
            );
          },
        );
      },
    );
  }
} 