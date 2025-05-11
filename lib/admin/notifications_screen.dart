import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme.dart';

// --- Models ---
class NotificationInfo {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  bool isRead;

  NotificationInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isRead = false,
  });
}

// --- Main Screen Widget ---
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Dummy Data
  final List<NotificationInfo> _notifications = [
    NotificationInfo(
      id: 'noti1',
      title: 'Another Test Notification!',
      description: "shdhd fbdjsjhhfbjdbsvkhfvdstLorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s wi...",
      timestamp: DateTime(2024, 3, 4, 15, 57),
      isRead: false,
    ),
     NotificationInfo(
      id: 'noti2',
      title: 'Test notifciation title!',
      description: 'sjcbxkxjcbvfhxcv hkcdbvkhbcxmv mcnubvkhbcxlhbv cxkdbvkhbcxvhbcxvhxc. vhbcxjhbv cxkbvxcjkcbvkloncjbvkcbcxvcvmvckjvbvkhcbvcbkhvcxbkhvckchxv vkbxcxnbvkhbcxv cxkbvkhbcxv cxkbvkhbcxvkhbcxvkbvx vkbxcxbvkhcxbkvkcvxnklcbkv',
      timestamp: DateTime(2024, 3, 4, 15, 53),
       isRead: false,
    ),
     NotificationInfo(
      id: 'noti3',
      title: 'xcvc',
      description: 'vcvxcvxcxv',
      timestamp: DateTime(2024, 3, 2, 15, 13),
      isRead: true,
    ),
      NotificationInfo(
      id: 'noti4',
      title: 'scvdcvbc',
      description: 'bvcbvcbvcb',
      timestamp: DateTime(2024, 3, 1, 10, 0),
       isRead: false,
    ),
  ];

  // New function to show preview and mark as read
  void _showNotificationPreview(NotificationInfo notification) {
    if (!mounted) return; // Good practice to check if mounted before async gaps

    // Mark as read immediately
    setState(() {
      notification.isRead = true;
    });

    // Show the preview dialog
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return _NotificationPreviewDialog(notification: notification);
      },
    );

    // Optional: Show a confirmation SnackBar (might be redundant with the preview)
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text("Viewing \"${notification.title}\". Marked as read.")),
    // );
  }

   void _showCreateNotificationDialog() async {
      final result = await showDialog<Map<String, String>>( // Expect title and description strings
         context: context,
         barrierDismissible: false, 
         builder: (BuildContext dialogContext) {
           return const _CreateNotificationDialog();
         },
       );

       if (result != null) {
         final title = result['title']!;
         final description = result['description']!;
         print('--- New Notification (Simple) ---');
         print('Title: $title');
         print('Description: $description');
         // TODO: Send this data to the backend
         // TODO: Add the new notification to the list
         // if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(content: Text("Notification \"$title\" would be sent (dummy).")),
         );
       }
   }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final DateFormat formatter = DateFormat('dd MMM, yyyy hh:mm a');

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Title and Create Button ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Notifications',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.notifications_active_outlined, size: 18),
                label: const Text('Create Notifications'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor, 
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: _showCreateNotificationDialog,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Notifications List ---
          Expanded(
            child: _notifications.isEmpty
                ? const Center(child: Text('No notifications found.'))
                : ListView.separated(
                    itemCount: _notifications.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      final bool isUnread = !notification.isRead;

                      return Card(
                        elevation: 2.0,
                         margin: EdgeInsets.zero, 
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                         color: Colors.white,
                        child: ListTile(
                           contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          leading: CircleAvatar(
                            backgroundColor: theme.primaryColor.withAlpha(25), // ~10% opacity
                            child: Icon(Icons.notifications_outlined, color: theme.primaryColor),
                          ),
                          title: Text(
                            notification.title,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Column(
                             crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                notification.description,
                                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                maxLines: 2, 
                                overflow: TextOverflow.ellipsis,
                              ),
                               const SizedBox(height: 8),
                               Text(
                                 formatter.format(notification.timestamp),
                                 style: TextStyle(color: Colors.grey[500], fontSize: 11),
                               ),
                            ],
                          ),
                          trailing: Tooltip(
                            message: 'View Notification',
                            child: IconButton(
                              icon: Icon(
                                Icons.remove_red_eye_outlined,
                                color: isUnread ? Colors.blueGrey[300] : Colors.grey[400],
                                size: 20,
                              ),
                              splashRadius: 20,
                              onPressed: () => _showNotificationPreview(notification),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}


// --- Create Notification Dialog Widget (Simple Version) ---
class _CreateNotificationDialog extends StatefulWidget {
  const _CreateNotificationDialog();

  @override
  State<_CreateNotificationDialog> createState() => _CreateNotificationDialogState();
}

class _CreateNotificationDialogState extends State<_CreateNotificationDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _sendNotification() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    
    if (title.isEmpty || description.isEmpty) {
       // if (!mounted) return;
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both title and description.'),
           backgroundColor: Colors.redAccent,
           ),
      );
      return;
    }
    Navigator.of(context).pop({
      'title': title,
       'description': description, // Send plain text
    });
  }

  @override
  Widget build(BuildContext context) {
     final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      elevation: 0,
      backgroundColor: Colors.transparent, 
      child: Container(
         constraints: const BoxConstraints(maxWidth: 600), // Smaller width for simple dialog
         decoration: BoxDecoration(
           color: Colors.white, 
           borderRadius: BorderRadius.circular(16.0),
           boxShadow: [
             BoxShadow(
               offset: const Offset(0, 4),
               blurRadius: 20,
               color: Colors.black.withAlpha(25), 
             ),
           ],
         ),
        child: Column(
           mainAxisSize: MainAxisSize.min, 
          children: [
            // --- Dialog Header ---
            Padding(
               padding: const EdgeInsets.fromLTRB(24, 20, 16, 16),
              child: Row(
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                     'Send A Notification To Users',
                     style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                   IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                      splashRadius: 20,
                       onPressed: () => Navigator.of(context).pop(),
                     ),
                ],
              ),
            ),
             const Divider(height: 1, thickness: 0.5),

            // --- Dialog Content ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Field
                  Text('Notification Title', style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter Notification Title',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                       suffixIcon: _titleController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                               tooltip: 'Clear Title',
                               splashRadius: 15,
                               onPressed: () => _titleController.clear(),
                             )
                          : null,
                    ),
                    onChanged: (_) => setState(() {}), 
                  ),
                  const SizedBox(height: 20),

                  // Description Field (Simple Multi-line)
                  Text('Notification Description', style: theme.textTheme.titleSmall?.copyWith(color: Colors.grey[700])),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    maxLines: 5, // Allow multiple lines
                    minLines: 3,
                    textInputAction: TextInputAction.newline, // Suggest newline action
                    decoration: InputDecoration(
                       hintText: 'Enter notification description here...',
                       border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                       contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ],
              ),
            ),

            // --- Dialog Actions ---
             const Divider(height: 1, thickness: 0.5),
             Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
               child: Row(
                 mainAxisAlignment: MainAxisAlignment.end,
                 children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                         backgroundColor: theme.primaryColor,
                         foregroundColor: Colors.white,
                         padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                       ),
                      onPressed: _sendNotification,
                      child: const Text('Send Now'),
                    ),
                 ],
               ),
             ),
          ],
        ),
      ),
    );
  }
}

// --- Notification Preview Dialog ---
class _NotificationPreviewDialog extends StatelessWidget {
  final NotificationInfo notification;

  const _NotificationPreviewDialog({required this.notification});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Notification Preview'),
      contentPadding: const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 0),
      titlePadding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 10.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.title,
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              notification.description,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.fromLTRB(0, 0, 24.0, 16.0),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
 