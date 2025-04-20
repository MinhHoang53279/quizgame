import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../services/auth_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login({
    required String username,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final authData = await _authService.login(
        username: username,
        password: password,
      );
      
      // Get user details directly from the login response (AuthResponse)
      // No need for the second call to user service anymore
      /*
      final userData = await _userService.getUserByUsername(username);
      _currentUser = User.fromJson(userData);
      */

      // Create User object from authData returned by AuthService.login
      _currentUser = User(
          id: authData['id'] as String,
          username: authData['username'] as String,
          email: authData['email'] as String,
          fullName: authData['fullName'] as String,
          score: authData['score'] as int,
          roles: [(authData['role'] as String?) ?? 'USER']
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

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
      // Call auth service to register. This now creates the full user.
      final authData = await _authService.register(
        username: username,
        email: email,
        password: password,
        fullName: fullName, // Pass fullName to auth service
      );
      
      // No need to call _userService.createUser anymore
      /*
      // Then create user profile
      final userData = await _userService.createUser(
        username: username,
        email: email,
        password: password, // Password might not be needed here anymore
        fullName: fullName,
      );
      */

      // Create User object from the data returned by auth service
      // Assuming AuthResponse now contains all necessary fields
      _currentUser = User(
         id: authData['id'] as String, // Explicit cast
         username: authData['username'] as String, // Explicit cast
         email: authData['email'] as String, // Explicit cast
         fullName: authData['fullName'] as String, // Explicit cast and correct parameter name
         score: authData['score'] as int, // Explicit cast
         roles: [(authData['role'] as String?) ?? 'USER'] // Ensure List<String>
      );

      // Token is saved within _authService.register -> _handleAuthResponse
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> getUserByUsername(String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userData = await _userService.getUserByUsername(username);
      _currentUser = User.fromJson(userData);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

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
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Add forgotPassword method
  Future<String> forgotPassword({required String email}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final message = await _authService.forgotPassword(email: email);
      _isLoading = false;
      notifyListeners();
      return message; // Return the message from the service
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      // Rethrow the error message to be displayed in the UI
      throw Exception(_error);
    }
  }

  // Add resetPassword method
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
      return message; // Return the success message
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      // Rethrow the error message (e.g., "Invalid or expired token")
      throw Exception(_error);
    }
  }
} 