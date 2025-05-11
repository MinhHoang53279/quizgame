import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../services/question_service.dart';
import '../models/question.dart';

/**
 * Provider quản lý trạng thái và logic nghiệp vụ liên quan đến người dùng.
 * Sử dụng ChangeNotifier để thông báo cho các widget lắng nghe khi có thay đổi.
 * Tương tác với AuthService và UserService để thực hiện các thao tác.
 */
class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  final QuestionService _questionService = QuestionService();
  User? _currentUser; // Thông tin người dùng đang đăng nhập
  bool _isLoading = false; // Trạng thái đang tải dữ liệu
  String? _error; // Thông báo lỗi (nếu có)

  // Getters để truy cập trạng thái từ bên ngoài
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /**
   * Xử lý đăng nhập người dùng.
   * Gọi AuthService.login, sau đó lấy thông tin người dùng từ phản hồi.
   * @param username Tên đăng nhập.
   * @param password Mật khẩu.
   * @return true nếu đăng nhập thành công, false nếu thất bại.
   */
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners(); // Thông báo bắt đầu tải

    try {
      // Gọi API đăng nhập
      final authData = await _authService.login(
        username: username,
        password: password,
      );
      
      // Lấy thông tin người dùng trực tiếp từ phản hồi đăng nhập (AuthResponse)
      _currentUser = User(
          id: authData['id'] as String, 
          username: authData['username'] as String, 
          email: authData['email'] as String, 
          fullName: authData['fullName'] as String, 
          score: authData['score'] as int, 
          roles: [(authData['role'] as String?) ?? 'USER'] 
      );

      _isLoading = false;
      notifyListeners(); // Thông báo tải xong, cập nhật UI
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", ""); // Lưu lỗi
      _isLoading = false;
      notifyListeners(); // Thông báo có lỗi
      return false;
    }
  }

  /**
   * Xử lý tạo tài khoản người dùng mới.
   * Gọi AuthService.register để tạo người dùng trên backend.
   * @param username Tên đăng nhập.
   * @param email Email.
   * @param password Mật khẩu.
   * @param fullName Họ và tên.
   * @return true nếu tạo thành công, false nếu thất bại.
   */
  Future<bool> createUser({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Gọi auth service để đăng ký. Backend sẽ tạo người dùng đầy đủ.
      final authData = await _authService.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
      );
      
      // Tạo đối tượng User từ dữ liệu trả về bởi auth service
      _currentUser = User(
         id: authData['id'] as String, 
         username: authData['username'] as String, 
         email: authData['email'] as String, 
         fullName: authData['fullName'] as String, 
         score: authData['score'] as int, 
         roles: [(authData['role'] as String?) ?? 'USER'] 
      );

      // Token đã được lưu trong AuthService
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", "");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /**
   * Lấy thông tin người dùng theo username (có thể không cần thiết nếu login/register trả đủ).
   * @param username Tên đăng nhập.
   * @return true nếu thành công, false nếu thất bại.
   */
  Future<bool> getUserByUsername(String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = await _userService.getUserByUsername(username);
      _currentUser = User.fromJson(userData); // Tạo User từ JSON
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", "");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /**
   * Xử lý yêu cầu quên mật khẩu.
   * Gọi AuthService.forgotPassword.
   * @param email Email người dùng.
   * @return Thông báo từ backend.
   * @throws Exception Nếu có lỗi xảy ra.
   */
  Future<String> forgotPassword({required String email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final message = await _authService.forgotPassword(email: email);
      _isLoading = false;
      notifyListeners();
      return message; // Trả về thông báo từ service
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", "");
      _isLoading = false;
      notifyListeners();
      // Ném lại lỗi để UI hiển thị
      throw Exception(_error);
    }
  }

  /**
   * Xử lý yêu cầu đặt lại mật khẩu.
   * Gọi AuthService.resetPassword.
   * @param token Token đặt lại.
   * @param newPassword Mật khẩu mới.
   * @return Thông báo thành công từ backend.
   * @throws Exception Nếu có lỗi xảy ra.
   */
  Future<String> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final message = await _authService.resetPassword(
        token: token,
        newPassword: newPassword,
      );
      _isLoading = false;
      notifyListeners();
      return message; // Trả về thông báo thành công
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", "");
      _isLoading = false;
      notifyListeners();
      // Ném lại lỗi (vd: "Invalid or expired token")
      throw Exception(_error);
    }
  }


  /**
   * Cập nhật điểm của người dùng hiện tại.
   * Gọi UserService.updateScore.
   * @param userId ID người dùng.
   * @param scoreChange Lượng điểm thay đổi.
   * @return true nếu thành công, false nếu thất bại.
   */
  Future<bool> updateScore(String userId, int scoreChange) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = await _userService.updateScore(userId, scoreChange);
      _currentUser = User.fromJson(userData);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst("Exception: ", "");
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /**
   * Xử lý đăng xuất người dùng.
   * Gọi AuthService.logout và xóa thông tin người dùng hiện tại.
   */
  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  /**
   * Xóa thông báo lỗi hiện tại.
   */
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Create a new question
  Future<bool> createQuestion({
    required String question,
    String? details,
    required String category,
    required String difficulty,
    required List<String> options,
    required int correctAnswerIndex,
    String? explanation,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _questionService.createQuestion(
        question: question,
        details: details,
        category: category,
        difficulty: difficulty,
        options: options,
        correctAnswerIndex: correctAnswerIndex,
        explanation: explanation,
      );

      _isLoading = false;
      notifyListeners();

      if (result['success']) {
        return true;
      } else {
        _error = result['error'];
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<Question>> getQuestions({
    String? category,
    String? difficulty,
    int page = 0,
    int size = 10,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final questions = await _questionService.getQuestions(
        category: category,
        difficulty: difficulty,
        page: page,
        size: size,
      );

      _isLoading = false;
      notifyListeners();
      return questions;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  Future<Question?> getQuestionById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final question = await _questionService.getQuestionById(id);
      _isLoading = false;
      notifyListeners();
      return question;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }
} 