import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:http/http.dart' as http;

// Model dữ liệu giả lập cho Question
class QuestionInfo {
  final String id;
  final String title;       // Nội dung câu hỏi
  final List<String> options; // Các lựa chọn (hoặc câu trả lời cho fill-in-blanks)
  final String questionType; // Loại câu hỏi (Fill in the Blanks, Text Only, etc.)
  final String quizName;     // Tên Quiz chứa câu hỏi này
  // Thêm các trường cần thiết khác (ví dụ: correctAnswer, quizId)

  const QuestionInfo({
    required this.id,
    required this.title,
    required this.options,
    required this.questionType,
    required this.quizName,
  });
}

// Model Quiz (Cần cho Dropdown Quiz Name)
class QuizInfoForDropdown {
  final String id;
  final String name;
  final String categoryId; // Để lọc quiz theo category
  const QuizInfoForDropdown({required this.id, required this.name, required this.categoryId});
}

// Model Category (Cần cho Dropdown Category)
class CategoryInfoForDropdown {
  final String id;
  final String name;
  const CategoryInfoForDropdown({required this.id, required this.name});
}

// Enum hoặc const cho Question Type
enum QuestionTypeOption { 
  fillInTheBlanks, 
  textOnly, 
  trueFalse, 
  multiChoice, 
  image,
  audio,
  video
}
// Enum hoặc const cho Option Type
enum OptionTypeOption { textOnly, trueFalse, images }

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  // Dữ liệu giả lập - Thay bằng dữ liệu thật
  final List<QuestionInfo> _dummyQuestions = const [
    QuestionInfo(id: 'qn1', title: 'She ______ to school every day.', options: ['go', 'goes', 'went', 'going'], questionType: 'Fill in the Blanks', quizName: 'LEVEL I'),
    QuestionInfo(id: 'qn2', title: 'The command ______ is used to create a new project?', options: ['flutter start', 'flutter new', 'flutter create', 'flutter now'], questionType: 'Fill in the Blanks', quizName: 'Flutter Basics'),
    QuestionInfo(id: 'qn3', title: 'Which animal is known for its black and white stripes?', options: ['Zebra', 'Lion', 'Gorilla', 'Elephant'], questionType: 'Text Only', quizName: 'LEVEL I'),
    QuestionInfo(id: 'qn4', title: 'Which sentence is grammatically correct?', options: ['She don\'t like ice cream.', 'He don\'t go to school.', 'They don\'t play.', 'It don\'t work.'], questionType: 'Text Only', quizName: 'LEVEL I'),
    QuestionInfo(id: 'qn5', title: 'What is the capital of France?', options: ['London', 'Berlin', 'Paris', 'Madrid'], questionType: 'Text Only', quizName: 'Geography'),
    // Add more dummy data
  ];

  // Dữ liệu giả lập cho Dropdowns (Nên lấy từ Provider)
  final List<CategoryInfoForDropdown> _dummyCategories = const [
    CategoryInfoForDropdown(id: 'cat1', name: 'History'),
    CategoryInfoForDropdown(id: 'cat2', name: 'Learn English'),
    CategoryInfoForDropdown(id: 'cat4', name: 'Technology'),
    CategoryInfoForDropdown(id: 'cat5', name: 'Programming'),
    CategoryInfoForDropdown(id: 'cat6', name: 'Learn Flutter'),
     CategoryInfoForDropdown(id: 'geo1', name: 'Geography'),
     CategoryInfoForDropdown(id: 'fb', name: 'Flutter Basics'),
  ];

  final List<QuizInfoForDropdown> _dummyQuizzesDropdown = const [
    QuizInfoForDropdown(id: 'q1', name: 'British Empire', categoryId: 'cat1'),
    QuizInfoForDropdown(id: 'q2', name: 'Space Technology', categoryId: 'cat4'),
    QuizInfoForDropdown(id: 'q3', name: 'LEVEL I', categoryId: 'cat2'),
    QuizInfoForDropdown(id: 'q4', name: 'React Native', categoryId: 'cat5'),
    QuizInfoForDropdown(id: 'q5', name: 'Internet of Things (IoT)', categoryId: 'cat4'),
    QuizInfoForDropdown(id: 'q6', name: 'Dart', categoryId: 'cat6'),
    QuizInfoForDropdown(id: 'geo_quiz', name: 'Geography', categoryId: 'geo1'),
    QuizInfoForDropdown(id: 'flutter_basics_quiz', name: 'Flutter Basics', categoryId: 'fb'),
  ];

  String _selectedSortOption = 'Newest First'; // Mặc định sắp xếp

  // --- Hàm xử lý cho các nút Actions (Placeholders) ---
  void _handleAddQuestion() {
    _showAddQuestionDialog();
  }

  Widget buildAddQuestionButton() {
    return ElevatedButton.icon(
      icon: const Icon(Icons.add, size: 22, color: Colors.white),
      label: const Text(
        '+ Add Question',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6A1B9A),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2,
      ),
      onPressed: _handleAddQuestion,
    );
  }

  Future<void> _showAddQuestionDialog() async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final optionsControllers = List.generate(4, (index) => TextEditingController());
    String? selectedCategoryId;
    String? selectedQuizId;
    QuestionTypeOption? selectedQuestionType;
    OptionTypeOption? selectedOptionType = OptionTypeOption.textOnly;
    int? selectedCorrectAnswerIndex;
    QuillController _quillController = QuillController.basic();
    List<QuizInfoForDropdown> filteredQuizzes = [];

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            // --- Xác định trạng thái dựa trên selectedOptionType ---
            final isTextOnly = selectedOptionType == OptionTypeOption.textOnly;
            final isTrueFalse = selectedOptionType == OptionTypeOption.trueFalse;
            final isImages = selectedOptionType == OptionTypeOption.images;

            // --- Tạo danh sách mục cho Dropdown Correct Answer ---
            final correctAnswerItems = optionsControllers
                .asMap()
                .entries
                // Chỉ bao gồm các option hợp lệ cho loại hiện tại
                .where((entry) {
                  final index = entry.key;
                  final controller = entry.value;
                  if (isTrueFalse) return index < 2; // Chỉ A, B cho True/False
                  return controller.text.trim().isNotEmpty; // Phải có text cho TextOnly và Images
                })
                .map((entry) {
                  final index = entry.key;
                  final label = String.fromCharCode('A'.codeUnitAt(0) + index);
                  // <<< SỬA LOGIC HIỂN THỊ TEXT CHO TRUE/FALSE >>>
                  final String optionTextSuffix = isTrueFalse 
                      ? (index == 0 ? ': True' : ': False') // Hiển thị True/False cố định
                      : ''; // Không hiển thị gì thêm cho loại khác
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text('Option $label$optionTextSuffix')
                  );
                })
                .toList();

            // --- Validate selectedCorrectAnswerIndex --- 
            if (selectedCorrectAnswerIndex != null && 
                !correctAnswerItems.any((item) => item.value == selectedCorrectAnswerIndex)) {
              // Nếu câu trả lời đúng đã chọn không còn hợp lệ (ví dụ: xóa text hoặc đổi sang True/False)
              WidgetsBinding.instance.addPostFrameCallback((_) { 
                // Cần chạy sau khi build để tránh lỗi setState trong build
                stfSetState(() => selectedCorrectAnswerIndex = null);
              });
            }

            // --- Helper tạo nút chọn ảnh --- 
            Widget _buildSelectImageIcon(int index) {
              return IconButton(
                icon: const Icon(Icons.image_outlined, color: Colors.grey),
                tooltip: 'Select Image for Option ${String.fromCharCode('A'.codeUnitAt(0) + index)}',
                splashRadius: 20,
                onPressed: () async { 
                  final ImagePicker picker = ImagePicker();
                  // Mở thư viện ảnh
                  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

                  if (pickedFile != null) {
                    // Cập nhật text field với đường dẫn ảnh
                    stfSetState(() {
                      optionsControllers[index].text = pickedFile.path;
                    });
                  } else {
                    // Người dùng không chọn ảnh
                    print('Image selection cancelled for option $index');
                  }
                },
              );
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Add Question', style: TextStyle(fontWeight: FontWeight.bold)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.6,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildDropdownFormField<String>(
                                context: stfContext,
                                labelText: 'Category',
                                value: selectedCategoryId,
                                hintText: 'Select Category',
                                items: _dummyCategories.map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name))).toList(),
                                onChanged: (newValue) {
                                  stfSetState(() {
                                    selectedCategoryId = newValue;
                                    selectedQuizId = null;
                                    filteredQuizzes = _dummyQuizzesDropdown.where((quiz) => quiz.categoryId == selectedCategoryId).toList();
                                  });
                                },
                                validator: (v) => v == null ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDropdownFormField<String>(
                                context: stfContext,
                                labelText: 'Quiz Name',
                                value: selectedQuizId,
                                hintText: selectedCategoryId == null ? 'Select Category First' : 'Select Quiz',
                                items: filteredQuizzes.map((quiz) => DropdownMenuItem(value: quiz.id, child: Text(quiz.name))).toList(),
                                onChanged: selectedCategoryId == null ? null : (newValue) {
                                  stfSetState(() => selectedQuizId = newValue);
                                },
                                validator: (v) => v == null ? 'Required' : null,
                                enabled: selectedCategoryId != null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildDropdownFormField<QuestionTypeOption>(
                          context: stfContext,
                          labelText: 'Question Type',
                          value: selectedQuestionType,
                          hintText: 'Select Question Type',
                          items: QuestionTypeOption.values.map((type) {
                            String text;
                            switch(type) {
                              case QuestionTypeOption.fillInTheBlanks: text = 'Fill in the Blanks'; break;
                              case QuestionTypeOption.textOnly: text = 'Text Only'; break;
                              case QuestionTypeOption.trueFalse: text = 'True/False'; break;
                              case QuestionTypeOption.multiChoice: text = 'Multiple Choice'; break;
                              case QuestionTypeOption.image: text = 'Image'; break;
                              case QuestionTypeOption.audio: text = 'Audio'; break;
                              case QuestionTypeOption.video: text = 'Video'; break;
                            }
                            return DropdownMenuItem(
                              value: type,
                              child: Text(text)
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            stfSetState(() => selectedQuestionType = newValue);
                          },
                          validator: (v) => v == null ? 'Required' : null,
                        ),
                        const SizedBox(height: 20),

                        // --- HÀNG RADIO BUTTON OPTION TYPE MỚI (SỬA LẠI) --- 
                        Row(
                          children: [
                            const Text('Option Type:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                            const SizedBox(width: 12),
                            // <<< Đảm bảo lặp qua TẤT CẢ các giá trị enum >>>
                            ...OptionTypeOption.values.map((type) {
                              String label;
                              // <<< Switch case phải bao gồm images >>>
                              switch (type) {
                                case OptionTypeOption.textOnly: label = 'Text Only'; break;
                                case OptionTypeOption.trueFalse: label = 'True/False'; break;
                                case OptionTypeOption.images: label = 'Images'; break; 
                              }
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<OptionTypeOption>(
                                    value: type,
                                    groupValue: selectedOptionType,
                                    onChanged: (OptionTypeOption? value) {
                                      if (value != null) {
                                        stfSetState(() {
                                          selectedOptionType = value;
                                          // Đặt lại đáp án đúng khi đổi loại
                                          selectedCorrectAnswerIndex = null;
                                        });
                                      }
                                    },
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  Text(label),
                                  // Thêm khoảng cách nếu không phải item cuối
                                  if (type != OptionTypeOption.values.last) const SizedBox(width: 12),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // --- HIỂN THỊ OPTIONS A, B, C, D THEO LOẠI --- 
                        if (isTextOnly)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildTextFormField(controller: optionsControllers[0], labelText: 'Option A', hintText: 'Enter Option Name', readOnly: false, validator: (v)=>(v==null || v.isEmpty) ? 'Required' : null, onChanged: (_) => stfSetState(() {}),)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTextFormField(controller: optionsControllers[1], labelText: 'Option B', hintText: 'Enter Option Name', readOnly: false, validator: (v)=>(v==null || v.isEmpty) ? 'Required' : null, onChanged: (_) => stfSetState(() {}),)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildTextFormField(controller: optionsControllers[2], labelText: 'Option C', hintText: 'Enter Option Name', readOnly: false, onChanged: (_) => stfSetState(() {}),)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTextFormField(controller: optionsControllers[3], labelText: 'Option D', hintText: 'Enter Option Name', readOnly: false, onChanged: (_) => stfSetState(() {}),)),
                                ],
                              ),
                               const SizedBox(height: 20), // Khoảng cách trước dropdown
                            ],
                          )
                        else if (isTrueFalse)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Tự động set text và readOnly cho True/False ở đây
                              // <<< KHÔI PHỤC KHỐI WIDGETSBINDING ĐỂ XÓA TEXT >>>
                              () { // Sử dụng hàm ẩn danh để chạy một lần
                                WidgetsBinding.instance.addPostFrameCallback((_) {
                                  // Chỉ xóa, không set text nữa
                                  if (optionsControllers[0].text.isNotEmpty) optionsControllers[0].clear(); 
                                  if (optionsControllers[1].text.isNotEmpty) optionsControllers[1].clear();
                                  if (optionsControllers[2].text.isNotEmpty) optionsControllers[2].clear(); 
                                  if (optionsControllers[3].text.isNotEmpty) optionsControllers[3].clear();
                                });
                                return const SizedBox.shrink(); // Không cần build gì ở đây
                              }(),
                              // <<< CHỈ HIỂN THỊ ROW A/B >>>
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildTextFormField(controller: optionsControllers[0], labelText: 'Option A', hintText: 'True', readOnly: true, validator: (v)=>(v==null || v.isEmpty) ? 'Required' : null, /* No onChanged */)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTextFormField(controller: optionsControllers[1], labelText: 'Option B', hintText: 'False', readOnly: true, validator: (v)=>(v==null || v.isEmpty) ? 'Required' : null, /* No onChanged */)),
                                ],
                              ),
                              const SizedBox(height: 20), // Khoảng cách trước dropdown
                            ],
                          )
                        else if (isImages) // Hoặc chỉ cần else
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildTextFormField(controller: optionsControllers[0], labelText: 'Option A', hintText: 'Enter Image Url or Select Image', readOnly: false, validator: (v)=>(v==null || v.isEmpty) ? 'Required' : null, onChanged: (_) => stfSetState(() {}), suffixActionIcon: _buildSelectImageIcon(0),)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTextFormField(controller: optionsControllers[1], labelText: 'Option B', hintText: 'Enter Image Url or Select Image', readOnly: false, validator: (v)=>(v==null || v.isEmpty) ? 'Required' : null, onChanged: (_) => stfSetState(() {}), suffixActionIcon: _buildSelectImageIcon(1),)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: _buildTextFormField(controller: optionsControllers[2], labelText: 'Option C', hintText: 'Enter Image Url or Select Image', readOnly: false, onChanged: (_) => stfSetState(() {}), suffixActionIcon: _buildSelectImageIcon(2),)),
                                  const SizedBox(width: 16),
                                  Expanded(child: _buildTextFormField(controller: optionsControllers[3], labelText: 'Option D', hintText: 'Enter Image Url or Select Image', readOnly: false, onChanged: (_) => stfSetState(() {}), suffixActionIcon: _buildSelectImageIcon(3),)),
                                ],
                              ),
                               const SizedBox(height: 20), // Khoảng cách trước dropdown
                            ],
                          ),
                        
                        // --- DROPDOWN CORRECT ANSWER (Không đổi) --- 
                        _buildDropdownFormField<int>(
                          context: stfContext,
                          labelText: 'Correct Answer Index',
                          value: selectedCorrectAnswerIndex,
                          hintText: 'Select Correct Answer',
                          items: correctAnswerItems, 
                          onChanged: (newValue) {
                            stfSetState(() => selectedCorrectAnswerIndex = newValue);
                          },
                          validator: (v) => v == null ? 'Required' : null,
                          enabled: correctAnswerItems.isNotEmpty,
                        ),
                        const SizedBox(height: 20),

                        // ... (Explanation Editor và Nút Upload giữ nguyên) ...
                        const Text('Explanation (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              QuillSimpleToolbar(
                                controller: _quillController,
                                config: const QuillSimpleToolbarConfig(),
                              ),
                              const Divider(height: 1, thickness: 1),
                              SizedBox(
                                height: 150,
                                child: QuillEditor.basic(
                                  controller: _quillController,
                                  config: const QuillEditorConfig(
                                    padding: EdgeInsets.all(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        Center(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B9A), foregroundColor: Colors.white, minimumSize: const Size(200, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                            child: const Text('Upload Question', style: TextStyle(fontSize: 16)),
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                List<String> updatedOptions;
                                // Lấy options dựa trên loại đang chọn
                                if (selectedOptionType == OptionTypeOption.trueFalse) {
                                  updatedOptions = ['True', 'False'];
                                } else {
                                  updatedOptions = optionsControllers
                                      // Lấy cả 4 controller
                                      .take(isTrueFalse ? 2 : 4)
                                      .where((c) => c.text.trim().isNotEmpty) // Chỉ lấy những cái có text
                                      .map((c) => c.text)
                                      .toList();
                                }
                                
                                // Đảm bảo số lượng options tối thiểu là 2
                                if (updatedOptions.length < 2 && selectedOptionType != OptionTypeOption.trueFalse) {
                                  // Có thể hiển thị thông báo lỗi thay vì print
                                  print('Error: At least 2 options are required for Text Only or Images type.');
                                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                                    const SnackBar(content: Text('Error: At least 2 options required!'), backgroundColor: Colors.red),
                                  );
                                  return; // Ngăn không cho submit
                                }

                                final explanationJson = jsonEncode(_quillController.document.toDelta().toJson());
                                final newQuestion = {
                                  'categoryId': selectedCategoryId,
                                  'quizId': selectedQuizId,
                                  'title': titleController.text,
                                  'questionType': selectedQuestionType.toString().split('.').last,
                                  'optionType': selectedOptionType.toString().split('.').last, // Lưu loại option
                                  'options': updatedOptions,
                                  'correctAnswerIndex': selectedCorrectAnswerIndex,
                                  'explanation': explanationJson,
                                };
                                print('New Question data: $newQuestion');
                                if (!mounted) return;
                                Navigator.of(dialogContext).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Question added (dummy)!')),
                                );
                                // TODO: Thêm vào danh sách hoặc gọi API thực tế
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

  void _handleImportQuestions() {
    // print('Import Questions button pressed');
    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(content: Text('Import Questions - Not implemented yet!')),
    // );
    // <<< GỌI DIALOG MỚI >>>
    _showImportQuestionsDialog(); 
  }

  void _handleEditQuestion(QuestionInfo question) {
    // TODO: Implement Edit Question dialog/screen
    print('Edit question: ${question.title}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit action for ${question.title} - Implement me!')),
    );
  }

  void _handleDeleteQuestion(QuestionInfo question) {
    print('Delete question: ${question.title}');
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this question?\n"${question.title}"'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () {
                // TODO: Implement actual delete logic here
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Delete action for ${question.title} - Implement me!')),
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // --- Dialog Chỉnh sửa Câu hỏi --- 
  Future<void> _showEditQuestionDialog(QuestionInfo question) async {
    final formKey = GlobalKey<FormState>();
    
    // Controllers
    final titleController = TextEditingController(text: question.title);
    final optionsControllers = List.generate(4, (index) => 
        TextEditingController(text: index < question.options.length ? question.options[index] : '')
    );

    // State variables for dialog
    String? selectedCategoryId; 
    String? selectedQuizId;   
    QuestionTypeOption? selectedQuestionType;
    OptionTypeOption? selectedOptionType = OptionTypeOption.textOnly; 
    int? selectedCorrectAnswerIndex; 
    late QuillController _quillController;

    // Tìm Quiz và Category ID ban đầu (ví dụ)
    final initialQuiz = _dummyQuizzesDropdown.firstWhere((q) => q.name == question.quizName, orElse: () => _dummyQuizzesDropdown.first); // Fallback
    selectedQuizId = initialQuiz.id;
    selectedCategoryId = initialQuiz.categoryId;

    // Chuyển đổi questionType từ String sang Enum (ví dụ)
    switch (question.questionType) {
      case 'Fill in the Blanks': selectedQuestionType = QuestionTypeOption.fillInTheBlanks; break;
      case 'Text Only': selectedQuestionType = QuestionTypeOption.textOnly; break;
      case 'True/False': selectedQuestionType = QuestionTypeOption.trueFalse; break;
      case 'Multiple Choice': selectedQuestionType = QuestionTypeOption.multiChoice; break;
      case 'Image': selectedQuestionType = QuestionTypeOption.image; break;
      case 'Audio': selectedQuestionType = QuestionTypeOption.audio; break;
      case 'Video': selectedQuestionType = QuestionTypeOption.video; break;
      default: selectedQuestionType = QuestionTypeOption.textOnly; // Fallback
    }

    // <<< TẠM THỜI: Cần thêm trường optionType vào QuestionInfo >>>
    selectedOptionType = OptionTypeOption.textOnly; 

    // Khởi tạo Quill Controller (BẠN CẦN THÊM LẠI TRƯỜNG explanation VÀO MODEL)
    try {
      // <<< BỎ COMMENT NHỮNG DÒNG NÀY SAU KHI BẠN CẬP NHẬT MODEL >>>
      // final initialDoc = question.explanation.isNotEmpty 
      //     ? Document.fromJson(jsonDecode(question.explanation)) 
      //     : Document(); 
      // Tạm thời khởi tạo rỗng vì trường explanation đã bị xóa
      final initialDoc = Document();
      _quillController = QuillController(document: initialDoc, selection: const TextSelection.collapsed(offset: 0));
    } catch (e) {
      print('Error initializing Quill controller: $e');
      _quillController = QuillController.basic(); 
    }
 
    // Lọc danh sách Quiz ban đầu theo Category đã chọn
    List<QuizInfoForDropdown> filteredQuizzes = _dummyQuizzesDropdown
        .where((quiz) => quiz.categoryId == selectedCategoryId).toList();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
             // <<< KHÔI PHỤC ĐỊNH NGHĨA correctAnswerItems >>>
             // <<< XÓA LOGIC CŨ, THAY BẰNG LOGIC MỚI >>>
             // bool isTrueFalse = selectedOptionType == OptionTypeOption.trueFalse;
             // ... (Tự động điền và khóa)
             // if (isTrueFalse) {
             //    if (optionsControllers[0].text != 'True') optionsControllers[0].text = 'True';
             //    if (optionsControllers[1].text != 'False') optionsControllers[1].text = 'False';
             //    // Không clear Option C, D để giữ lại nội dung nếu có
             // }
             // // Tạo danh sách item cho Correct Answer Dropdown (Sửa lại hiển thị)
             // final correctAnswerItems = optionsControllers
             //   .asMap()
             //   .entries
             //   .where((entry) => isTrueFalse ? entry.key < 2 : entry.value.text.trim().isNotEmpty)
             //   .map((entry) {
             //     final index = entry.key;
             //     final label = String.fromCharCode('A'.codeUnitAt(0) + index);
             //     return DropdownMenuItem<int>(
             //       value: index,
             //       child: Text('Option $label'),
             //     );
             //   }).toList();
             // if (selectedCorrectAnswerIndex != null) {
             //    if (isTrueFalse && selectedCorrectAnswerIndex! > 1) {
             //       selectedCorrectAnswerIndex = null;
             //    } 
             //    // <<< SỬA LẠI TRUY CẬP correctAnswerItems >>>
             //    else if (!isTrueFalse && !correctAnswerItems.any((item) => item.value == selectedCorrectAnswerIndex)) {
             //       selectedCorrectAnswerIndex = null;
             //    }
             // }

             // --- LOGIC MỚI (Tương tự Add Dialog) ---
             final isTextOnly = selectedOptionType == OptionTypeOption.textOnly;
             final isTrueFalse = selectedOptionType == OptionTypeOption.trueFalse;
             final isImages = selectedOptionType == OptionTypeOption.images;

             // <<< XÓA KHỐI NÀY - Sẽ xử lý trong if (isTrueFalse) >>>
             // if (isTrueFalse) {
             //    // Không cần addPostFrameCallback ở đây vì edit đã có giá trị ban đầu
             //    if (optionsControllers[0].text != 'True') optionsControllers[0].text = 'True';
             //    if (optionsControllers[1].text != 'False') optionsControllers[1].text = 'False';
             //    if (optionsControllers[2].text.isNotEmpty) optionsControllers[2].clear();
             //    if (optionsControllers[3].text.isNotEmpty) optionsControllers[3].clear();
             // }

             // --- Tạo danh sách mục cho Dropdown Correct Answer ---
             final correctAnswerItems = optionsControllers
                .asMap()
                .entries
                .where((entry) {
                  final index = entry.key;
                  final controller = entry.value;
                  if (isTrueFalse) return index < 2;
                  return controller.text.trim().isNotEmpty;
                })
                .map((entry) {
                  final index = entry.key;
                  final label = String.fromCharCode('A'.codeUnitAt(0) + index);
                  // <<< SỬA LOGIC HIỂN THỊ TEXT CHO TRUE/FALSE >>>
                  final String optionTextSuffix = isTrueFalse 
                      ? (index == 0 ? ': True' : ': False') // Hiển thị True/False cố định
                      : ''; // Không hiển thị gì thêm cho loại khác
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text('Option $label$optionTextSuffix')
                  );
                })
                .toList();

              // --- DEBUG PRINT --- 
              // if (!isTrueFalse) {
              //   print("DEBUG (Edit): Building Dropdown for Text/Image");
              //   print("  Option C Text: [${optionsControllers[2].text}] (isEmpty: ${optionsControllers[2].text.trim().isEmpty})");
              //   print("  Option D Text: [${optionsControllers[3].text}] (isEmpty: ${optionsControllers[3].text.trim().isEmpty})");
              //   print("  Generated Correct Answer Items Count: ${correctAnswerItems.length}");
              //   print("  Correct Answer Items Values: ${correctAnswerItems.map((item) => item.value).toList()}");
              // }
              // --- END DEBUG PRINT --- 

              if (selectedCorrectAnswerIndex != null && 
                  !correctAnswerItems.any((item) => item.value == selectedCorrectAnswerIndex)) {
                 selectedCorrectAnswerIndex = null;
              }

              Widget _buildSelectImageIcon(int index) {
                 // ... (Giống Add Dialog) ... // <<< CẬP NHẬT CODE Ở ĐÂY >>>
                  return IconButton(
                    icon: const Icon(Icons.image_outlined, color: Colors.grey),
                    tooltip: 'Select Image for Option ${String.fromCharCode('A'.codeUnitAt(0) + index)}',
                    splashRadius: 20,
                    onPressed: () async { 
                      final ImagePicker picker = ImagePicker();
                      final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        stfSetState(() {
                          optionsControllers[index].text = pickedFile.path;
                        });
                      } else {
                         print('Image selection cancelled for option $index');
                      }
                    },
                  );
               }
             // --- KẾT THÚC LOGIC MỚI ---

            return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                title: Row( // Thêm title và nút close
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Edit Question', style: TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
                content: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6, 
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                               Expanded(
                                 child: _buildDropdownFormField<String>(
                                   context: stfContext,
                                   labelText: 'Category',
                                   value: selectedCategoryId,
                                   hintText: 'Select Category',
                                   items: _dummyCategories.map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name))).toList(),
                                   onChanged: (newValue) {
                                     stfSetState(() {
                                       selectedCategoryId = newValue;
                                       selectedQuizId = null; 
                                       filteredQuizzes = _dummyQuizzesDropdown.where((quiz) => quiz.categoryId == selectedCategoryId).toList();
                                     });
                                   },
                                   validator: (v) => v == null ? 'Required' : null,
                                 ),
                               ),
                               const SizedBox(width: 16),
                               Expanded(
                                 child: _buildDropdownFormField<String>(
                                   context: stfContext,
                                   labelText: 'Quiz Name',
                                   value: selectedQuizId,
                                   hintText: selectedCategoryId == null ? 'Select Category First' : 'Select Quiz',
                                   items: filteredQuizzes.map((quiz) => DropdownMenuItem(value: quiz.id, child: Text(quiz.name))).toList(),
                                   // <<< Sửa lại cách truyền onChanged >>>
                                   onChanged: selectedCategoryId == null ? null : (newValue) { 
                                     stfSetState(() => selectedQuizId = newValue);
                                   },
                                   validator: (v) => v == null ? 'Required' : null,
                                   // <<< Thêm lại enabled cho dropdown helper >>>
                                   enabled: selectedCategoryId != null,
                                 ),
                               ),
                             ],
                          ),
                          const SizedBox(height: 20),
                          _buildDropdownFormField<QuestionTypeOption>(
                              context: stfContext,
                              labelText: 'Question Type',
                              value: selectedQuestionType,
                              hintText: 'Select Question Type',
                              items: QuestionTypeOption.values.map((type) {
                                String text;
                                switch(type) {
                                  case QuestionTypeOption.fillInTheBlanks: text = 'Fill in the Blanks'; break;
                                  case QuestionTypeOption.textOnly: text = 'Text Only'; break;
                                  case QuestionTypeOption.trueFalse: text = 'True/False'; break;
                                  case QuestionTypeOption.multiChoice: text = 'Multiple Choice'; break;
                                  case QuestionTypeOption.image: text = 'Image'; break;
                                  case QuestionTypeOption.audio: text = 'Audio'; break;
                                  case QuestionTypeOption.video: text = 'Video'; break;
                                }
                                return DropdownMenuItem(
                                  value: type,
                                  child: Text(text) 
                                );
                              }).toList(),
                              onChanged: (newValue) {
                                stfSetState(() => selectedQuestionType = newValue);
                              },
                              validator: (v) => v == null ? 'Required' : null,
                          ), 
                          const SizedBox(height: 20),
                          _buildTextFormField(
                              controller: titleController, 
                              labelText: 'Question Title', // Bỏ phần ghi chú
                              hintText: 'Enter question title here',
                              maxLines: 3,
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ), 
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              const Text('Option Type:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                              const SizedBox(width: 12),
                              // <<< Đảm bảo lặp qua TẤT CẢ các giá trị enum >>>
                              ...OptionTypeOption.values.map((type) {
                                String label;
                                // <<< Switch case phải bao gồm images >>>
                                switch (type) {
                                  case OptionTypeOption.textOnly: label = 'Text Only'; break;
                                  case OptionTypeOption.trueFalse: label = 'True/False'; break;
                                  case OptionTypeOption.images: label = 'Images'; break; 
                                }
                                return Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<OptionTypeOption>(
                                      value: type,
                                      groupValue: selectedOptionType,
                                      onChanged: (OptionTypeOption? value) {
                                        if (value != null) {
                                          stfSetState(() {
                                            selectedOptionType = value;
                                            // Đặt lại đáp án đúng khi đổi loại
                                            selectedCorrectAnswerIndex = null;
                                          });
                                        }
                                      },
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    Text(label),
                                    // Thêm khoảng cách nếu không phải item cuối
                                    if (type != OptionTypeOption.values.last) const SizedBox(width: 12),
                                  ],
                                );
                              }).toList(),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // --- HIỂN THỊ OPTIONS A, B, C, D THEO LOẠI --- 
                          if (isTextOnly)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildTextFormField(controller: optionsControllers[0], labelText: 'Option A', hintText: 'Enter Option Name', readOnly: false, validator: (v)=>(v==null || v.isEmpty) ? 'Required' : null, onChanged: (_) => stfSetState(() {}),)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildTextFormField(controller: optionsControllers[1], labelText: 'Option B', hintText: 'Enter Option Name', readOnly: false, validator: (v)=>(v==null || v.isEmpty) ? 'Required' : null, onChanged: (_) => stfSetState(() {}),)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildTextFormField(controller: optionsControllers[2], labelText: 'Option C', hintText: 'Enter Option Name', readOnly: false, onChanged: (_) => stfSetState(() {}),)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildTextFormField(controller: optionsControllers[3], labelText: 'Option D', hintText: 'Enter Option Name', readOnly: false, onChanged: (_) => stfSetState(() {}),)),
                                  ],
                                ),
                                 const SizedBox(height: 20), // Khoảng cách trước dropdown
                              ],
                            )
                          else if (isTrueFalse)
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Tự động set text và readOnly cho True/False ở đây
                                // <<< KHÔI PHỤC KHỐI WIDGETSBINDING ĐỂ XÓA TEXT >>>
                                () { // Sử dụng hàm ẩn danh để chạy một lần
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    // Chỉ xóa, không set text nữa
                                    if (optionsControllers[0].text.isNotEmpty) optionsControllers[0].clear(); 
                                    if (optionsControllers[1].text.isNotEmpty) optionsControllers[1].clear();
                                    if (optionsControllers[2].text.isNotEmpty) optionsControllers[2].clear(); 
                                    if (optionsControllers[3].text.isNotEmpty) optionsControllers[3].clear();
                                  });
                                  return const SizedBox.shrink(); // Không cần build gì ở đây
                                }(),
                                // <<< CHỈ HIỂN THỊ ROW A/B >>>
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildTextFormField(controller: optionsControllers[0], labelText: 'Option A', hintText: 'True', readOnly: true, validator: (v)=>(v==null || v.isEmpty) ? 'Required' : null, /* No onChanged */)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildTextFormField(controller: optionsControllers[1], labelText: 'Option B', hintText: 'False', readOnly: true, validator: (v)=>(v==null || v.isEmpty) ? 'Required' : null, /* No onChanged */)),
                                  ],
                                ),
                                const SizedBox(height: 20), // Khoảng cách trước dropdown
                              ],
                            )
                          else if (isImages) // Hoặc chỉ cần else
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildTextFormField(controller: optionsControllers[0], labelText: 'Option A', hintText: 'Enter Image Url or Select Image', readOnly: false, validator: (v)=>(v==null || v.isEmpty) ? 'Required' : null, onChanged: (_) => stfSetState(() {}), suffixActionIcon: _buildSelectImageIcon(0),)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildTextFormField(controller: optionsControllers[1], labelText: 'Option B', hintText: 'Enter Image Url or Select Image', readOnly: false, validator: (v)=>(v==null || v.isEmpty) ? 'Required' : null, onChanged: (_) => stfSetState(() {}), suffixActionIcon: _buildSelectImageIcon(1),)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: _buildTextFormField(controller: optionsControllers[2], labelText: 'Option C', hintText: 'Enter Image Url or Select Image', readOnly: false, onChanged: (_) => stfSetState(() {}), suffixActionIcon: _buildSelectImageIcon(2),)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildTextFormField(controller: optionsControllers[3], labelText: 'Option D', hintText: 'Enter Image Url or Select Image', readOnly: false, onChanged: (_) => stfSetState(() {}), suffixActionIcon: _buildSelectImageIcon(3),)),
                                  ],
                                ),
                                 const SizedBox(height: 20), // Khoảng cách trước dropdown
                              ],
                            ),
                          
                          // --- DROPDOWN CORRECT ANSWER (Không đổi) --- 
                          _buildDropdownFormField<int>(/* Correct Answer */
                              context: stfContext,
                              labelText: 'Correct Answer Index',
                              value: selectedCorrectAnswerIndex,
                              hintText: 'Select Correct Answer',
                              items: correctAnswerItems, 
                              onChanged: (newValue) {
                                stfSetState(() => selectedCorrectAnswerIndex = newValue);
                              },
                              validator: (v) => v == null ? 'Required' : null,
                          ), 
                          const SizedBox(height: 20),
                          
                          // <<< KHÔI PHỤC EXPLANATION EDITOR >>>
                          const Text('Explanation (Optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Container(
                             decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!), 
                                borderRadius: BorderRadius.circular(8),
                             ),
                             child: Column(
                                children: [
                                   QuillSimpleToolbar(
                                      controller: _quillController,
                                      config: const QuillSimpleToolbarConfig(
                                      ),
                                   ),
                                   const Divider(height: 1, thickness: 1),
                                   SizedBox(
                                      height: 150, 
                                      child: QuillEditor.basic(
                                         controller: _quillController,
                                         config: const QuillEditorConfig(
                                           padding: EdgeInsets.all(12),
                                         ),
                                      ),
                                   ),
                                ],
                             ),
                          ),
                          const SizedBox(height: 30),

                          // --- Update Button (Sử dụng lại các biến state đã khôi phục) ---
                          Center(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B9A), foregroundColor: Colors.white, minimumSize: const Size(200, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              child: const Text('Update Question', style: TextStyle(fontSize: 16)),
                              onPressed: () {
                                if (formKey.currentState!.validate()) {
                                  // ... (Logic lấy updatedOptions giữ nguyên) ...
                                  List<String> updatedOptions;
                                  if (selectedOptionType == OptionTypeOption.trueFalse) {
                                    updatedOptions = ['True', 'False'];
                                  } else {
                                    updatedOptions = optionsControllers
                                        .where((c) => c.text.isNotEmpty)
                                        .map((c) => c.text)
                                        .toList();
                                  }
                                  
                                  // <<< KHÔI PHỤC LẤY EXPLANATION >>>
                                  final explanationJson = jsonEncode(_quillController.document.toDelta().toJson());

                                  final updatedData = {
                                    'id': question.id,
                                    'quizId': selectedQuizId,
                                    'title': titleController.text,
                                    'questionType': selectedQuestionType.toString().split('.').last,
                                    'optionType': selectedOptionType.toString().split('.').last,
                                    'options': updatedOptions, 
                                    // <<< KHÔI PHỤC CORRECT ANSWER & EXPLANATION >>>
                                    'correctAnswerIndex': selectedCorrectAnswerIndex,
                                    'explanation': explanationJson,
                                  };
                                  print('Full Question data to update: $updatedData');
                                  if (!mounted) return;
                                  Navigator.of(dialogContext).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Question updated (dummy)!')), 
                                  );
                                  // TODO: Implement actual update logic (API call)
                                } else { print('Validation failed'); }
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

  // --- Dialog Nhập Câu hỏi --- 
  Future<void> _showImportQuestionsDialog() async {
    String? selectedCategoryId;
    String? selectedQuizId;
    PlatformFile? selectedFile;
    List<QuizInfoForDropdown> filteredQuizzes = [];
    bool isLoading = false; // State để quản lý trạng thái loading khi upload

    await showDialog<void>(
      context: context,
      barrierDismissible: !isLoading, // Không cho đóng khi đang tải lên
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (stfContext, stfSetState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Import Questions (Bulk Upload)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    // Vô hiệu hóa nút đóng khi đang tải
                    onPressed: isLoading ? null : () => Navigator.of(dialogContext).pop(),
                  ),
                ],
              ),
              content: SizedBox(
                 width: MediaQuery.of(context).size.width * 0.5, // Điều chỉnh độ rộng dialog
                 child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                       // --- Dropdowns Category & Quiz --- 
                       Row(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Expanded(
                             child: _buildDropdownFormField<String>(
                               context: stfContext,
                               labelText: 'Category',
                               value: selectedCategoryId,
                               hintText: 'Select Category',
                               items: _dummyCategories.map((cat) => DropdownMenuItem(value: cat.id, child: Text(cat.name))).toList(),
                               onChanged: isLoading ? null : (newValue) { // Vô hiệu hóa khi tải
                                 stfSetState(() {
                                   selectedCategoryId = newValue;
                                   selectedQuizId = null; 
                                   filteredQuizzes = _dummyQuizzesDropdown.where((quiz) => quiz.categoryId == selectedCategoryId).toList();
                                 });
                               },
                               validator: (v) => v == null ? 'Required' : null,
                             ),
                           ),
                           const SizedBox(width: 16),
                           Expanded(
                             child: _buildDropdownFormField<String>(
                               context: stfContext,
                               labelText: 'Quiz', // Đổi label
                               value: selectedQuizId,
                               hintText: selectedCategoryId == null ? 'Select Category First' : 'Select Quiz Name',
                               items: filteredQuizzes.map((quiz) => DropdownMenuItem(value: quiz.id, child: Text(quiz.name))).toList(),
                               onChanged: isLoading || selectedCategoryId == null ? null : (newValue) { 
                                 stfSetState(() => selectedQuizId = newValue);
                               },
                               validator: (v) => v == null ? 'Required' : null,
                               enabled: !isLoading && selectedCategoryId != null, 
                             ),
                           ),
                         ],
                       ),
                       const SizedBox(height: 24),

                       // --- Phần Chọn File --- 
                       const Text('Select File (CSV)', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
                       const SizedBox(height: 8),
                       RichText(
                         text: TextSpan(
                            style: DefaultTextStyle.of(context).style.copyWith(color: Colors.grey[600], fontSize: 13),
                            children: <TextSpan>[
                              const TextSpan(text: 'Only CSV files are supported. Please follow the '),
                              TextSpan(
                                text: 'instructions',
                                style: const TextStyle(
                                  color: Colors.purple, // Màu tím
                                  decoration: TextDecoration.underline, // Gạch chân
                                  fontWeight: FontWeight.w500,
                                ),
                                // recognizer: TapGestureRecognizer()..onTap = () {
                                //    print('Instructions link tapped - TODO: Implement opening docs');
                                //    // TODO: Mở link tài liệu hướng dẫn ở đây
                                // },
                              ),
                              const TextSpan(text: ' and download our demo templates before uploading any files.'),
                            ],
                         ),
                       ),
                       const SizedBox(height: 16),
                       // Vùng chọn file
                       Container(
                         height: 150,
                         width: double.infinity,
                         // TODO: Thêm dashed border (có thể dùng package dotted_border)
                         decoration: BoxDecoration(
                           border: Border.all(color: Colors.grey[300]!), 
                           borderRadius: BorderRadius.circular(8),
                           color: Colors.grey[50],
                         ),
                         child: Center(
                           child: selectedFile == null
                             ? ElevatedButton.icon(
                                 icon: const Icon(Icons.upload_file, size: 20),
                                 label: const Text('Select File'),
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: Colors.grey[200],
                                   foregroundColor: Colors.black87,
                                   elevation: 0,
                                 ),
                                 // Vô hiệu hóa nút khi đang tải
                                 onPressed: isLoading ? null : () async {
                                   FilePickerResult? result = await FilePicker.platform.pickFiles(
                                     type: FileType.custom,
                                     allowedExtensions: ['csv'],
                                   );
                                   if (result != null && result.files.single != null) {
                                     stfSetState(() {
                                       selectedFile = result.files.single;
                                     });
                                   } else {
                                     // User canceled the picker
                                     print('File selection cancelled.');
                                   }
                                 },
                               )
                             : Column(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   Icon(Icons.check_circle_outline, color: Colors.green[600], size: 32),
                                   const SizedBox(height: 8),
                                   Text(
                                     selectedFile!.name, 
                                     style: const TextStyle(fontWeight: FontWeight.w500),
                                     textAlign: TextAlign.center,
                                     overflow: TextOverflow.ellipsis,
                                     maxLines: 2,
                                   ),
                                   const SizedBox(height: 4),
                                   Text('(${(selectedFile!.size / 1024).toStringAsFixed(1)} KB)', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                   // Nút xóa file đã chọn (chỉ hiển thị khi không loading)
                                   if (!isLoading)
                                     TextButton.icon(
                                       icon: const Icon(Icons.close, size: 16), 
                                       label: const Text('Remove'),
                                       style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
                                       onPressed: () => stfSetState(() => selectedFile = null),
                                     ),
                                 ],
                               ), 
                         ),
                       ),
                       const SizedBox(height: 30),

                       // --- Nút Upload --- 
                       Center(
                         child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B9A),
                              foregroundColor: Colors.white,
                              minimumSize: const Size(200, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              // Thay đổi giao diện khi đang loading
                              disabledBackgroundColor: Colors.grey[400],
                              disabledForegroundColor: Colors.grey[700],
                            ),
                            // Vô hiệu hóa nút khi đang tải hoặc chưa đủ thông tin
                            onPressed: isLoading || selectedFile == null || selectedQuizId == null 
                              ? null 
                              : () async {
                                  stfSetState(() => isLoading = true);
                                  String? errorMessage;
                                  bool uploadSuccess = false;

                                  try {
                                    print('Starting upload for file: ${selectedFile!.name}, Quiz ID: $selectedQuizId');

                                    // --- 1. Đọc nội dung file CSV --- 
                                    String csvString;
                                    // FilePicker trả về path cho mobile/desktop, bytes cho web
                                    if (selectedFile!.path != null) {
                                      // Đọc từ path (Mobile/Desktop)
                                      final file = File(selectedFile!.path!);
                                      csvString = await file.readAsString();
                                    } else if (selectedFile!.bytes != null) {
                                      // Đọc từ bytes (Web)
                                      csvString = utf8.decode(selectedFile!.bytes!); 
                                    } else {
                                      throw Exception('Cannot read file content.');
                                    }

                                    // --- 2. Parse dữ liệu CSV --- 
                                    // Bỏ qua dòng header nếu có (rowAsMapConverter tự xử lý nếu có header)
                                    // Hoặc dùng CsvToListConverter và bỏ qua dòng đầu tiên [0]
                                    final List<List<dynamic>> rowsAsListOfValues = 
                                        const CsvToListConverter(eol: '\n', fieldDelimiter: ',')
                                        .convert(csvString);
                                    
                                    // Bỏ dòng header nếu có (ví dụ kiểm tra tên cột đầu tiên)
                                    if (rowsAsListOfValues.isNotEmpty && rowsAsListOfValues[0][0].toLowerCase() == 'title') { // Giả sử cột đầu là title
                                      rowsAsListOfValues.removeAt(0);
                                    }

                                    if (rowsAsListOfValues.isEmpty) {
                                      throw Exception('CSV file is empty or contains only headers.');
                                    }

                                    // --- 3. Chuyển đổi thành List<Map> để gửi API --- 
                                    // *** QUAN TRỌNG: Điều chỉnh tên cột và logic chuyển đổi cho phù hợp với file CSV và API của bạn ***
                                    List<Map<String, dynamic>> questionsToUpload = [];
                                    for (var row in rowsAsListOfValues) {
                                       try {
                                           // Giả sử cấu trúc CSV: title, questionType, optionType, optionA, optionB, optionC, optionD, correctAnswerIndex, explanation
                                          if (row.length < 9) throw FormatException('Invalid row length');

                                          List<String> options = [];
                                          if (row[3] != null && row[3].toString().trim().isNotEmpty) options.add(row[3].toString().trim());
                                          if (row[4] != null && row[4].toString().trim().isNotEmpty) options.add(row[4].toString().trim());
                                          if (row[5] != null && row[5].toString().trim().isNotEmpty) options.add(row[5].toString().trim());
                                          if (row[6] != null && row[6].toString().trim().isNotEmpty) options.add(row[6].toString().trim());
                                          
                                          // Xử lý correctAnswerIndex (cần là số nguyên)
                                          int? correctIndex = int.tryParse(row[7].toString());
                                          if (correctIndex == null) throw FormatException('Invalid correct answer index');

                                          questionsToUpload.add({
                                            'title': row[0].toString().trim(),
                                            'questionType': row[1].toString().trim(), // Ví dụ: 'TextOnly', 'Image', ...
                                            'optionType': row[2].toString().trim(), // Ví dụ: 'textOnly', 'images', ...
                                            'options': options,
                                            'correctAnswerIndex': correctIndex,
                                            'explanation': row[8]?.toString().trim() ?? '' // Xử lý explanation null
                                          });
                                       } catch (e) {
                                         print('Error parsing row: $row - $e');
                                         throw Exception('Error parsing CSV data. Check file format and content.'); 
                                       }
                                    }

                                    if (questionsToUpload.isEmpty) {
                                       throw Exception('No valid questions found in the CSV file.');
                                    }

                                    // --- 4. Gửi dữ liệu lên API endpoint --- 
                                    // *** THAY THẾ BẰNG API ENDPOINT THỰC TẾ CỦA BẠN ***
                                    final url = Uri.parse('YOUR_API_BASE_URL/api/quizzes/$selectedQuizId/questions/import'); 
                                    
                                    // *** LẤY AUTH TOKEN (Ví dụ) ***
                                    // final String? token = await _getAuthToken(); // Hàm lấy token của bạn
                                    const String? token = 'YOUR_AUTH_TOKEN'; // Tạm thời dùng placeholder
                                    if (token == null) {
                                      throw Exception('Authentication token not found.');
                                    }

                                    print('Sending ${questionsToUpload.length} questions to $url');

                                    final response = await http.post(
                                      url,
                                      headers: {
                                        'Content-Type': 'application/json; charset=UTF-8',
                                        'Authorization': 'Bearer $token',
                                      },
                                      body: jsonEncode(questionsToUpload), // Encode list thành JSON
                                    );

                                    // --- 5. Xử lý kết quả trả về --- 
                                    if (response.statusCode == 200 || response.statusCode == 201) { // Hoặc mã thành công khác
                                      print('Upload successful: ${response.body}');
                                      uploadSuccess = true; 
                                    } else {
                                      print('Upload failed: ${response.statusCode} - ${response.body}');
                                      // Cố gắng parse lỗi từ body nếu có
                                      String serverError = 'Upload failed. Status code: ${response.statusCode}';
                                      try {
                                         final errorBody = jsonDecode(response.body);
                                         serverError = errorBody['message'] ?? serverError; 
                                      } catch(_){}
                                      throw Exception(serverError);
                                    }

                                  } catch (e) {
                                    print('Upload process error: $e');
                                    errorMessage = e.toString();
                                    // Bỏ tiền tố "Exception: " nếu có
                                    if (errorMessage != null && errorMessage.startsWith('Exception: ')) {
                                      errorMessage = errorMessage.substring(11);
                                    }
                                  } finally {
                                    stfSetState(() => isLoading = false);
                                    // --- Hiển thị thông báo và đóng dialog --- 
                                    if (!stfContext.mounted) return;
                                    if (uploadSuccess) {
                                      Navigator.of(dialogContext).pop(); // Đóng dialog nếu thành công
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Questions imported successfully!'), backgroundColor: Colors.green),
                                      );
                                      // TODO: Có thể cần refresh lại danh sách câu hỏi ở màn hình chính
                                    } else {
                                      ScaffoldMessenger.of(dialogContext).showSnackBar(
                                        SnackBar(content: Text(errorMessage ?? 'An unknown error occurred during upload.'), backgroundColor: Colors.red),
                                      );
                                    }
                                  }
                                },
                            child: isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                              : const Text('Upload', style: TextStyle(fontSize: 16)),
                         ),
                       ),
                    ],
                  ),
                 ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const primaryColor = Color(0xFF6A1B9A); // Tím

    // TODO: Logic lọc/sắp xếp displayedQuestions dựa trên _selectedSortOption
    List<QuestionInfo> displayedQuestions = _dummyQuestions;

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
                'All Questions',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _handleAddQuestion,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Question'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _handleImportQuestions,
                    icon: const Icon(Icons.upload_file_outlined, size: 18), // Icon import
                    label: const Text('Import Questions'),
                     style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                   const SizedBox(width: 12),
                   // --- Sort By Button ---
                  PopupMenuButton<String>(
                    tooltip: 'Sort Questions',
                    onSelected: (String result) {
                      setState(() {
                        _selectedSortOption = result;
                        // TODO: Trigger data reload/refilter
                        print('Selected sort: $_selectedSortOption');
                      });
                    },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(value: 'Newest First', child: Text('Newest First')),
                      const PopupMenuItem<String>(value: 'Oldest First', child: Text('Oldest First')),
                      const PopupMenuItem<String>(value: 'By Quiz Name', child: Text('By Quiz Name')),
                      // Add more sort options
                    ],
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), 
                      decoration: BoxDecoration(
                         color: Colors.grey[200], 
                         borderRadius: BorderRadius.circular(8),
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
                boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 3, offset: const Offset(0, 1))],
              ),
              child: SingleChildScrollView( 
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey[50]),
                  headingTextStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                  columnSpacing: 30.0, // Điều chỉnh khoảng cách
                  dataRowHeight: 56.0, // Điều chỉnh chiều cao hàng
                  columns: const <DataColumn>[
                    DataColumn(label: Text('Question Title')),
                    DataColumn(label: Text('Options')),
                    DataColumn(label: Text('Question Type')),
                    DataColumn(label: Text('Quiz Name')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: displayedQuestions.map((question) => DataRow(
                    cells: <DataCell>[
                      DataCell( Text(question.title, overflow: TextOverflow.ellipsis, maxLines: 2) ), // Giới hạn nội dung dài
                      DataCell( Text(question.options.join(', '), overflow: TextOverflow.ellipsis) ), // Hiển thị options, nối bằng dấu phẩy
                      DataCell( Text(question.questionType) ),
                      DataCell( Text(question.quizName) ),
                      DataCell(
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Tooltip(
                              message: 'Edit Question',
                              child: InkWell(
                                onTap: () => _showEditQuestionDialog(question),
                                customBorder: const CircleBorder(),
                                child: Container(
                                   padding: const EdgeInsets.all(7), 
                                   decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
                                   child: const Icon(Icons.edit_outlined, size: 19, color: Colors.blue)
                                ),
                              ),
                            ),
                             const SizedBox(width: 10), 
                            Tooltip(
                              message: 'Delete Question',
                              child: InkWell(
                                 onTap: () => _handleDeleteQuestion(question),
                                 customBorder: const CircleBorder(),
                                 child: Container(
                                   padding: const EdgeInsets.all(7), 
                                   decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                                   child: const Icon(Icons.delete_outline, size: 19, color: Colors.red)
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: _buildPaginationControls(), // Sử dụng lại hàm phân trang
          ), 
        ],
      ),
    );
  }

   // Widget xây dựng phần điều khiển phân trang (Placeholder - copy từ QuizzesScreen nếu chưa có)
   // Cần điều chỉnh totalItems dựa trên displayedQuestions.length
   Widget _buildPaginationControls() {
     const totalItems = 5; // Ví dụ - Cần lấy từ dữ liệu thật
     const itemsPerPage = 10;
     const currentPage = 1; 

     final totalPages = (totalItems / itemsPerPage).ceil();
     final startItem = (currentPage - 1) * itemsPerPage + 1;
     final endItem = (startItem + itemsPerPage - 1) > totalItems ? totalItems : (startItem + itemsPerPage - 1);

     return Row(
       children: [
         Text('Showing $startItem–$endItem of $totalItems', style: TextStyle(color: Colors.grey[600])),
         const Spacer(), 
         IconButton(
           icon: const Icon(Icons.chevron_left),
           onPressed: currentPage > 1 ? () { /* TODO: Go to previous page */ } : null, 
           tooltip: 'Previous Page',
           splashRadius: 20,
           iconSize: 24,
         ),
         const SizedBox(width: 8), 
         IconButton(
           icon: const Icon(Icons.chevron_right),
           onPressed: currentPage < totalPages ? () { /* TODO: Go to next page */ } : null, 
           tooltip: 'Next Page',
           splashRadius: 20,
           iconSize: 24,
         ),
       ],
     );
   }

   // --- Widget Helpers (Copy và chỉnh sửa từ quizzes_screen nếu cần) --- 

   Widget _buildTextFormField({
     required TextEditingController controller,
     required String labelText,
     String? hintText,
     int maxLines = 1,
     TextInputType keyboardType = TextInputType.text,
     String? Function(String?)? validator,
     bool readOnly = false,
     ValueChanged<String>? onChanged,
     Widget? suffixActionIcon,
   }) {
     return TextFormField(
       controller: controller,
       readOnly: readOnly,
       keyboardType: keyboardType,
       maxLines: maxLines,
       decoration: InputDecoration(
         labelText: labelText,
         hintText: hintText,
         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
         suffixIcon: Builder( // Sử dụng Builder để context không bị lỗi
           builder: (context) {
             Widget? clearButton;
             // Chỉ tạo nút clear nếu không phải readOnly
             if (!readOnly) {
               clearButton = IconButton(
                 icon: const Icon(Icons.clear, size: 20, color: Colors.grey), // Màu xám nhẹ
                 tooltip: 'Clear',
                 splashRadius: 18,
                 onPressed: () {
                   // Chỉ clear và gọi onChanged nếu thực sự có text
                   if (controller.text.isNotEmpty) {
                      controller.clear();
                      if (onChanged != null) onChanged('');
                   }
                 },
               );
             }

             // Kết hợp nút clear và nút action nếu cần
             if (suffixActionIcon != null) {
               if (clearButton != null) {
                 return Row(
                   mainAxisSize: MainAxisSize.min,
                   mainAxisAlignment: MainAxisAlignment.end,
                   children: [clearButton, suffixActionIcon],
                 );
               } else {
                 return suffixActionIcon; // Chỉ nút action (ví dụ: khi readOnly)
               }
             } else if (clearButton != null) {
               return clearButton; // Chỉ nút clear
             }
             return const SizedBox.shrink(); // Không có icon nào
           },
         ),
         alignLabelWithHint: true,
       ),
       validator: validator,
       onChanged: readOnly ? null : onChanged,
     );
   }
   
   Widget _buildDropdownFormField<T>({
     required BuildContext context, 
     required String labelText,
     required T? value,
     required List<DropdownMenuItem<T>> items,
     required ValueChanged<T?>? onChanged, 
     String? hintText,
     String? Function(T?)? validator,
     bool? enabled, 
   }) {
     return DropdownButtonFormField<T>(
       decoration: InputDecoration(
         labelText: labelText,
         hintText: value == null ? hintText : null, 
         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
         contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16), 
         fillColor: enabled == false ? Colors.grey[200] : null, 
         filled: enabled == false,
       ),
       value: value,
       items: items,
       onChanged: enabled == false ? null : onChanged, 
       validator: validator,
       isExpanded: true, 
       icon: const Icon(Icons.arrow_drop_down),
     );
   }
} 