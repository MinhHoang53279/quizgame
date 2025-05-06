import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/providers/admin_dashboard_provider.dart';
import '../data/providers/user_provider.dart'; // For logout
import '../data/models/admin_dtos.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'categories_screen.dart'; // Import the new screen
import 'quizzes_screen.dart'; // Import Quizzes Screen
import 'questions_screen.dart'; // Import QuestionsScreen
import 'featured_screen.dart'; // <<< THÊM IMPORT
import 'users_screen.dart'; // <<< THÊM IMPORT
import 'notifications_screen.dart'; // <<< THÊM IMPORT CHO NOTIFICATIONS >>>
import 'settings_screen.dart'; // <<< ADD IMPORT FOR SETTINGS >>>
// Import chart library if you start implementing charts
// import 'package:fl_chart/fl_chart.dart'; 

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0; // Track selected index for NavigationRail

  @override
  void initState() {
    super.initState();
    // Fetch data when the screen loads, without blocking the build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AdminDashboardProvider>(context, listen: false)
          .fetchAdminData();
    });
  }

 // Placeholder widget for content pages
  Widget _buildContentPage(int index) {
     final adminProvider = Provider.of<AdminDashboardProvider>(context, listen: false);
     final summary = adminProvider.summaryData;

     // Return different content based on index
     switch (index) {
       case 0: // Dashboard
         return _buildDashboardContent(adminProvider, summary);
       case 1: // Categories
         return const CategoriesScreen();
       case 2: // Quizzes
         return const QuizzesScreen();
       case 3: // Questions 
         return const QuestionsScreen();
       case 4: // Featured 
         return const FeaturedScreen(); 
       case 5: // Users
         return const UsersScreen(); 
       case 6: // Notifications
         return const NotificationsScreen();
       case 7: // Settings
          // return const Center(child: Text('Settings Page - Coming Soon!')); // Replace placeholder
         return const SettingsScreen(); // <<< SHOW SETTINGS SCREEN >>>
       // Handle Ads and License if they are added later
       // case 8: // Ads 
       // case 9: // License
       default:
         return _buildDashboardContent(adminProvider, summary);
     }
  }

  // Extracted dashboard content logic
  Widget _buildDashboardContent(AdminDashboardProvider adminProvider, DashboardSummaryDTO? summary) {
     return RefreshIndicator(
      onRefresh: () => adminProvider.fetchAdminData(),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // --- Summary Cards Row ---
          _buildSummaryCardsRow(summary),
          const SizedBox(height: 20),
          // --- Charts Row ---
          _buildChartsRow(),
          const SizedBox(height: 20),
          // --- Recent Activity / Top Users Row (Example) ---
          _buildBottomRow(summary),
          // You might remove the _buildSection for Recent Activity here
          // if you display it elsewhere or differently.
        ],
      ),
    );
  }

  // --- Reusable UI Building Blocks (Matching the Target UI) ---

  // Builds the row of summary cards
  Widget _buildSummaryCardsRow(DashboardSummaryDTO? summary) {
    // Placeholder data for missing items
    const categoryCount = 12;
    const questionCount = 120;
    const purchaseCount = 13;
    const notificationCount = 4;

    return Wrap(
      spacing: 16.0, // Horizontal space between cards
      runSpacing: 16.0, // Vertical space between rows of cards
      alignment: WrapAlignment.start,
      children: [
        _buildStyledSummaryCard(context,
            icon: Icons.people_alt_outlined,
            title: 'Total Users',
            value: summary?.users.total.toString() ?? '0', 
            color: Colors.blue), 
        _buildStyledSummaryCard(context,
            icon: Icons.category_outlined,
            title: 'Total Categories',
            value: categoryCount.toString(),
            color: Colors.orange),
        _buildStyledSummaryCard(context,
            icon: Icons.quiz_outlined, 
            title: 'Total Quizzes',
            value: summary?.quizzes.total.toString() ?? '0',
            color: Colors.green),
        _buildStyledSummaryCard(context,
            icon: Icons.question_answer_outlined,
            title: 'Total Questions',
            value: questionCount.toString(),
            color: Colors.purple),
        _buildStyledSummaryCard(context,
            icon: Icons.notifications_outlined,
            title: 'Total Notifications',
            value: notificationCount.toString(),
            color: Colors.teal),
      ],
    );
  }

  // New styled summary card matching the image
  Widget _buildStyledSummaryCard(BuildContext context, 
      {required IconData icon, required String title, required String value, required Color color}) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 180), // Ensure minimum width
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  // Builds the row containing charts (placeholders for now)
  Widget _buildChartsRow() {
    return LayoutBuilder( // Use LayoutBuilder to make it responsive
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 600; // Example breakpoint
        return Flex(
          direction: isWide ? Axis.horizontal : Axis.vertical,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              flex: isWide ? 1 : 0, // Equal width on wide screens
              child: Card(
                elevation: 2,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  height: 300,
                  child: const Center(child: Text('Chart: User Registration (Placeholder)')),
                ),
              ),
            ),
            if (isWide) const SizedBox(width: 16) else const SizedBox(height: 16),
            Flexible(
               flex: isWide ? 1 : 0,
               child: Card(
                elevation: 2,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Container(
                   padding: const EdgeInsets.all(16),
                  height: 300,
                  child: const Center(child: Text('Chart: Points Purchases (Placeholder)')),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Builds the bottom row (Recent Activity / Top Users)
  Widget _buildBottomRow(DashboardSummaryDTO? summary) {
     return LayoutBuilder(
      builder: (context, constraints) {
         bool isWide = constraints.maxWidth > 800; // Different breakpoint maybe
         return Flex(
           direction: isWide ? Axis.horizontal : Axis.vertical,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             // Left side: Recent Activity (Optional, could be in Top Users card too)
             // Flexible(...),

             // Right side: Top Users Card Placeholder
            Flexible(
              flex: isWide ? 1 : 0,
              child: Card(
                 elevation: 2,
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                 child: Container(
                   padding: const EdgeInsets.all(16),
                    // Height can be fixed or dynamic based on content
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                         children: [
                            Text('Top Users', style: Theme.of(context).textTheme.titleLarge),
                            TextButton(onPressed: () {}, child: const Text('View All')),
                         ],
                       ),
                       const SizedBox(height: 10),
                       const ListTile(
                         leading: CircleAvatar(child: Text('S')),
                         title: Text('shemoeya kla'),
                         subtitle: Text('Points: 3888'),
                         trailing: Icon(Icons.visibility_outlined, color: Colors.grey),
                       ),
                        const ListTile(
                         leading: CircleAvatar(child: Text('P')),
                         title: Text('patrick07'),
                         subtitle: Text('Points: 3350'),
                         trailing: Icon(Icons.visibility_outlined, color: Colors.grey),
                       ),
                       // Add more placeholder users...
                     ],
                   )
                 ),
               ),
            ),
           ],
         );
      }
     );
  }


  // --- Old Helper Functions (Keep for reference or remove later) ---

  // Helper function to build a summary card (OLD STYLE)
  // Widget _buildSummaryCard(BuildContext context, {required IconData icon, required String title, required String value}) { ... }

  // Helper function to build list sections (OLD STYLE)
  // Widget _buildSection<T>(BuildContext context, String title, List<T> items, Widget Function(T item) itemBuilder) { ... }

  // Show confirmation dialog before deleting
  // Future<bool> _showDeleteConfirmationDialog(BuildContext context, String itemName) async { ... }


  @override
  Widget build(BuildContext context) {
    final adminProvider = Provider.of<AdminDashboardProvider>(context);
    // final userProvider = Provider.of<UserProvider>(context, listen: false); // For logout

    // Define the primary color for the theme
    const sidebarColor = Color(0xFF6A1B9A); // Purple shade from image
    const backgroundColor = Color(0xFFF5F5F5); // Light grey background

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Row(
        children: [
          // --- Navigation Rail ---
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: sidebarColor,
            elevation: 4,
            minWidth: 90, // Increased width for text
            labelType: NavigationRailLabelType.all, // Show labels always
            selectedLabelTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            unselectedLabelTextStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            selectedIconTheme: const IconThemeData(color: Colors.white, size: 28),
            unselectedIconTheme: IconThemeData(color: Colors.white.withOpacity(0.7), size: 24),
            leading: const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'QuizHour', 
                style: TextStyle(
                  color: Colors.white, 
                  fontSize: 22, 
                  fontWeight: FontWeight.bold
                )
              ),
            ),
            destinations: const <NavigationRailDestination>[
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.category_outlined),
                 selectedIcon: Icon(Icons.category),
                label: Text('Categories'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.quiz_outlined),
                 selectedIcon: Icon(Icons.quiz),
                label: Text('Quizzes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.question_answer_outlined),
                 selectedIcon: Icon(Icons.question_answer),
                label: Text('Questions'),
              ),
              // Add other destinations...
              NavigationRailDestination(
                icon: Icon(Icons.star_border),
                 selectedIcon: Icon(Icons.star),
                label: Text('Featured'),
              ),
               NavigationRailDestination(
                icon: Icon(Icons.people_alt_outlined),
                 selectedIcon: Icon(Icons.people_alt),
                label: Text('Users'),
              ),
              // Remove Purchases Destination
              //  NavigationRailDestination(
              //   icon: Icon(Icons.shopping_cart_outlined),
              //    selectedIcon: Icon(Icons.shopping_cart),
              //   label: Text('Purchases'),
              // ),
               NavigationRailDestination(
                icon: Icon(Icons.notifications_outlined),
                 selectedIcon: Icon(Icons.notifications),
                label: Text('Notifications'),
              ),
              // Remove Ads Destination
              //  NavigationRailDestination(
              //   icon: Icon(Icons.ad_units_outlined),
              //    selectedIcon: Icon(Icons.ad_units),
              //   label: Text('Ads'),
              // ),
               NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                 selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          // --- Main Content Area ---
          Expanded(
            child: Column(
              children: [
                // --- Custom Top Bar ---
                _buildTopBar(context),
                // --- Content Based on Selection ---
                Expanded(
                  child: Consumer<AdminDashboardProvider>(
                    builder: (context, provider, child) {
                      if (provider.isLoading && provider.summaryData == null) {
                        return const Center(child: CircularProgressIndicator());
                      } 
                      if (provider.error != null && provider.summaryData == null) {
                        return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                            child: Text('Error: ${provider.error}',
                                    style: const TextStyle(color: Colors.red)),
                          ),
                        );
                      }
                      // Hiển thị trang nội dung dựa trên index đã chọn
                      return _buildContentPage(_selectedIndex); 
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // --- Custom Top Bar Widget ---
  Widget _buildTopBar(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false); // For logout & user info
    final currentUser = userProvider.currentUser; // Assuming UserProvider holds current user info

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'QuizHour - Admin Panel', // Title from image
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          // --- User Profile Dropdown Placeholder ---
          PopupMenuButton<String>(
             tooltip: 'User Options',
             onSelected: (String result) async {
                switch (result) {
                  case 'profile':
                    // TODO: Navigate to profile screen
                    print('Profile selected');
                    break;
                  case 'logout':
                    await userProvider.logout();
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                    }
                    break;
                }
              },
             itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: ListTile(
                     leading: Icon(Icons.person_outline),
                     title: Text('Profile'),
                  ),
                ),
                 const PopupMenuDivider(),
                 PopupMenuItem<String>(
                  value: 'logout',
                  child: ListTile(
                     leading: Icon(Icons.logout, color: Colors.red),
                     title: Text('Logout', style: TextStyle(color: Colors.red)),
                  ),
                ),
              ],
            offset: const Offset(0, 50), // Offset dropdown below icon
            child: Row(
              children: [
                 CircleAvatar(
                  // backgroundColor: Colors.blueGrey, // Or use user image
                  radius: 18,
                  child: Text(
                     currentUser?.username.substring(0, 1).toUpperCase() ?? '?', // First initial
                     style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                       currentUser?.username ?? 'Admin User', // Use actual username if available
                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                     ),
                     Text(
                       currentUser?.roles.join(', ') ?? 'Admin', // Display roles or default
                       style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 