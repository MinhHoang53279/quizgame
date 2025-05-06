import 'package:flutter/material.dart';
// Thêm các import cần thiết khác nếu có (ví dụ: provider)
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert'; // For jsonEncode/Decode if loading Quill data

// Mô hình dữ liệu giả lập cho Quiz (điều chỉnh nếu cần)
class QuizInfo {
  final String id;
  final String thumbnailUrl;
  final String name;
  final int questionCount;
  final String categoryName;
  // Thêm các trường khác nếu cần
  final String categoryId; // Cần ID để xử lý dropdown
  final int points;
  final String questionOrder;
  final bool timerEnabled;
  final int timerMinutes;
  final String description; // JSON string for Quill

  const QuizInfo({
    required this.id,
    required this.thumbnailUrl,
    required this.name,
    required this.questionCount,
    required this.categoryName,
    // Thêm các trường từ dialog
    required this.categoryId,
    required this.points,
    required this.questionOrder,
    required this.timerEnabled,
    required this.timerMinutes,
    required this.description,
  });
}

// Placeholder Category Model (cần cho dropdown trong dialog)
class CategoryInfoDialog {
  final String id;
  final String name;
  const CategoryInfoDialog({required this.id, required this.name});
}

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  // Dữ liệu giả lập - Thay thế bằng dữ liệu thật từ provider/API
  final List<QuizInfo> _dummyQuizzes = const [
    QuizInfo(id: 'q1', thumbnailUrl: 'assets/images/placeholder.png', name: 'British Empire', questionCount: 10, categoryName: 'History', categoryId: 'cat1', points: 10, questionOrder: 'Oldest First', timerEnabled: true, timerMinutes: 2, description: '[{"insert":"Description for British Empire quiz.\\n"}]'),
    QuizInfo(id: 'q2', thumbnailUrl: 'assets/images/placeholder.png', name: 'Space Technology', questionCount: 0, categoryName: 'Technology', categoryId: 'cat4', points: 5, questionOrder: 'Newest First', timerEnabled: false, timerMinutes: 0, description: '[{"insert":"All about space!\\n"}]'),
    QuizInfo(id: 'q3', thumbnailUrl: 'assets/images/placeholder.png', name: 'LEVEL I', questionCount: 7, categoryName: 'Learn English', categoryId: 'cat2', points: 8, questionOrder: 'Random', timerEnabled: true, timerMinutes: 5, description: '[{"insert":"English learning level 1.\\n"}]'),
    QuizInfo(id: 'q4', thumbnailUrl: 'assets/images/placeholder.png', name: 'React Native', questionCount: 8, categoryName: 'Programming', categoryId: 'cat5', points: 15, questionOrder: 'Oldest First', timerEnabled: false, timerMinutes: 0, description: '[{"insert":"Mobile dev with React Native.\\n"}]'),
    QuizInfo(id: 'q5', thumbnailUrl: 'assets/images/placeholder.png', name: 'Internet of Things (IoT)', questionCount: 10, categoryName: 'Technology', categoryId: 'cat4', points: 12, questionOrder: 'Newest First', timerEnabled: true, timerMinutes: 10, description: '[{"insert":"Connecting devices.\\n"}]'),
    QuizInfo(id: 'q6', thumbnailUrl: 'assets/images/placeholder.png', name: 'Dart', questionCount: 10, categoryName: 'Learn Flutter', categoryId: 'cat6', points: 5, questionOrder: 'Random', timerEnabled: false, timerMinutes: 0, description: '[{"insert":"Fundamentals of Dart.\\n"}]'),
    // Thêm dữ liệu khác nếu cần để test phân trang
  ];

  // Dữ liệu giả lập cho Categories (dùng trong dropdown)
  final List<CategoryInfoDialog> _dummyCategories = const [
    CategoryInfoDialog(id: 'cat1', name: 'History'),
    CategoryInfoDialog(id: 'cat2', name: 'Learn English'),
    CategoryInfoDialog(id: 'cat3', name: 'Religion'),
    CategoryInfoDialog(id: 'cat4', name: 'Technology'),
    CategoryInfoDialog(id: 'cat5', name: 'Programming'),
    CategoryInfoDialog(id: 'cat6', name: 'Learn Flutter'),
  ];

  final List<String> _questionOrderOptions = ['Oldest First', 'Newest First', 'Random'];

  // TODO: Thêm state cho phân trang, sắp xếp, tìm kiếm

  // --- Hàm hiển thị Dialog Chỉnh sửa --- 
  Future<void> _showEditQuizDialog(QuizInfo quiz) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: quiz.name);
    final thumbnailController = TextEditingController(text: quiz.thumbnailUrl);
    final pointsController = TextEditingController(text: quiz.points.toString());
    final timerMinutesController = TextEditingController(text: quiz.timerMinutes.toString());
    
    final quillController = QuillController(
      document: Document.fromJson(jsonDecode(quiz.description)),
        selection: const TextSelection.collapsed(offset: 0),
      );
    final editorFocusNode = FocusNode();
    final editorScrollController = ScrollController();

    final imagePicker = ImagePicker();
    XFile? pickedImageFile; // Store picked image file

    // Dialog state variables
    String? selectedCategoryId = quiz.categoryId;
    String? selectedQuestionOrder = quiz.questionOrder;
    bool isTimerOn = quiz.timerEnabled;

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (BuildContext dialogContext) {
        // Use StatefulBuilder to manage dialog's internal state
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              // Styling dialog để giống ảnh
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              titlePadding: const EdgeInsets.all(0),
              contentPadding: const EdgeInsets.all(0), 
              title: Container(
                 padding: const EdgeInsets.fromLTRB(20, 16, 8, 16), // Adjust padding
                 decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                 ),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     // Tiêu đề dialog sẽ trống theo ảnh, chỉ có nút close
                     const Spacer(), // Đẩy nút close sang phải
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
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7, // Chiều rộng dialog
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // --- Row 1: Category & Quiz Name ---
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildDropdownFormField<String>(
                                context: stfContext, // Use StatefulBuilder context
                                labelText: 'Category',
                                value: selectedCategoryId,
                                hintText: 'Select Category',
                                items: _dummyCategories.map((cat) => DropdownMenuItem(
                                  value: cat.id,
                                  child: Text(cat.name),
                                )).toList(),
                                onChanged: (newValue) {
                                  stfSetState(() => selectedCategoryId = newValue);
                                },
                                validator: (value) => value == null ? 'Please select a category' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextFormField(
                                controller: nameController,
                                labelText: 'Quiz Name',
                                hintText: 'Enter Quiz Title',
                                validator: (value) => (value == null || value.isEmpty) ? 'Please enter name' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // --- Row 2: Thumbnail & Points ---
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildImagePickerFormField(
                                context: stfContext, // Use StatefulBuilder context
                                controller: thumbnailController,
                                picker: imagePicker,
                                currentImageFile: pickedImageFile,
                                labelText: 'Quiz Thumbnail Image',
                                hintText: 'Enter Image Url or Select Image',
                                onImagePicked: (file) {
                                  stfSetState(() => pickedImageFile = file);
                                },
                              ),
                            ),
                             const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextFormField(
                                controller: pointsController,
                                labelText: 'Points Required To Play This Quiz',
                                hintText: 'Enter Points',
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Enter points';
                                  if (int.tryParse(value) == null) return 'Invalid number';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                         // --- Question Order Dropdown ---
                         _buildDropdownFormField<String>(
                           context: stfContext,
                            labelText: 'Question Order',
                            value: selectedQuestionOrder,
                            hintText: 'Select Question Order',
                            items: _questionOrderOptions.map((order) => DropdownMenuItem(
                              value: order,
                              child: Text(order)
                            )).toList(),
                            onChanged: (newValue) {
                              stfSetState(() => selectedQuestionOrder = newValue);
                            },
                             validator: (value) => value == null ? 'Select order' : null,
                        ),
                        const SizedBox(height: 20),

                         // --- Timer Section ---
                        _buildTimerSection(
                          context: stfContext, // Use StatefulBuilder context
                          isTimerOn: isTimerOn,
                          controller: timerMinutesController,
                          onTimerToggle: (value) {
                             stfSetState(() => isTimerOn = value);
                          },
                           validator: (value) { // Validate minutes only if timer is On
                             if(isTimerOn) {
                               if (value == null || value.isEmpty) return 'Enter minutes';
                               if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Invalid minutes';
                             }
                             return null;
                           }
                        ),
                        const SizedBox(height: 20),

                        // --- Description Section (Quill Editor) ---
                        const Text('Enter Quiz Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        QuillSimpleToolbar(
                           controller: quillController,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(
                            minHeight: 150, // Đặt chiều cao tối thiểu
                            maxHeight: 300, // Giới hạn chiều cao tối đa
                          ),
                           decoration: BoxDecoration(
                             border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                           ),
                          child: QuillEditor.basic(
                             controller: quillController,
                            focusNode: editorFocusNode,
                            scrollController: editorScrollController,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // --- Update Button ---
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A), // Màu tím
                              foregroundColor: Colors.white,
                              minimumSize: const Size(200, 50), // Kích thước nút
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Update Quiz', style: TextStyle(fontSize: 16)),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                // Validation passed
                                final updatedData = {
                                  'id': quiz.id,
                                  'name': nameController.text,
                                  'categoryId': selectedCategoryId,
                                  'thumbnail': pickedImageFile?.path ?? thumbnailController.text, // Path nếu có ảnh mới, ngược lại giữ URL cũ
                                  'points': int.parse(pointsController.text),
                                  'questionOrder': selectedQuestionOrder,
                                  'timerEnabled': isTimerOn,
                                  'timerMinutes': isTimerOn ? int.parse(timerMinutesController.text) : 0,
                                  'description': jsonEncode(quillController.document.toDelta().toJson()),
                                  // Include categoryName if needed by backend/update logic
                                };

                                // TODO: Implement actual update logic (call API, update provider state)
                                print('Quiz data to update: $updatedData');

                                if (!mounted) return; // Check mounted before pop
                                Navigator.of(dialogContext).pop(); // Close dialog
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('"${quiz.name}" updated (Not actually saved!)')),
                                );
                              } else {
                                print('Form validation failed');
                              }
                            },
                           ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Hàm hiển thị Dialog Thêm Mới --- 
  Future<void> _showAddQuizDialog() async {
    final formKey = GlobalKey<FormState>();
    // Khởi tạo controller trống
    final nameController = TextEditingController();
    final thumbnailController = TextEditingController();
    final pointsController = TextEditingController();
    final timerMinutesController = TextEditingController();

    // Quill controller trống
    final quillController = QuillController.basic();
    final editorFocusNode = FocusNode();
    final editorScrollController = ScrollController();

    final imagePicker = ImagePicker();
    XFile? pickedImageFile; 

    // Trạng thái mặc định cho dialog thêm mới
    String? selectedCategoryId;
    String? selectedQuestionOrder;
    bool isTimerOn = false; // Mặc định tắt timer

    return showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              titlePadding: const EdgeInsets.all(0),
              contentPadding: const EdgeInsets.all(0), 
              title: Container(
                 padding: const EdgeInsets.fromLTRB(20, 16, 8, 16), 
                 decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                 ),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     const Spacer(),
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
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.7, 
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // --- Row 1: Category & Quiz Name ---
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                               // FIX: Thêm hintText cho Dropdown
                              child: _buildDropdownFormField<String>(
                                context: stfContext, 
                                labelText: 'Category',
                                value: selectedCategoryId,
                                hintText: 'Select Category', // Placeholder
                                items: _dummyCategories.map((cat) => DropdownMenuItem(
                                  value: cat.id,
                                  child: Text(cat.name),
                                )).toList(),
                                onChanged: (newValue) {
                                  stfSetState(() => selectedCategoryId = newValue);
                                },
                                validator: (value) => value == null ? 'Please select a category' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextFormField(
                                controller: nameController,
                                labelText: 'Quiz Name',
                                hintText: 'Enter Quiz Title', // Placeholder
                                validator: (value) => (value == null || value.isEmpty) ? 'Please enter name' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // --- Row 2: Thumbnail & Points ---
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildImagePickerFormField(
                                context: stfContext, 
                                controller: thumbnailController,
                                picker: imagePicker,
                                currentImageFile: pickedImageFile,
                                labelText: 'Quiz Thumbnail Image',
                                hintText: 'Enter Image Url or Select Image', // Placeholder
                                onImagePicked: (file) {
                                  stfSetState(() => pickedImageFile = file);
                                },
                              ),
                            ),
                             const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextFormField(
                                controller: pointsController,
                                labelText: 'Points Required To Play This Quiz',
                                hintText: 'Enter Points', // Placeholder
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) return 'Enter points';
                                  if (int.tryParse(value) == null) return 'Invalid number';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                         // --- Question Order Dropdown ---
                         // FIX: Thêm hintText
                         _buildDropdownFormField<String>(
                           context: stfContext,
                            labelText: 'Question Order',
                            value: selectedQuestionOrder,
                            hintText: 'Select Question Order', // Placeholder
                            items: _questionOrderOptions.map((order) => DropdownMenuItem(
                              value: order,
                              child: Text(order)
                            )).toList(),
                            onChanged: (newValue) {
                              stfSetState(() => selectedQuestionOrder = newValue);
                            },
                             validator: (value) => value == null ? 'Select order' : null,
                        ),
                        const SizedBox(height: 20),

                         // --- Timer Section ---
                        _buildTimerSection(
                          context: stfContext, 
                          isTimerOn: isTimerOn,
                          controller: timerMinutesController,
                          onTimerToggle: (value) {
                             stfSetState(() => isTimerOn = value);
                          },
                           validator: (value) { 
                             if(isTimerOn) {
                               if (value == null || value.isEmpty) return 'Enter minutes';
                               if (int.tryParse(value) == null || int.parse(value) <= 0) return 'Invalid minutes';
                             }
                             return null;
                           }
                        ),
                        const SizedBox(height: 20),

                        // --- Description Section (Quill Editor) ---
                        const Text('Enter Quiz Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        QuillSimpleToolbar(
                           controller: quillController,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(
                            minHeight: 150, 
                            maxHeight: 300, 
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: QuillEditor.basic(
                             controller: quillController,
                            focusNode: editorFocusNode,
                            scrollController: editorScrollController,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // --- Upload Button ---
                        Center(
                          child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A), 
                    foregroundColor: Colors.white,
                              minimumSize: const Size(200, 50), 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                            // FIX: Đổi Text nút
                            child: const Text('Upload Quiz', style: TextStyle(fontSize: 16)), 
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                                final newQuizData = {
                                  // Không có ID ở đây
                                  'name': nameController.text,
                                  'categoryId': selectedCategoryId,
                                  'thumbnail': pickedImageFile?.path ?? thumbnailController.text,
                                  'points': int.parse(pointsController.text),
                                  'questionOrder': selectedQuestionOrder,
                                  'timerEnabled': isTimerOn,
                                  'timerMinutes': isTimerOn ? int.parse(timerMinutesController.text) : 0,
                                  'description': jsonEncode(quillController.document.toDelta().toJson()),
                                };

                                // TODO: Implement actual ADD logic (call API, update provider state)
                                print('New Quiz data to upload: $newQuizData');

                                if (!mounted) return; 
                      Navigator.of(dialogContext).pop();
                       ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Quiz "${nameController.text}" added (Not actually saved!)')),
                      );
                              } else {
                                print('Form validation failed');
                    }
                  },
                          ),
                ),
              ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // --- Hàm hiển thị Dialog Sắp xếp Thứ tự --- 
  Future<void> _showSetOrderDialog() async {
    String? selectedCategoryId;
    List<QuizInfo> quizzesForSelectedCategory = []; // Danh sách quiz cho category đã chọn

    // Lấy danh sách categories từ dummy data (hoặc provider)
    final categories = _dummyCategories;

     return showDialog<void>(
        context: context,
      barrierDismissible: false,
        builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {

            // Hàm lọc quiz theo category ID
            void _loadQuizzesForCategory(String? categoryId) {
              if (categoryId == null) {
                quizzesForSelectedCategory = [];
              } else {
                // Lọc từ dummy data (thay bằng fetch API/provider sau)
                quizzesForSelectedCategory = _dummyQuizzes
                    .where((quiz) => quiz.categoryId == categoryId)
                    .toList();
                // TODO: Implement actual sorting logic based on current order if available
              }
            }

          return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              titlePadding: const EdgeInsets.all(0),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              title: Container(
                 padding: const EdgeInsets.fromLTRB(20, 16, 8, 16), 
                 decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                 ),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   children: [
                     const Text('Set Quiz Order', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
              content: SizedBox(
                // Điều chỉnh chiều rộng nếu cần, hoặc để tự động
                 width: MediaQuery.of(context).size.width * 0.5, // Ví dụ: 50% chiều rộng màn hình
                 child: Column(
                   mainAxisSize: MainAxisSize.min, // Giữ kích thước tối thiểu
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     _buildDropdownFormField<String>(
                       context: stfContext,
                       labelText: 'Category',
                       value: selectedCategoryId,
                       hintText: 'Select Category',
                       items: categories.map((cat) => DropdownMenuItem(
                         value: cat.id,
                         child: Text(cat.name),
                       )).toList(),
                       onChanged: (newValue) {
                         stfSetState(() {
                           selectedCategoryId = newValue;
                           _loadQuizzesForCategory(selectedCategoryId); // Tải quiz cho category mới
                         });
                       },
                       // Không cần validator ở đây
                     ),
                     const SizedBox(height: 20),

                     // --- Khu vực hiển thị danh sách Quiz hoặc thông báo ---
                     Expanded(
                       child: Container(
                         decoration: BoxDecoration(
                           border: Border.all(color: Colors.grey[300]!),
                           borderRadius: BorderRadius.circular(8),
                         ),
                         child: selectedCategoryId == null
                             ? const Center(child: Text('Please Select A Category First!'))
                             : quizzesForSelectedCategory.isEmpty
                                 ? const Center(child: Text('No quizzes found in this category.'))
                                 // TODO: Thay ListView bằng ReorderableListView để kéo thả
                                 : ListView.builder(
                                     itemCount: quizzesForSelectedCategory.length,
                                     itemBuilder: (context, index) {
                                       final quiz = quizzesForSelectedCategory[index];
                                       return ListTile(
                                         key: ValueKey(quiz.id), // Cần key cho ReorderableListView sau này
                                         leading: const Icon(Icons.drag_handle), // Icon kéo thả (placeholder)
                                         title: Text(quiz.name),
                                         // Thêm các thông tin khác nếu cần
                                       );
                                     },
                                   ),
                       ),
                     ),
                   ],
                 ),
              ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B9A), 
                    foregroundColor: Colors.white,
                  ),
                  onPressed: selectedCategoryId == null ? null : () { // Disable nếu chưa chọn category
                    // TODO: Implement logic to save the new order of quizzesForSelectedCategory
                    print('Saving order for category: $selectedCategoryId');
                    print('New order (IDs): ${quizzesForSelectedCategory.map((q) => q.id).toList()}');
                     if (!mounted) return; 
                     Navigator.of(dialogContext).pop();
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('Quiz order saved (Not implemented yet!)')),
                     );
                  },
                  child: const Text('Save Order'),
                ),
              ],
              actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            );
          },
        );
      },
    );
  }

  // Hàm xử lý khi nhấn nút Delete
  void _handleDeleteQuiz(QuizInfo quiz) {
    showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete "${quiz.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () {
                  // TODO: Implement actual delete logic here
                  Navigator.of(ctx).pop(); // Close dialog
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Delete action for ${quiz.name} - Implement me!')),
                  );
                },
                child: const Text('Delete'),
              ),
            ],
          );
        },
      );
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Màu chính từ theme hoặc định nghĩa lại nếu cần (lấy từ hình ảnh)
    const primaryColor = Color(0xFF6A1B9A); // Màu tím giống sidebar/button Add

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Title and Action Buttons Row ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Quizzes',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Điều chỉnh màu nếu cần
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    // FIX: Gọi hàm mở dialog thêm mới
                    onPressed: _showAddQuizDialog, 
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Quiz'),
                     style: ElevatedButton.styleFrom(
                       backgroundColor: primaryColor,
                       foregroundColor: Colors.white,
                       shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                     // FIX: Gọi hàm mở dialog sắp xếp
                    onPressed: _showSetOrderDialog,
                    icon: const Icon(Icons.import_export, size: 18), 
                    label: const Text('Set Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                       foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Nút Sort By - Cần state management để thay đổi "All"
                   ElevatedButton.icon(
                    onPressed: () { /* TODO: Implement Sort By dropdown/menu */ },
                    icon: const Icon(Icons.sort, size: 18),
                    label: const Text('Sort By - All'), // TODO: Làm động text này
                     style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200], // Màu nền xám nhạt
                      foregroundColor: Colors.black87, // Màu chữ đen
                       shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ],
              ),
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1), // changes position of shadow
                  ),
                ],
               ),
              child: SingleChildScrollView( // Cho phép cuộn ngang nếu bảng quá rộng
                 scrollDirection: Axis.horizontal,
                 child: DataTable(
                  headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey[50]),
                  headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                     columns: const <DataColumn>[
                      DataColumn(label: Text('Thumbnail')),
                      DataColumn(label: Text('Quiz Name')),
                      DataColumn(label: Text('Questions Amount')),
                      DataColumn(label: Text('Category')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: _dummyQuizzes.map((quiz) => DataRow(
                      cells: <DataCell>[
                        DataCell(
                          Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          // Sử dụng Image.network nếu URL từ API, Image.asset nếu từ local
                          child: Image.asset(
                             quiz.thumbnailUrl, // Dùng ảnh placeholder
                             width: 60, // Điều chỉnh kích thước
                             height: 40,
                             fit: BoxFit.cover,
                             errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 40), // Fallback icon
                          ),
                          )
                        ),
                        DataCell(Text(quiz.name)),
                        DataCell(Text(quiz.questionCount.toString())),
                        DataCell(Text(quiz.categoryName)),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Nút Edit (icon bút chì màu xanh)
                            Tooltip(
                              message: 'Edit Quiz',
                              child: InkWell(
                                onTap: () => _showEditQuizDialog(quiz),
                                customBorder: const CircleBorder(),
                                child: Container(
                                   padding: const EdgeInsets.all(6),
                                   decoration: BoxDecoration(
                                     color: Colors.blue.withOpacity(0.1), // Nền xanh nhạt
                                     shape: BoxShape.circle,
                                   ),
                                   child: const Icon(Icons.edit_outlined, size: 18, color: Colors.blue)
                                ),
                              ),
                            ),
                             const SizedBox(width: 8),
                             // Nút Delete (icon thùng rác màu đỏ)
                            Tooltip(
                              message: 'Delete Quiz',
                              child: InkWell(
                                 onTap: () => _handleDeleteQuiz(quiz),
                                 customBorder: const CircleBorder(),
                                 child: Container(
                                   padding: const EdgeInsets.all(6),
                                   decoration: BoxDecoration(
                                     color: Colors.red.withOpacity(0.1), // Nền đỏ nhạt
                                     shape: BoxShape.circle,
                                   ),
                                   child: const Icon(Icons.delete_outline, size: 18, color: Colors.red)
                                 ),
                              ),
                            ),
                          ],
                        )
                      ),
                      ],
                    )).toList(),
                 ),
               ),
            ),
          ),
          const SizedBox(height: 16),
          // --- Pagination ---
           _buildPaginationControls(), // Gọi hàm xây dựng phân trang
        ],
      ),
    );
  }

  // Widget xây dựng phần điều khiển phân trang (Placeholder)
   Widget _buildPaginationControls() {
     // TODO: Lấy tổng số item và trang hiện tại từ state/provider
     const totalItems = 11; // Ví dụ
     const itemsPerPage = 10;
     const currentPage = 1; // Trang bắt đầu từ 1

     final totalPages = (totalItems / itemsPerPage).ceil();
     final startItem = (currentPage - 1) * itemsPerPage + 1;
     final endItem = (startItem + itemsPerPage - 1) > totalItems ? totalItems : (startItem + itemsPerPage - 1);


     return Row(
       mainAxisAlignment: MainAxisAlignment.end,
       children: [
         Text('Showing $startItem–$endItem of $totalItems'),
         const SizedBox(width: 16),
         IconButton(
           icon: const Icon(Icons.chevron_left),
           onPressed: currentPage > 1 ? () { /* TODO: Go to previous page */ } : null, // Disable nếu ở trang đầu
           tooltip: 'Previous Page',
           splashRadius: 20,
         ),
         IconButton(
           icon: const Icon(Icons.chevron_right),
           onPressed: currentPage < totalPages ? () { /* TODO: Go to next page */ } : null, // Disable nếu ở trang cuối
           tooltip: 'Next Page',
           splashRadius: 20,
        ),
       ],
    );
  }

  // --- Các Widget Helper cho Form trong Dialog --- 

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    String? hintText,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        suffixIcon: suffixIcon ?? ( controller.text.isNotEmpty && !readOnly
          ? IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () => controller.clear(),
              splashRadius: 20,
            )
          : null),
      ),
      validator: validator,
    );
  }
  
  Widget _buildDropdownFormField<T>({
    required BuildContext context, 
    required String labelText,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required void Function(T?) onChanged,
    String? hintText,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      decoration: InputDecoration(
        labelText: labelText,
        hintText: value == null ? hintText : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      ),
      value: value,
      items: items,
      onChanged: onChanged,
      validator: validator,
      isExpanded: true, 
      icon: const Icon(Icons.arrow_drop_down),
    );
  }

  Widget _buildImagePickerFormField({
    required BuildContext context,
    required TextEditingController controller,
    required ImagePicker picker,
    required XFile? currentImageFile,
    required String labelText,
    String? hintText,
    required Function(XFile?) onImagePicked,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                 if (controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: () {
                      controller.clear();
                      onImagePicked(null);
                    },
                    splashRadius: 20,
                    tooltip: 'Clear URL / Selection',
                  ),
                IconButton(
              icon: const Icon(Icons.photo_library_outlined),
                  tooltip: 'Pick Image from Gallery',
                  splashRadius: 20,
              onPressed: () async {
                try {
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                      if (!context.mounted) return;
                  if (image != null) {
                         controller.text = image.name; // Hiển thị tên file đã chọn
                         onImagePicked(image); // Cập nhật state
                  }
                } catch (e) {
                       if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error picking image: $e')),
                  );
                }
              },
            ),
              ],
          ),
        ),
        ),
        // Preview ảnh đã chọn (nếu có)
         if (currentImageFile != null)
           Padding(
             padding: const EdgeInsets.only(top: 8.0),
             child: Image.network(
               currentImageFile.path,
               height: 60, 
               width: 100,
               fit: BoxFit.cover,
               errorBuilder: (context, error, stackTrace) => const Text('Preview not available'),
             ),
           )
         // Preview ảnh từ URL
         else if (controller.text.isNotEmpty && Uri.tryParse(controller.text)?.isAbsolute == true) 
           Padding(
             padding: const EdgeInsets.only(top: 8.0),
             child: Image.network( 
               controller.text,
               height: 60,
               width: 100,
               fit: BoxFit.cover,
               errorBuilder: (context, error, stackTrace) => const Text('Invalid URL or cannot load image'), 
             ),
           ),
      ],
    );
  }

  Widget _buildTimerSection({
      required BuildContext context,
      required bool isTimerOn,
      required TextEditingController controller,
      required Function(bool) onTimerToggle,
      String? Function(String?)? validator,
  }) {
     final theme = Theme.of(context);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: 'Timer',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Row(
        children: [
          Text('Timer:', style: theme.textTheme.titleSmall),
          const SizedBox(width: 8),
          Radio<bool>(value: true, groupValue: isTimerOn, onChanged: (val) => onTimerToggle(val!)),
          const Text('On'),
          const SizedBox(width: 8),
          Radio<bool>(value: false, groupValue: isTimerOn, onChanged: (val) => onTimerToggle(val!)),
          const Text('Off'),
          const SizedBox(width: 16),
          // Chỉ hiển thị trường nhập phút khi Timer = On
          Expanded(
            child: Visibility(
              visible: isTimerOn,
              maintainState: true, // Giữ state khi ẩn
              maintainAnimation: true,
              maintainSize: true,
              child: TextFormField(
                controller: controller,
                enabled: isTimerOn, // Disable khi Timer = Off
                decoration: InputDecoration(
                  hintText: 'Minutes',
                  border: InputBorder.none, // Bỏ viền trong
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                   suffixIcon: controller.text.isNotEmpty
                   ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () => controller.clear(),
                      splashRadius: 15,
                    )
                  : null,
                ),
                keyboardType: TextInputType.number,
                validator: validator, // Validator đã kiểm tra isTimerOn
              ),
            ),
          ),
           if(isTimerOn) const Text('Timer in Minutes Per Complete Quiz', style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
} 