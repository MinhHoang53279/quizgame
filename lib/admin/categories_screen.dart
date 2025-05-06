import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import image_picker
import 'dart:io'; // Needed for File type if used, or just use XFile

// Placeholder model for Category data
class Category {
  final String id;
  final String name;
  final int quizCount;
  final String imageUrl; // Placeholder for background image

  const Category({
    required this.id,
    required this.name,
    required this.quizCount,
    required this.imageUrl,
  });
}

// Convert to StatefulWidget to handle dialogs potentially needing state later
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // Make the list mutable for reordering
  late List<Category> _reorderableCategories;

  @override
  void initState() {
    super.initState();
    // Initialize the mutable list from the dummy data
    _reorderableCategories = List<Category>.from(_dummyCategories);
  }

  // Dummy data for categories (Keep the original const list for initialization)
  final List<Category> _dummyCategories = const [
    Category(id: '1', name: 'Learn Flutter', quizCount: 4, imageUrl: 'assets/images/placeholder.png'), 
    Category(id: '2', name: 'Learn English', quizCount: 10, imageUrl: 'assets/images/placeholder.png'),
    Category(id: '3', name: 'Religion', quizCount: 0, imageUrl: 'assets/images/placeholder.png'),
    Category(id: '4', name: 'Technology', quizCount: 3, imageUrl: 'assets/images/placeholder.png'),
    Category(id: '5', name: 'Entertainment', quizCount: 0, imageUrl: 'assets/images/placeholder.png'),
    Category(id: '6', name: 'Programming', quizCount: 1, imageUrl: 'assets/images/placeholder.png'),
    Category(id: '7', name: 'Sports', quizCount: 1, imageUrl: 'assets/images/placeholder.png'),
    Category(id: '8', name: 'Academic', quizCount: 0, imageUrl: 'assets/images/placeholder.png'),
    // Add more dummy data as needed
  ];

  // --- Dialog Functions ---

  Future<void> _showEditCategoryDialog(BuildContext context, Category category) async {
    final nameController = TextEditingController(text: category.name);
    // Keep the controller for potential display, but primary interaction is via picker
    final imagePathController = TextEditingController(text: category.imageUrl);
    XFile? pickedImageFile; // Variable to hold the picked image file

    final formKey = GlobalKey<FormState>();
    const primaryColor = Color(0xFF6A1B9A);
    final ImagePicker picker = ImagePicker();

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use StatefulBuilder to manage the state of the picked image within the dialog
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              titlePadding: const EdgeInsets.all(0),
              contentPadding: const EdgeInsets.all(24),
              title: Container(
                 padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                 decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                 ),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     const Text('Edit Category', style: TextStyle(fontWeight: FontWeight.bold)),
                     IconButton(
                       icon: const Icon(Icons.close), 
                       onPressed: () => Navigator.of(dialogContext).pop(),
                       tooltip: 'Close',
                       color: Colors.grey[600],
                       splashRadius: 20,
                      ),
                   ],
                 ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: ListBody(
                    children: <Widget>[
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Category Name',
                          border: OutlineInputBorder(),
                          // Maybe remove clear icon or handle its logic
                          // suffixIcon: Icon(Icons.clear) 
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a category name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      // Image Picker Row
                      const Text('Category Thumbnail Image', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            // Display the selected image path or original URL/path
                            child: TextFormField(
                              controller: imagePathController,
                              readOnly: true, // Make it read-only
                              decoration: const InputDecoration(
                                hintText: 'No image selected or URL',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.photo_library_outlined),
                            tooltip: 'Pick Image',
                            onPressed: () async {
                              try {
                                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                                if (image != null) {
                                  // Update the state within the dialog using StatefulBuilder's setState
                                  stfSetState(() {
                                    pickedImageFile = image;
                                    imagePathController.text = image.name; // Show picked file name
                                  });
                                }
                              } catch (e) {
                                print("Image picker error: $e");
                                // Optionally show a snackbar or message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error picking image: $e')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                       // Optional: Image Preview (Add later if needed)
                      // if (pickedImageFile != null)
                      //   Padding(
                      //     padding: const EdgeInsets.only(top: 10),
                      //     child: kIsWeb 
                      //         ? Image.network(pickedImageFile!.path, height: 100)
                      //         : Image.file(File(pickedImageFile!.path), height: 100), 
                      //   ),
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45), // Full width button
                     shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Update Category'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // TODO: Implement update logic (pass nameController.text and pickedImageFile)
                      print('Updating Category: ${nameController.text}, Image: ${pickedImageFile?.path ?? imagePathController.text}');
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showAddToFeaturedDialog(BuildContext context, Category category) async {
    const primaryColor = Color(0xFF6A1B9A);
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
           title: const Center(child: Text('Add to Featured?', style: TextStyle(fontWeight: FontWeight.bold))),
           content: Text('Do you want to add this category (${category.name}) to the featured section?', textAlign: TextAlign.center),
           actionsAlignment: MainAxisAlignment.center,
           actionsPadding: const EdgeInsets.only(bottom: 20), 
           actions: <Widget>[
             ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Add'),
                onPressed: () {
                    // TODO: Implement Add to Featured logic
                    print('Adding ${category.name} to featured');
                    Navigator.of(dialogContext).pop();
                },
             ),
             const SizedBox(width: 10),
             ElevatedButton(
                style: ElevatedButton.styleFrom(
                   backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('No'),
                 onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDeleteCategoryDialog(BuildContext context, Category category) async {
     const primaryColor = Color(0xFF6A1B9A);
    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
           title: const Center(child: Text('Delete This Category?', style: TextStyle(fontWeight: FontWeight.bold))),
           content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                Text('Do you want to delete this category and it\'s contents?', textAlign: TextAlign.center),
                SizedBox(height: 10),
                 Text(
                  'Warning: All of the quizzes and questions included to this category will be deleted too!',
                  style: TextStyle(color: Colors.red, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
            ],
           ),
           actionsAlignment: MainAxisAlignment.center,
           actionsPadding: const EdgeInsets.only(bottom: 20),
           actions: <Widget>[
             ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Yes, Delete'),
                 onPressed: () {
                    // TODO: Implement delete logic
                     print('Deleting ${category.name}');
                    Navigator.of(dialogContext).pop();
                },
             ),
             const SizedBox(width: 10),
             ElevatedButton(
                style: ElevatedButton.styleFrom(
                   backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('No'),
                 onPressed: () => Navigator.of(dialogContext).pop(),
            ),
          ],
        );
      },
    );
  }

  // --- ADD CATEGORY DIALOG ---
  Future<void> _showAddCategoryDialog(BuildContext context) async {
    final nameController = TextEditingController(); // Empty initially
    final imagePathController = TextEditingController(); // Empty initially
    XFile? pickedImageFile;
    final formKey = GlobalKey<FormState>();
    const primaryColor = Color(0xFF6A1B9A);
    final ImagePicker picker = ImagePicker();

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              titlePadding: const EdgeInsets.all(0),
              contentPadding: const EdgeInsets.all(24),
              title: Container(
                 padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                 decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                 ),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     const Text('Add New Category', style: TextStyle(fontWeight: FontWeight.bold)), // Changed Title
                     IconButton(
                       icon: const Icon(Icons.close), 
                       onPressed: () => Navigator.of(dialogContext).pop(),
                       tooltip: 'Close',
                       color: Colors.grey[600],
                       splashRadius: 20,
                      ),
                   ],
                 ),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: ListBody(
                    children: <Widget>[
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Category Name',
                          hintText: 'Enter Category Name', // Added hint
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.clear) // Or handle clear logic
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a category name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text('Category Thumbnail Image', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: imagePathController,
                        // Allow manual URL entry OR picking an image
                        // readOnly: true, // Make it editable for URL input
                        decoration: InputDecoration(
                          hintText: 'Enter Image Url or Select Image', // Updated hint
                          border: const OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                          suffixIcon: Row(
                             mainAxisSize: MainAxisSize.min, // Important
                             children: [
                               // Optional: Clear button
                               // IconButton(icon: const Icon(Icons.clear), onPressed: (){}), 
                               IconButton(
                                icon: const Icon(Icons.photo_library_outlined),
                                tooltip: 'Pick Image',
                                onPressed: () async {
                                   try {
                                      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                                      if (image != null) {
                                        stfSetState(() {
                                          pickedImageFile = image;
                                          imagePathController.text = image.name; // Display picked file name
                                        });
                                      }
                                    } catch (e) {
                                      print("Image picker error: $e");
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error picking image: $e')),
                                      );
                                    }
                                 },
                               ),
                             ],
                          )
                        ),
                        // No validator needed here? Or validate if it's URL or if a file is picked?
                      ),
                      // Optional Image preview
                    ],
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 45),
                     shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Upload Category'), // Changed Button Text
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      // TODO: Implement create logic (pass nameController.text and pickedImageFile/imagePathController.text)
                      print('Creating Category: ${nameController.text}, Image: ${pickedImageFile?.path ?? imagePathController.text}');
                      Navigator.of(dialogContext).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- SET ORDER DIALOG ---
  Future<void> _showSetOrderDialog(BuildContext context) async {
    const primaryColor = Color(0xFF6A1B9A);
    // Use a temporary list within the dialog state for reordering
    List<Category> tempList = List<Category>.from(_reorderableCategories);

    return showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        // Use StatefulBuilder for the ReorderableListView state
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              titlePadding: const EdgeInsets.all(0),
              contentPadding: const EdgeInsets.fromLTRB(0, 12, 0, 12), // Adjust padding
              title: Container(
                 padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                 decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                 ),
                 child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       const Text('Set Category Order', style: TextStyle(fontWeight: FontWeight.bold)),
                       IconButton(
                          icon: const Icon(Icons.close), 
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          tooltip: 'Close',
                          color: Colors.grey[600],
                          splashRadius: 20,
                       ),
                    ],
                 ),
              ),
              // Make content scrollable and constrain height
              content: Container(
                width: double.maxFinite, // Take full width
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6), // Limit height
                child: ReorderableListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: <Widget>[
                    for (int index = 0; index < tempList.length; index += 1) 
                      ListTile(
                        key: Key(tempList[index].id), // Unique key for each item
                        leading: const Icon(Icons.drag_handle), // Drag handle
                        title: Text(tempList[index].name),
                        trailing: Text('#${index + 1}'), // Display current order
                      ),
                  ],
                  onReorder: (int oldIndex, int newIndex) {
                    stfSetState(() {
                      if (oldIndex < newIndex) {
                        newIndex -= 1;
                      }
                      final Category item = tempList.removeAt(oldIndex);
                      tempList.insert(newIndex, item);
                    });
                  },
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              actions: <Widget>[
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                     backgroundColor: primaryColor,
                     foregroundColor: Colors.white,
                     minimumSize: const Size(double.infinity, 45),
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(8),
                     ),
                  ),
                  child: const Text('Save Order'),
                  onPressed: () {
                    // TODO: Implement logic to save the new order (tempList)
                    setState(() {
                      // Update the main list with the new order
                      _reorderableCategories = List<Category>.from(tempList);
                    });
                    print('New Category Order Saved (IDs): ${tempList.map((c) => c.id).toList()}');
                    Navigator.of(dialogContext).pop(); 
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Color(0xFF6A1B9A); // Same purple as sidebar

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Action Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Categories',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _showSetOrderDialog(context), // Call set order dialog
                    icon: const Icon(Icons.sort, size: 18),
                    label: const Text('Set Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryColor,
                      side: const BorderSide(color: primaryColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showAddCategoryDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Category'),
                    style: ElevatedButton.styleFrom(
                       backgroundColor: primaryColor,
                       foregroundColor: Colors.white,
                       shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 24),
          // Categories Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 350, // Max width for each item
                childAspectRatio: 16 / 10, // Aspect ratio (width / height)
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemCount: _reorderableCategories.length, // Use the mutable list
              itemBuilder: (context, index) {
                final category = _reorderableCategories[index]; // Get category from mutable list
                return CategoryCard(
                    category: category,
                    onEdit: () => _showEditCategoryDialog(context, category),
                    onAdd: () => _showAddToFeaturedDialog(context, category),
                    onDelete: () => _showDeleteCategoryDialog(context, category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for individual Category Card
class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onAdd;
  final VoidCallback onDelete;

  const CategoryCard({
    super.key, 
    required this.category,
    required this.onEdit,
    required this.onAdd,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
     const actionButtonColor = Colors.blue;
     const actionIconColor = Colors.white;

    return Card(
      clipBehavior: Clip.antiAlias, // Clip the image
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Stack(
        children: [
          // Background Image (Placeholder)
          Positioned.fill(
            child: Image.asset(
              category.imageUrl, // Use placeholder path
              fit: BoxFit.cover,
              // Add color overlay for better text visibility
              color: Colors.black.withOpacity(0.4),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end, // Align text to bottom
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Quiz Count: ${category.quizCount}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          // Action Buttons Overlay
          Positioned(
            top: 8,
            right: 8,
            child: Row(
              children: [
                _buildActionButton(icon: Icons.edit, color: actionButtonColor, iconColor: actionIconColor, tooltip: 'Edit', onPressed: onEdit),
                const SizedBox(width: 4),
                _buildActionButton(icon: Icons.add, color: actionButtonColor, iconColor: actionIconColor, tooltip: 'Add to Featured?', onPressed: onAdd),
                const SizedBox(width: 4),
                _buildActionButton(icon: Icons.delete_outline, color: actionButtonColor, iconColor: actionIconColor, tooltip: 'Delete', onPressed: onDelete),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      {required IconData icon, required Color color, required Color iconColor, required String tooltip, required VoidCallback onPressed}) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        elevation: 2,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Icon(icon, size: 18, color: iconColor),
          ),
        ),
      ),
    );
  }
} 