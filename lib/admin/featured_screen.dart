import 'package:flutter/material.dart';
import '../theme.dart';

// Model for Featured Category Data
class FeaturedCategoryInfo {
  final String id;
  final String name;
  final int quizCount;
  final String imageUrl; // URL or asset path

  FeaturedCategoryInfo({
    required this.id,
    required this.name,
    required this.quizCount,
    required this.imageUrl,
  });
}

class FeaturedScreen extends StatefulWidget {
  const FeaturedScreen({super.key});

  @override
  State<FeaturedScreen> createState() => _FeaturedScreenState();
}

class _FeaturedScreenState extends State<FeaturedScreen> {
  // Dummy data - Replace with actual data fetching
  List<FeaturedCategoryInfo> _featuredCategories = [
    FeaturedCategoryInfo(
      id: 'cat_flutter',
      name: 'Learn Flutter',
      quizCount: 4,
      imageUrl: 'https://images.unsplash.com/photo-1607706189992-eae578626c86?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80', // Placeholder image
    ),
    FeaturedCategoryInfo(
      id: 'cat_prog',
      name: 'Programming',
      quizCount: 1,
      imageUrl: 'https://images.unsplash.com/photo-1542831371-29b0f74f9713?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80', // Placeholder image
    ),
    FeaturedCategoryInfo(
      id: 'cat_english',
      name: 'Learn English',
      quizCount: 10,
      imageUrl: 'https://images.unsplash.com/photo-1559094368-8c8a94d8e7e3?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1074&q=80', // Placeholder image
    ),
    // Add more categories if needed
  ];

  // Function to handle removing a featured category
  void _removeFeaturedCategory(String categoryId) {
    setState(() {
      _featuredCategories.removeWhere((category) => category.id == categoryId);
      // TODO: Add API call to update backend
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Category removed from featured (dummy)! ID: $categoryId')),
    );
     print('Remove featured category: $categoryId');
  }

  // --- Show Confirmation Dialog before Removing --- 
  Future<bool?> _showRemoveConfirmationDialog(String categoryId, String categoryName) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            'Remove from featured?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                // <<< Sử dụng categoryName để hiển thị đúng tên >>>
                Text('Do you want to remove "$categoryName" from the featured section?'),
              ],
            ),
          ),
          actionsAlignment: MainAxisAlignment.center, // Center buttons
          actionsPadding: const EdgeInsets.only(bottom: 16.0, top: 0), 
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, // Nút Yes màu đỏ
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(dialogContext).pop(true); // Return true when Yes is pressed
              },
            ),
            const SizedBox(width: 10),
            ElevatedButton(
               style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A1B9A), // Nút No màu tím
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('No'),
              onPressed: () {
                Navigator.of(dialogContext).pop(false); // Return false when No is pressed
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Title --- 
          Text(
            'Featured Categories',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),

          // --- Category Cards Grid --- 
          Expanded(
            child: _featuredCategories.isEmpty
              ? const Center(child: Text('No featured categories yet.'))
              : Wrap(
                  spacing: 20.0, // Khoảng cách ngang giữa các card
                  runSpacing: 20.0, // Khoảng cách dọc giữa các hàng card
                  children: _featuredCategories
                      .map((category) => _FeaturedCategoryCard(
                            category: category,
                            onRemove: () async { 
                              final bool? confirmed = await _showRemoveConfirmationDialog(category.id, category.name);
                              if (confirmed == true) {
                                // Chỉ xóa nếu người dùng xác nhận
                                _removeFeaturedCategory(category.id);
                              }
                            },
                          ))
                      .toList(),
                ), 
          ),
           const SizedBox(height: 16), 
            // TODO: Add button to select new categories to feature?
        ],
      ),
    );
  }
}

// --- Custom Widget for Category Card ---
class _FeaturedCategoryCard extends StatelessWidget {
  final FeaturedCategoryInfo category;
  final VoidCallback onRemove;

  const _FeaturedCategoryCard({required this.category, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300, // Fixed width for the card
      height: 180, // Fixed height for the card
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            Image.network(
              category.imageUrl,
              fit: BoxFit.cover,
              // Optional: Add loading/error builders for better UX
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.broken_image, color: Colors.grey, size: 40)),
                );
              },
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.4, 1.0], // Adjust stops for gradient effect
                ),
              ),
            ),
            // Text Content
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 2.0, color: Colors.black54)], // Text shadow
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    'Quiz Count: ${category.quizCount}',
                    style: TextStyle(
                      fontSize: 13.0,
                      color: Colors.white.withOpacity(0.9),
                      shadows: const [Shadow(blurRadius: 1.0, color: Colors.black45)],
                    ),
                  ),
                ],
              ),
            ),
            // Remove Button
            Positioned(
              top: 8.0,
              right: 8.0,
              child: Material(
                color: Colors.black.withOpacity(0.4), // Semi-transparent background
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onRemove,
                  customBorder: const CircleBorder(),
                  splashColor: Colors.white.withOpacity(0.3),
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18.0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 