import 'dart:convert';
import 'dart:io' show Platform, HttpException, SocketException; // Import Platform
import 'dart:math';
import 'package:flutter/foundation.dart' show kIsWeb; // Import kIsWeb for web check
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  // Dynamically determine the base URL based on the platform
  static String get _baseUrl {
    const String envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl; // Use environment variable if provided
    }

    if (kIsWeb) {
      // Running on the web
      return 'http://localhost:8090/api/auth';
    } else if (Platform.isAndroid) {
      // Running on Android emulator or device
      // Use 10.0.2.2 for Emulator, for physical device use host machine IP
      // TODO: Consider using a configuration or discovery mechanism for physical devices
      return 'http://10.0.2.2:8090/api/auth';
    } else if (Platform.isIOS) {
      // Running on iOS simulator or device
      // Use localhost for Simulator, for physical device use host machine IP
      // TODO: Consider using a configuration or discovery mechanism for physical devices
       return 'http://localhost:8090/api/auth';
    } else {
       // Other platforms (Desktop - Windows, macOS, Linux)
       return 'http://localhost:8090/api/auth';
    }
  }

  static const String _tokenKey = 'auth_token';

  final http.Client _client; // Inject HttpClient for testability

  // Constructor allowing client injection
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  // Login user
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final Uri loginUrl = Uri.parse('$_baseUrl/login');
    print('Attempting POST to $loginUrl with username: $username');

    try {
      // Bỏ qua OPTIONS request vì Client không hỗ trợ phương thức options
      // Sử dụng trực tiếp POST request

      // Thêm timeout để tránh chờ vô hạn
      final response = await _client.post(
        loginUrl,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
          'Origin': 'http://localhost',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 15), onTimeout: () {
        print('Login request timed out after 15 seconds');
        throw Exception('Login request timed out. Please try again.');
      });

      print('Login response status: ${response.statusCode}');
      print('Login response headers: ${response.headers}');
      print('Login response body: ${response.body}'); // DEBUG: Log response body to diagnose issues

      return _handleAuthResponse(response);

    } on SocketException catch (e) {
      print('Network Error during login: $e');
      throw Exception('Network Error: Could not connect to the server. Please check your connection and ensure the server is running.');
    } on HttpException catch (e) {
       print('HTTP Error during login: $e');
      throw Exception('HTTP Error: Could not find the requested resource.');
    } on FormatException catch (e) {
      print('Format Error during login response parsing: $e');
      throw Exception('Format Error: Invalid response format received from server.');
    } catch (e) {
      print('Unexpected error during login: $e');
      // Rethrow or handle specific exceptions based on your http client or other factors
      throw Exception('An unexpected error occurred during login: $e');
    }
  }

  // Register user
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    final Uri registerUrl = Uri.parse('$_baseUrl/register');
    print('Attempting POST to $registerUrl for user: $username');

    try {
      final response = await _client.post(
        registerUrl,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'email': email,
          'password': password,
          'fullName': fullName,
        }),
      );

      print('Register response status: ${response.statusCode}');
      // print('Register response body: ${response.body}'); // Avoid logging potentially sensitive data

      return _handleRegistrationResponse(response);

    } on SocketException catch (e) {
      print('Network Error during registration: $e');
      throw Exception('Network Error: Could not connect to the server. Please check your connection and ensure the server is running.');
    } on HttpException catch (e) {
       print('HTTP Error during registration: $e');
      throw Exception('HTTP Error: Could not find the requested resource.');
    } on FormatException catch (e) {
      print('Format Error during registration response parsing: $e');
      throw Exception('Format Error: Invalid response format received from server.');
    } catch (e) {
      print('Unexpected error during registration: $e');
      throw Exception('An unexpected error occurred during registration: $e');
    }
  }

  // Forgot Password
  Future<String> forgotPassword({required String email}) async {
    final Uri forgotPasswordUrl = Uri.parse('$_baseUrl/forgot-password');
    print('Attempting POST to $forgotPasswordUrl for email: $email');

    try {
      final response = await _client.post(
        forgotPasswordUrl,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
        }),
      );

      print('Forgot Password response status: ${response.statusCode}');
      print('Forgot Password response body: ${response.body}'); // Log the server message

       // Check for non-200 status codes first
      if (response.statusCode != 200) {
          String errorMessage = 'Failed to process forgot password request (Status: ${response.statusCode})';
          try {
            // Attempt to parse error if backend sends structured error
            final errorData = jsonDecode(response.body) as Map<String, dynamic>;
            errorMessage = errorData['message'] ?? errorData['error'] ?? response.body;
          } catch (_) {
            errorMessage = response.body; // Use raw body if not JSON
          }
          print('Forgot Password Error: $errorMessage');
          throw Exception(errorMessage);
      }

      // Even if 200 OK, the actual message is in the body (for security)
      // We return the body directly to the provider/UI to display the message.
      return response.body;

    } on SocketException catch (e) {
      print('Network Error during forgot password: $e');
      throw Exception('Network Error: Could not connect to the server.');
    } on HttpException catch (e) {
       print('HTTP Error during forgot password: $e');
      throw Exception('HTTP Error: Could not find the requested resource.');
    } catch (e) {
      print('Unexpected error during forgot password: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Reset Password
  Future<String> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    final Uri resetPasswordUrl = Uri.parse('$_baseUrl/reset-password');
    print('Attempting POST to $resetPasswordUrl with token: $token');

    try {
      final response = await _client.post(
        resetPasswordUrl,
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'token': token,
          'newPassword': newPassword,
        }),
      );

      print('Reset Password response status: ${response.statusCode}');
      print('Reset Password response body: ${response.body}');

      if (response.statusCode == 200) {
        return response.body; // Return success message from backend
      } else {
         // Handle errors (e.g., invalid token, expired token, other errors)
          String errorMessage = 'Failed to reset password (Status: ${response.statusCode})';
          try {
            // Use backend's error message directly if possible
            errorMessage = response.body;
          } catch (_) {
             // Fallback
             errorMessage = 'An error occurred while resetting the password.';
          }
          print('Reset Password Error: $errorMessage');
          throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      print('Network Error during reset password: $e');
      throw Exception('Network Error: Could not connect to the server.');
    } on HttpException catch (e) {
       print('HTTP Error during reset password: $e');
      throw Exception('HTTP Error: Could not find the requested resource.');
     } on FormatException catch (e) {
      print('Format Error during reset password response parsing: $e');
      throw Exception('Format Error: Invalid response format received from server.');
    } catch (e) {
      print('Unexpected error during reset password: $e');
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Get stored token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Clear stored token (logout)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    print('User logged out, token removed.');
  }

  // --- Helper methods ---

  Future<Map<String, dynamic>> _handleAuthResponse(http.Response response) async {
    print('_handleAuthResponse called with status: ${response.statusCode}');

    if (response.statusCode == 200) {
      try {
        print('Trying to parse response body: ${response.body}');
        if (response.body.isEmpty) {
          print('ERROR: Empty response body');
          throw const FormatException('Empty response from server.');
        }

        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('Parsed data: $data');

        if (data['token'] != null) {
          await _saveToken(data['token']);
          print('Login successful, token saved: ${data['token'].substring(0, min(10, data['token'].length))}...');
          print('User data: ${data['username']}, roles: ${data['role']}');
          // Return user details along with token if needed, e.g., username, roles
          // Adjust the return value based on your backend's AuthResponse DTO
          return data;
        } else {
          print('ERROR: Token not found in response data');
          throw const FormatException('Token not found in login response.');
        }
      } on FormatException catch (e) {
        print('Error decoding login response JSON: $e');
        throw Exception('Invalid response format from server.');
      }
    } else if (response.statusCode == 401) {
      print('Login failed: Invalid credentials (401)');
       throw Exception('Invalid username or password.');
    } else {
       String errorMessage = 'Login failed with status: ${response.statusCode}';
      try {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? errorData['error'] ?? response.body;
      } catch (_) {
           errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
         print('Login Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

   Future<Map<String, dynamic>> _handleRegistrationResponse(http.Response response) async {
    if (response.statusCode == 201 || response.statusCode == 200) { // 201 Created or 200 OK
      try {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
          // Assume registration might also return a token (adjust if not)
          if (data['token'] != null) {
            await _saveToken(data['token']);
            print('Registration successful, token saved.');
          } else {
            print('Registration successful, but no token returned in response.');
          }
          return data; // Return user details or success message
      } on FormatException catch (e) {
        print('Error decoding registration response JSON: $e');
        throw Exception('Invalid response format from server after registration.');
      }
    } else if (response.statusCode == 409) {
        String errorMessage = 'Registration failed: Conflict (409)';
        try {
          final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? errorData['error'] ?? 'Username or email already exists.';
        } catch (_) {
           errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
        }
        print('Registration Error: $errorMessage');
        throw Exception(errorMessage);
    } else {
        String errorMessage = 'Registration failed with status: ${response.statusCode}';
       try {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
          errorMessage = errorData['message'] ?? errorData['error'] ?? response.body;
      } catch (_) {
           errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
      }
        print('Registration Error: $errorMessage');
      throw Exception(errorMessage);
    }
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Helper to get authorization headers (could be used for other services)
  Future<Map<String, String>> getAuthHeaders() async {
     final token = await getToken();
     if (token != null) {
       return {
         'Authorization': 'Bearer $token',
         'Content-Type': 'application/json; charset=UTF-8',
         'Accept': 'application/json',
       };
     } else {
        return {
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        }; // Return non-auth headers if no token
     }
  }
}