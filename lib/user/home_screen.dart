import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/providers/user_provider.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  @override
  Widget build(BuildContext context) {
    // Define colors (có thể chuyển vào Theme sau)
    const Color primaryColor = Color(0xFF6A1B9A);
    const Color cardRed = Color(0xFFEF5350);
    const Color cardBlue = Color(0xFF42A5F5);
    const Color cardGreen = Color(0xFF66BB6A);
    const Color cardYellow = Color(0xFFFFCA28);
    const Color cardDarkBlue = Color(0xFF1E88E5);
    const Color cardLightGreen = Color(0xFF9CCC65);
    const Color cardOrange = Color(0xFFFFA726);
    const Color cardLime = Color(0xFFD4E157);

    // Lấy UserProvider và userName
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String userName = userProvider.currentUser?.fullName ?? 'Loading...';
    final String userInitial = userProvider.currentUser?.fullName?.isNotEmpty == true
        ? userProvider.currentUser!.fullName![0].toUpperCase()
        : 'G';

    return Scaffold(
      // AppBar vẫn giữ nguyên cấu trúc hiện tại
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder( // Use Builder to get context for Scaffold.of(context).openDrawer()
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white), // Changed icon
            tooltip: 'Menu',
            onPressed: () => Scaffold.of(context).openDrawer(), // Mở Drawer
          ),
        ),
        title: Text(
          'DTQUIZ',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            tooltip: 'Notifications',
            onPressed: () { /* TODO: Handle notification tap */ },
          ),
          const SizedBox(width: 8),
        ],
      ),
      // Drawer giữ nguyên
      drawer: _buildDrawer(context),
      // Extend body behind app bar for seamless gradient
      extendBodyBehindAppBar: true,
      // Body được xây dựng lại
      body: _buildBody(context, userName, userInitial, cardRed, cardBlue, cardGreen, cardYellow, cardDarkBlue, cardLightGreen, cardOrange, cardLime),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    // Drawer giữ nguyên logic
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(user?.fullName ?? 'Guest', style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(user?.email ?? 'Not logged in'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.fullName?.isNotEmpty == true ? user!.fullName![0].toUpperCase() : 'G',
                style: TextStyle(fontSize: 40.0, color: Theme.of(context).primaryColor),
              ),
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context); // Đóng Drawer
            },
          ),
          ListTile(
            leading: const Icon(Icons.leaderboard_outlined),
            title: const Text('Leaderboard'),
            onTap: () {
              // TODO: Navigate to Leaderboard screen
              Navigator.pop(context);
              print('Navigate to Leaderboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              // TODO: Navigate to Profile screen
              Navigator.pop(context);
              print('Navigate to Profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Settings'),
            onTap: () {
              // TODO: Navigate to Settings screen
              Navigator.pop(context);
               print('Navigate to Settings');
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Create Question'),
            onTap: () {
              Navigator.pop(context); // Đóng Drawer
              Navigator.pushNamed(context, '/create_question'); // Điều hướng
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await userProvider.logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
            },
          ),
        ],
      ),
    );
  }

  // Widget _buildBody MỚI
  Widget _buildBody(BuildContext context, String userName, String userInitial, Color cardRed, Color cardBlue, Color cardGreen, Color cardYellow, Color cardDarkBlue, Color cardLightGreen, Color cardOrange, Color cardLime) {
    // Nền gradient
    final backgroundDecoration = BoxDecoration(
      gradient: LinearGradient(
        colors: [
          const Color(0xFF6A1B9A),
          const Color(0xFF8E24AA),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    );

    // Lấy TextTheme
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: backgroundDecoration,
      // Sử dụng SafeArea để tránh nội dung bị che bởi notch/statusbar
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          children: [
            // --- Welcome Section ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back,',
                      style: textTheme.titleMedium?.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName,
                      style: textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    userInitial,
                    style: textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // --- Featured Section: Daily Quiz ---
            _buildFeaturedCard(
              context: context,
              title: 'Daily Quiz',
              subtitle: 'Test your knowledge daily!',
              buttonText: 'Start Now',
              icon: Icons.event_note_outlined,
              color: cardLightGreen,
              onTap: () {
                /* TODO: Navigate to Daily Quiz */ print('Daily Quiz Tapped');
              },
            ),
            const SizedBox(height: 30),

            // --- Main Categories Section ---
            Text(
              'Explore Quizzes',
              style: textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 15),

            // Dùng ListView hoặc Column thay thế Grid cũ
            _buildCategoryItem(
              context: context,
              title: 'Practice Mode',
              subtitle: 'Sharpen your skills',
              icon: Icons.edit_note_outlined,
              color: cardBlue,
              onTap: () {
                Navigator.pushNamed(context, '/practice');
              },
            ),
            _buildCategoryItem(
              context: context,
              title: 'Contests',
              subtitle: 'Compete with others',
              icon: Icons.emoji_events_outlined,
              color: cardRed,
              onTap: () {
                /* TODO: Navigate to Contest list */ print('Contest Tapped');
              },
            ),
            _buildCategoryItem(
              context: context,
              title: 'Upcoming Contests',
              subtitle: 'See what\'s next',
              icon: Icons.calendar_today_outlined,
              color: cardGreen,
              onTap: () {
                 /* TODO: Navigate to Upcoming Contest */ print('Upcoming Contest Tapped');
              },
            ),
             _buildCategoryItem(
              context: context,
              title: 'True/False',
              subtitle: 'Quick yes or no questions',
              icon: Icons.check_circle_outline,
              color: cardLime,
              onTap: () {
                 /* TODO: Navigate to True/False */ print('True-False Tapped');
              },
            ),
            _buildCategoryItem(
              context: context,
              title: 'Audio & Video Quiz',
              subtitle: 'Listen or watch to answer',
              icon: Icons.graphic_eq_outlined, // Có thể đổi icon phù hợp hơn
              color: cardOrange, // Gộp Audio & Video
              onTap: () {
                 /* TODO: Navigate to Audio/Video Quiz */ print('Audio/Video Quiz Tapped');
              },
            ),
            // Bỏ các Card riêng lẻ cho Audio, Video, General Quiz nếu đã gộp hoặc không cần
            // _buildCategoryItem(context: context, title: 'General Quiz', ... ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Helper Widget mới cho Card nổi bật
  Widget _buildFeaturedCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String buttonText,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      color: color,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.9)),
                    ),
                    const SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: color,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: Text(buttonText, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Icon(icon, size: 60, color: Colors.white.withOpacity(0.8)),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget mới cho các mục danh sách
  Widget _buildCategoryItem({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        leading: CircleAvatar(
          radius: 25,
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(title, style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }

  // Widget _buildActionCard cũ không còn dùng nữa, có thể xóa bỏ
  // Widget _buildActionCard(...) { ... }
} 