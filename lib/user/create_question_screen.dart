import 'package:flutter/material.dart';

class CreateQuestionScreen extends StatefulWidget {
  const CreateQuestionScreen({super.key});

  @override
  State<CreateQuestionScreen> createState() => _CreateQuestionScreenState();
}

class _CreateQuestionScreenState extends State<CreateQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  // Danh sách các controllers cho từng option
  final List<TextEditingController> _optionControllers = [];
  // Chỉ số của đáp án đúng (dùng Radio button)
  int? _correctAnswerIndex;
  // (Tùy chọn) Controller cho category
  // final _categoryController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Khởi tạo với 2 ô nhập option
    _addOptionField();
    _addOptionField();
  }

  // Hàm thêm một ô nhập option mới
  void _addOptionField() {
    setState(() {
      _optionControllers.add(TextEditingController());
    });
  }

  // Hàm xóa một ô nhập option
  void _removeOptionField(int index) {
    // Chỉ cho xóa nếu có nhiều hơn 2 options
    if (_optionControllers.length > 2) {
      setState(() {
        // Nếu xóa option đang được chọn là đúng, reset lại
        if (_correctAnswerIndex == index) {
          _correctAnswerIndex = null;
        }
        // Nếu xóa option trước option đúng, cập nhật lại index
        else if (_correctAnswerIndex != null && _correctAnswerIndex! > index) {
          _correctAnswerIndex = _correctAnswerIndex! - 1;
        }
        _optionControllers[index].dispose(); // Dispose controller trước khi xóa
        _optionControllers.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    // Dispose tất cả các option controllers
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    // _categoryController.dispose();
    super.dispose();
  }

  void _submitForm() {
    // Validate cả form và các option
    bool allOptionsValid = true;
    for (int i = 0; i < _optionControllers.length; i++) {
      if (_optionControllers[i].text.trim().isEmpty) {
        allOptionsValid = false;
        // Có thể hiển thị thông báo lỗi cụ thể hơn cho từng option nếu muốn
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all option fields (Option ${i + 1}).')),
        );
        break;
      }
    }

    if (_formKey.currentState!.validate() && allOptionsValid) {
      if (_correctAnswerIndex == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select the correct answer.')),
        );
        return; // Dừng lại nếu chưa chọn đáp án đúng
      }

      // Form hợp lệ, xử lý gửi dữ liệu
      final questionText = _questionController.text;
      final options = _optionControllers.map((controller) => controller.text.trim()).toList();
      final correctAnswer = options[_correctAnswerIndex!]; // Lấy text của đáp án đúng

      print('--- Submitting Question ---');
      print('Question: $questionText');
      print('Options: $options');
      print('Correct Answer Index: $_correctAnswerIndex');
      print('Correct Answer Text: $correctAnswer');
      // TODO: Get category data
      // TODO: Call service/provider to send data to backend

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question data collected (check console)!')),
      );
      // Navigator.pop(context); // Quay về màn hình trước sau khi submit
    } else {
       print('Form validation failed or options invalid.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Question'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView( // Sử dụng ListView để tránh lỗi overflow
            children: [
              Text(
                'Enter your question details:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),

              // Trường nhập câu hỏi
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question Text',
                  hintText: 'E.g., What is the capital of ...?',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true, // Canh label với hint khi maxLines > 1
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter the question text.';
                  }
                  return null;
                },
                maxLines: 3,
                textInputAction: TextInputAction.next, // Chuyển focus
              ),
              const SizedBox(height: 20),

              // --- Khu vực nhập Options --- 
              Text(
                'Options (Select the correct one):',
                 style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              // Dùng ListView.builder để tạo động các ô nhập liệu
              ListView.builder(
                shrinkWrap: true, // Cần thiết khi đặt ListView trong ListView khác
                physics: const NeverScrollableScrollPhysics(), // Ngăn cuộn riêng của ListView này
                itemCount: _optionControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Radio button để chọn đáp án đúng
                        Radio<int>(
                          value: index,
                          groupValue: _correctAnswerIndex,
                          onChanged: (int? value) {
                            setState(() {
                              _correctAnswerIndex = value;
                            });
                          },
                          activeColor: Theme.of(context).primaryColor,
                        ),
                        // TextFormField cho option
                        Expanded(
                          child: TextFormField(
                            controller: _optionControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Option ${index + 1}',
                              border: const OutlineInputBorder(),
                              isDense: true, // Làm cho field nhỏ gọn hơn
                            ),
                            validator: (value) {
                              // Validation cơ bản đã xử lý trong _submitForm
                              // Có thể thêm validation phức tạp hơn ở đây nếu cần
                              // if (value == null || value.trim().isEmpty) {
                              //   return 'Required';
                              // }
                              return null;
                            },
                             textInputAction: TextInputAction.next, // Chuyển focus
                          ),
                        ),
                        // Nút xóa option
                        if (_optionControllers.length > 2) // Chỉ hiển thị nếu > 2 options
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                            tooltip: 'Remove Option ${index + 1}',
                            onPressed: () => _removeOptionField(index),
                          )
                        else // Placeholder để giữ khoảng cách khi không có nút xóa
                          const SizedBox(width: 48), // Chiều rộng tương đương IconButton
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              // Nút thêm Option
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Add Option'),
                  onPressed: _addOptionField,
                ),
              ),

              const SizedBox(height: 20),

              // --- Khu vực chọn Category --- 
              // TODO: Implement UI for selecting category (e.g., DropdownButton)
              const Text('Select category (Not implemented yet)'),

              const SizedBox(height: 30),

              // Nút Submit
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15.0),
                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                child: const Text(
                    'Submit Question',
                    style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 