import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:intl/intl.dart'; // For number formatting if needed
import '../theme.dart';

// Model for User Information
class UserInfo {
  final String id;
  final String name;
  final String? avatarUrl; // Can be null
  int points; // Make points modifiable
  final double strength;
  final String email;
  bool isEnabled; // User access status
  String role; // Make role modifiable
  final DateTime accountCreated;
  final int quizPlayed;
  final int questionAnswered;
  final int correctAnswer;
  final int incorrectAnswer;

  UserInfo({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.points,
    required this.strength,
    required this.email,
    required this.isEnabled,
    required this.role,
    required this.accountCreated,
    required this.quizPlayed,
    required this.questionAnswered,
    required this.correctAnswer,
    required this.incorrectAnswer,
  });
}

// Model cho Lịch sử điểm
class PointsHistoryEntry {
  final String description;
  final DateTime date;
  final int pointsChange;

  PointsHistoryEntry({
    required this.description,
    required this.date,
    required this.pointsChange,
  });
}

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSortOption = 'Newest First'; // Default sort
  List<UserInfo> _displayedUsers = []; // Users currently displayed (filtered/sorted)

  // Dữ liệu User giả lập - cập nhật với trường mới
  final List<UserInfo> _dummyUsers = [
    UserInfo(id: 'user1', name: 'Juma', avatarUrl: null, points: 17, strength: 35.14, email: 'juma***@email.com', isEnabled: true, role: 'user', accountCreated: DateTime(2025, 4, 28, 12, 48), quizPlayed: 4, questionAnswered: 37, correctAnswer: 13, incorrectAnswer: 24),
    UserInfo(id: 'user2', name: 'test1', avatarUrl: null, points: 88, strength: 37.50, email: 'test1***@email.com', isEnabled: true, role: 'user', accountCreated: DateTime(2025, 4, 27, 10, 10), quizPlayed: 15, questionAnswered: 150, correctAnswer: 88, incorrectAnswer: 62),
    UserInfo(id: 'user3', name: 'Aliya Khanmammadova', avatarUrl: null, points: 42, strength: 53.33, email: 'aliya***@email.com', isEnabled: true, role: 'user', accountCreated: DateTime(2025, 4, 26, 9, 0), quizPlayed: 8, questionAnswered: 70, correctAnswer: 42, incorrectAnswer: 28),
    UserInfo(id: 'user4', name: 'Bilio', avatarUrl: null, points: 17, strength: 27.78, email: 'bilio***@email.com', isEnabled: true, role: 'user', accountCreated: DateTime(2025, 4, 25, 18, 30), quizPlayed: 5, questionAnswered: 40, correctAnswer: 17, incorrectAnswer: 23),
    UserInfo(id: 'user5', name: 'yash', avatarUrl: null, points: 50, strength: 0.00, email: 'yash***@email.com', isEnabled: true, role: 'user', accountCreated: DateTime(2025, 4, 24, 11, 11), quizPlayed: 10, questionAnswered: 90, correctAnswer: 50, incorrectAnswer: 40),
    UserInfo(id: 'user6', name: 'angel', avatarUrl: null, points: 67, strength: 75.68, email: 'angel***@email.com', isEnabled: true, role: 'user', accountCreated: DateTime(2025, 4, 23, 14, 0), quizPlayed: 12, questionAnswered: 110, correctAnswer: 67, incorrectAnswer: 43),
    UserInfo(id: 'user7', name: 'Admin User', avatarUrl: null, points: 999, strength: 100.0, email: 'admin***@email.com', isEnabled: true, role: 'admin', accountCreated: DateTime(2025, 1, 1, 0, 0), quizPlayed: 1, questionAnswered: 10, correctAnswer: 10, incorrectAnswer: 0),
    UserInfo(id: 'user8', name: 'Disabled User', avatarUrl: null, points: 5, strength: 10.0, email: 'disabled***@email.com', isEnabled: false, role: 'user', accountCreated: DateTime(2025, 4, 20, 8, 0), quizPlayed: 2, questionAnswered: 15, correctAnswer: 5, incorrectAnswer: 10),
    UserInfo(id: 'user9', name: 'Editor Jane', avatarUrl: null, points: 150, strength: 80.0, email: 'editor***@email.com', isEnabled: true, role: 'editor', accountCreated: DateTime(2025, 3, 15, 16, 20), quizPlayed: 20, questionAnswered: 200, correctAnswer: 150, incorrectAnswer: 50),
    UserInfo(id: 'user10', name: 'Top Scorer', avatarUrl: null, points: 5000, strength: 95.5, email: 'top***@email.com', isEnabled: true, role: 'user', accountCreated: DateTime(2025, 2, 10, 10, 0), quizPlayed: 100, questionAnswered: 1000, correctAnswer: 955, incorrectAnswer: 45),
    UserInfo(id: 'user11', name: 'Another User', avatarUrl: null, points: 25, strength: 30.0, email: 'another***@email.com', isEnabled: true, role: 'user', accountCreated: DateTime(2025, 4, 1, 12, 0), quizPlayed: 6, questionAnswered: 50, correctAnswer: 25, incorrectAnswer: 25),
  ];

  // Dữ liệu Lịch sử điểm giả lập 
  final List<PointsHistoryEntry> _dummyPointsHistory = [
    PointsHistoryEntry(description: 'Completed A Quiz', date: DateTime(2025, 4, 28, 16, 38), pointsChange: 3),
    PointsHistoryEntry(description: 'Completed A Quiz', date: DateTime(2025, 4, 28, 15, 12), pointsChange: 5),
    PointsHistoryEntry(description: 'Daily Login Bonus', date: DateTime(2025, 4, 28, 9, 0), pointsChange: 1),
    PointsHistoryEntry(description: 'Completed A Quiz', date: DateTime(2025, 4, 27, 20, 5), pointsChange: 4),
    PointsHistoryEntry(description: 'Points Purchase', date: DateTime(2025, 4, 27, 11, 0), pointsChange: 100), // Example purchase
    PointsHistoryEntry(description: 'Admin Adjustment', date: DateTime(2025, 4, 26, 10, 0), pointsChange: -10), // Example adjustment
  ];

  @override
  void initState() {
    super.initState();
    _displayedUsers = List.from(_dummyUsers); // Initialize displayed users
    _searchController.addListener(_filterUsers); // Add listener for search
    _sortUsers(); // Apply initial sort
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUsers);
    _searchController.dispose();
    super.dispose();
  }

  // --- Filtering Logic ---
  void _filterUsers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _displayedUsers = _dummyUsers.where((user) {
        return user.name.toLowerCase().contains(query);
        // Add other fields to search if needed (e.g., email)
        // || user.email.toLowerCase().contains(query) 
      }).toList();
      _sortUsers(); // Re-apply sort after filtering
    });
  }

  // --- Sorting Logic ---
  void _sortUsers() {
    // Important: Sorting modifies the list in place.
    _displayedUsers.sort((a, b) {
      switch (_selectedSortOption) {
        case 'Oldest First': 
          return a.accountCreated.compareTo(b.accountCreated); // Sort by creation date
        case 'Top Rank': // Sort by points descending
          return b.points.compareTo(a.points);
        case 'Low Rank': // Sort by points ascending
          return a.points.compareTo(b.points);
        case 'Disabled': // Show disabled first
          if (!a.isEnabled && b.isEnabled) return -1;
          if (a.isEnabled && !b.isEnabled) return 1;
          return a.name.compareTo(b.name); // Secondary sort by name
         case 'Admins': // Show admins first
           if (a.role == 'admin' && b.role != 'admin') return -1;
           if (a.role != 'admin' && b.role == 'admin') return 1;
           return a.name.compareTo(b.name);
         case 'Editors': // Show editors first
           if (a.role == 'editor' && b.role != 'editor') return -1;
           if (a.role != 'editor' && b.role == 'editor') return 1;
           return a.name.compareTo(b.name);
        case 'Newest First': // Default or explicitly chosen
        default:
           return b.accountCreated.compareTo(a.accountCreated); // Sort by creation date descending
      }
    });
    // setState is needed if called directly, but usually filter/select calls setState
    // setState(() {}); 
  }

  // --- Action Handlers ---
  void _copyUserId(String userId) {
    Clipboard.setData(ClipboardData(text: userId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('User ID copied to clipboard!')),
    );
  }

  // Updated to call the dialog
  void _viewUserInfo(UserInfo user) {
     _showUserInfoDialog(user);
  }

  // --- Edit Role ---
  void _editUserRole(UserInfo user) async {
    final String? newRole = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return _EditUserRoleDialog(user: user);
      },
    );

    if (newRole != null && newRole != user.role) {
      setState(() {
        // Update in the original list
        final originalUserIndex = _dummyUsers.indexWhere((u) => u.id == user.id);
        if (originalUserIndex != -1) {
          _dummyUsers[originalUserIndex].role = newRole;
        }
        // Update the displayed user directly
        user.role = newRole;
        // Optionally re-sort if sorting depends on role
        if (_selectedSortOption == 'Admins' || _selectedSortOption == 'Editors') {
             _sortUsers();
        }
      });
       // TODO: Add API call to update role on backend
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Updated ${user.name}'s role to $newRole (dummy).")),
      );
    }
  }

  // --- Edit Points ---
   void _editUserPoints(UserInfo user) async {
      final int? newPoints = await showDialog<int>(
        context: context,
        builder: (BuildContext dialogContext) {
          return _EditUserPointsDialog(user: user);
        },
      );

      if (newPoints != null && newPoints != user.points) {
         setState(() {
            // Update in the original list
            final originalUserIndex = _dummyUsers.indexWhere((u) => u.id == user.id);
            if (originalUserIndex != -1) {
              _dummyUsers[originalUserIndex].points = newPoints;
            }
            // Update the displayed user directly
            user.points = newPoints;
             // Optionally re-sort if sorting depends on points
             if (_selectedSortOption == 'Top Rank' || _selectedSortOption == 'Low Rank') {
                _sortUsers();
             }
         });
          // TODO: Add API call to update points on backend
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text("Updated ${user.name}'s points to $newPoints (dummy).")),
          );
      }
   }


  Future<bool> _showDisableConfirmationDialog(String userName) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Disable User?'),
          content: Text('Are you sure you want to disable user "$userName"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Disable'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false; // Return false if dialog is dismissed
  }

  void _toggleUserAccess(UserInfo user, bool newValue) async {
     bool confirm = true;
     if (newValue == false) { // Only confirm when disabling
       confirm = await _showDisableConfirmationDialog(user.name);
     }

     if (confirm) {
       setState(() {
          // Find the user in the original list and update
         final originalUserIndex = _dummyUsers.indexWhere((u) => u.id == user.id);
         if (originalUserIndex != -1) {
           _dummyUsers[originalUserIndex].isEnabled = newValue;
         }
         // Also update the currently displayed user object directly
         user.isEnabled = newValue; 
         _filterUsers(); // Re-filter/sort to reflect change if needed by sort option
       });
       // TODO: Add API call to update user status on backend
       print('User ${user.name} access toggled to $newValue');
        ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('User ${user.name} access set to ${newValue ? "Enabled" : "Disabled"} (dummy)!')),
       );
     }
  }

  // --- Hàm hiển thị Dialog thông tin User --- 
  Future<void> _showUserInfoDialog(UserInfo user) async {
    // TODO: Fetch detailed user data here if needed, especially points history
    // For now, we use the dummy history for all users
    final pointsHistory = this._dummyPointsHistory; 

    await showDialog(
      context: context,
      // barrierDismissible: false, // Allow dismissing by clicking outside
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: _UserInfoDialogContent(user: user, pointsHistory: pointsHistory),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const headerColor = Color(0xFF6A1B9A); // Sidebar color for header consistency

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Title and Controls Row ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Users',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  // Search Field
                  SizedBox(
                    width: 250, // Adjust width as needed
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name...',
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              tooltip: 'Clear Search',
                              splashRadius: 18,
                              onPressed: () {
                                _searchController.clear();
                                // Filtering happens via listener
                              },
                            )
                          : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                         focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0), // Adjust padding
                        isDense: true, // Make it more compact
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Sort Button
                  PopupMenuButton<String>(
                    tooltip: 'Sort Users',
                    onSelected: (String result) {
                      setState(() {
                        _selectedSortOption = result;
                        _sortUsers(); // Sort the currently displayed users
                      });
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(value: 'Newest First', child: Text('Newest First')),
                      const PopupMenuItem<String>(value: 'Oldest First', child: Text('Oldest First')),
                       const PopupMenuDivider(),
                      const PopupMenuItem<String>(value: 'Top Rank', child: Text('Top Rank (Points)')),
                      const PopupMenuItem<String>(value: 'Low Rank', child: Text('Low Rank (Points)')),
                       const PopupMenuDivider(),
                       const PopupMenuItem<String>(value: 'Disabled', child: Text('Disabled First')),
                      const PopupMenuItem<String>(value: 'Admins', child: Text('Admins First')),
                      const PopupMenuItem<String>(value: 'Editors', child: Text('Editors First')),
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), 
                      decoration: BoxDecoration(
                         color: Colors.grey[100], 
                         borderRadius: BorderRadius.circular(8),
                         border: Border.all(color: Colors.grey[300]!)
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sort, size: 18, color: Colors.black87),
                          const SizedBox(width: 8),
                          Text('Sort By - $_selectedSortOption', style: const TextStyle(color: Colors.black87)),
                          const Icon(Icons.arrow_drop_down, color: Colors.black54), 
                        ],
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),

          // --- Data Table --- 
          Expanded(
            child: Container(
              width: double.infinity,
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(8),
                 border: Border.all(color: Colors.grey[300]!),
                 boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1))],
               ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical, // Allow vertical scroll if needed
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Always allow horizontal scroll for wide tables
                  child: DataTable(
                      headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey[50]),
                      headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 13),
                      columnSpacing: 30.0,
                      dataRowMinHeight: 56.0,
                      dataRowMaxHeight: 64.0, // Allow slightly more height for content
                      columns: const <DataColumn>[
                        DataColumn(label: Text('Name')),
                        DataColumn(label: Text('Points'), numeric: true),
                        DataColumn(label: Text('Strength'), numeric: true),
                        DataColumn(label: Text('Email')),
                        DataColumn(label: Text('User Access')),
                        DataColumn(label: Text('Role')),
                        DataColumn(label: Text('Actions')),
                      ],
                      rows: _displayedUsers.map((user) {
                        // Simple email masking
                        String maskedEmail = '*******';
                        if (user.email.contains('@')) {
                          maskedEmail += user.email.substring(user.email.indexOf('@'));
                        }

                        return DataRow(
                          cells: <DataCell>[
                            // Name Cell (Avatar + Text)
                            DataCell(
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: Colors.grey[200],
                                    backgroundImage: user.avatarUrl != null 
                                        ? NetworkImage(user.avatarUrl!) // Use NetworkImage for URLs
                                        : null, // Fallback to default icon/letter
                                    child: user.avatarUrl == null 
                                        ? Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?')
                                        : null, 
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(child: Text(user.name, overflow: TextOverflow.ellipsis)),
                                ],
                              )
                            ),
                            // Points
                            DataCell(Text(NumberFormat.compact().format(user.points))), // Compact format
                            // Strength
                            DataCell(Text('${user.strength.toStringAsFixed(2)}%')), // Format as percentage
                            // Email (Masked)
                            DataCell(Text(maskedEmail)),
                            // User Access (Switch)
                            DataCell(
                              Transform.scale( // Make switch slightly smaller
                                scale: 0.8,
                                child: Switch(
                                  value: user.isEnabled,
                                  onChanged: (newValue) => _toggleUserAccess(user, newValue),
                                  activeColor: Colors.green,
                                  // inactiveThumbColor: Colors.redAccent,
                                ),
                              )
                             ),
                            // Role
                            DataCell(Text(user.role, style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey[700]))),
                            // Actions Cell
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                   _actionButton(icon: Icons.copy_outlined, tooltip: 'Copy User ID', color: Colors.blueGrey, onPressed: () => _copyUserId(user.id)),
                                   const SizedBox(width: 6),
                                   _actionButton(icon: Icons.visibility_outlined, tooltip: 'View User Info', color: Colors.blue, onPressed: () => _viewUserInfo(user)),
                                   const SizedBox(width: 6),
                                   _actionButton(icon: Icons.manage_accounts_outlined, tooltip: 'Edit User Role', color: Colors.orange, onPressed: () => _editUserRole(user)),
                                   const SizedBox(width: 6),
                                   _actionButton(icon: Icons.edit, tooltip: 'Edit User Points', color: Colors.purple, onPressed: () => _editUserPoints(user)),
                                  // Add more actions if needed
                                ],
                              )
                            ),
                          ],
                        );
                      }).toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // --- Pagination Controls --- 
          // TODO: Implement actual pagination logic
           Padding(
             padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
             child: Row(
               children: [
                 // Replace with actual pagination state
                 Text('Showing 1–${_displayedUsers.length} of ${_dummyUsers.length}', style: TextStyle(color: Colors.grey[600])), 
                 const Spacer(), 
                 IconButton(
                   icon: const Icon(Icons.chevron_left),
                   onPressed: null, // Disabled for now
                   tooltip: 'Previous Page',
                   splashRadius: 20,
                   iconSize: 24,
                 ),
                 const SizedBox(width: 8), 
                 IconButton(
                   icon: const Icon(Icons.chevron_right),
                   onPressed: null, // Disabled for now
                   tooltip: 'Next Page',
                   splashRadius: 20,
                   iconSize: 24,
                 ),
               ],
             ),
           ), 
        ],
      ),
    );
  }

  // Helper widget for action buttons in the table
  Widget _actionButton({required IconData icon, required String tooltip, required Color color, required VoidCallback onPressed}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.all(7), 
          decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Icon(icon, size: 19, color: color)
        ),
      ),
    );
  }

} // <<< Đóng class _UsersScreenState >>>

// --- Widget nội dung Dialog thông tin User --- 
class _UserInfoDialogContent extends StatelessWidget {
  final UserInfo user;
  final List<PointsHistoryEntry> pointsHistory;

  // Sửa constructor
  const _UserInfoDialogContent({super.key, required this.user, required this.pointsHistory});

  // Helper để tạo các chip thống kê
  Widget _buildStatChip(String label, String value) {
    return Chip(
      label: Text('$label: $value'),
      backgroundColor: Colors.white.withOpacity(0.9),
      labelStyle: const TextStyle(fontSize: 12, color: Colors.black87),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    );
  }

  // Helper để tạo dòng lịch sử điểm
  Widget _buildHistoryTile(PointsHistoryEntry entry) {
    final DateFormat formatter = DateFormat('MM/dd/yyyy hh:mm a');
    final bool isPositive = entry.pointsChange >= 0;
    final String pointsPrefix = isPositive ? '+' : '';

    return ListTile(
      dense: true,
      leading: Icon(Icons.history_toggle_off, color: Colors.grey[600], size: 20),
      title: Text(entry.description, style: const TextStyle(fontSize: 14)),
      subtitle: Text(formatter.format(entry.date), style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isPositive ? Colors.blue.withOpacity(0.8) : Colors.red.withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '$pointsPrefix${entry.pointsChange}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 2, horizontal: 0), // Adjust padding
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DateFormat accountFormatter = DateFormat('MM/dd/yyyy hh:mm a');
    String maskedEmail = '*******';
     if (user.email.contains('@')) {
        maskedEmail += user.email.substring(user.email.indexOf('@'));
      }

    return Container(
      constraints: const BoxConstraints(maxWidth: 550), // Giới hạn chiều rộng dialog
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 20,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Để dialog co lại theo nội dung
        children: [
          // --- Phần Header màu tím --- 
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: const Color(0xFF6A1B9A).withOpacity(0.9), // Màu tím header
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none, // Allow overflow for close button
              alignment: Alignment.center,
              children: [
                Column(
                  children: [
                     CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.white.withOpacity(0.8),
                      backgroundImage: user.avatarUrl != null 
                          ? NetworkImage(user.avatarUrl!) 
                          : null,
                      child: user.avatarUrl == null 
                          ? Text(
                              user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                              style: TextStyle(fontSize: 36, color: theme.primaryColor.withOpacity(0.7)),
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      user.name,
                      style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      maskedEmail,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white.withOpacity(0.8)),
                    ),
                     const SizedBox(height: 6),
                    Text(
                      'Account Created: ${accountFormatter.format(user.accountCreated)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.white.withOpacity(0.7), fontSize: 11),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildStatChip('Points', user.points.toString()),
                        _buildStatChip('Strength', '${user.strength.toStringAsFixed(2)}%'),
                        _buildStatChip('Quiz Played', user.quizPlayed.toString()),
                        _buildStatChip('Question Answered', user.questionAnswered.toString()),
                        _buildStatChip('Correct Answer', user.correctAnswer.toString()),
                        _buildStatChip('Incorrect Answer', user.incorrectAnswer.toString()),
                      ],
                    )
                  ],
                ),
                // Nút đóng dialog
                 Positioned(
                   top: -10,
                   right: -10,
                   child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                       elevation: 2,
                       child: InkWell(
                         onTap: () => Navigator.of(context).pop(),
                         customBorder: const CircleBorder(),
                         child: const Padding(
                           padding: EdgeInsets.all(5.0),
                           child: Icon(Icons.close, size: 20, color: Colors.black54),
                         ),
                       ),
                   ),
                 ), 
              ],
            ),
          ),
          
          // --- Phần Lịch sử điểm (Scrollable) --- 
          Padding(
             padding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                  Text(
                     'Points History',
                     style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  pointsHistory.isEmpty
                    ? const Text('No points history available.')
                    : ConstrainedBox( // Giới hạn chiều cao của ListView
                        constraints: const BoxConstraints(maxHeight: 200), 
                        child: ListView.separated(
                          shrinkWrap: true, // Quan trọng khi lồng ListView
                          itemCount: pointsHistory.length,
                          itemBuilder: (context, index) => _buildHistoryTile(pointsHistory[index]),
                          separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
                        ),
                      ),
               ],
             ),
          ),
        ],
      ),
    );
  }
}

// --- Dialog chỉnh sửa vai trò ---
class _EditUserRoleDialog extends StatefulWidget {
  final UserInfo user;

  const _EditUserRoleDialog({required this.user});

  @override
  State<_EditUserRoleDialog> createState() => _EditUserRoleDialogState();
}

class _EditUserRoleDialogState extends State<_EditUserRoleDialog> {
  late String _selectedRole;
  final List<String> _availableRoles = ['user', 'editor', 'admin']; // Define available roles

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.user.role; // Initialize with current role
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Role for ${widget.user.name}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select new role:'),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedRole,
            items: _availableRoles.map((String role) {
              return DropdownMenuItem<String>(
                value: role,
                child: Text(role),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedRole = newValue;
                });
              }
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(null), // Return null on cancel
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('Save Role'),
          onPressed: () {
             // TODO: Add confirmation dialog maybe?
             Navigator.of(context).pop(_selectedRole); // Return the selected role
          },
        ),
      ],
    );
  }
}

// --- Dialog chỉnh sửa điểm ---
class _EditUserPointsDialog extends StatefulWidget {
  final UserInfo user;

  const _EditUserPointsDialog({required this.user});

  @override
  State<_EditUserPointsDialog> createState() => _EditUserPointsDialogState();
}

class _EditUserPointsDialogState extends State<_EditUserPointsDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _pointsController;

  @override
  void initState() {
    super.initState();
    _pointsController = TextEditingController(text: widget.user.points.toString());
  }

  @override
  void dispose() {
     _pointsController.dispose();
     super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Points for ${widget.user.name}'),
      content: Form(
        key: _formKey,
        child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             Text('Current Points: ${widget.user.points}'),
             const SizedBox(height: 16),
             TextFormField(
                controller: _pointsController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly // Allow only digits
                ],
                decoration: const InputDecoration(
                  labelText: 'New Points',
                  border: OutlineInputBorder(),
                  hintText: 'Enter the total points',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter points';
                  }
                  final points = int.tryParse(value);
                  if (points == null) {
                    return 'Please enter a valid number';
                  }
                  if (points < 0) { // Basic validation
                     return 'Points cannot be negative';
                  }
                  return null; // Return null if valid
                },
             ),
           ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(null), // Return null on cancel
        ),
        ElevatedButton(
           style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
          child: const Text('Update Points'),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final newPoints = int.parse(_pointsController.text);
               // TODO: Add confirmation dialog maybe?
              Navigator.of(context).pop(newPoints); // Return the new points value
            }
          },
        ),
      ],
    );
  }
} 