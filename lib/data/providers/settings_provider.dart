import 'package:flutter/material.dart';
import 'dart:convert'; // For json encoding/decoding
import 'package:http/http.dart' as http; // Assuming use of http package
import '../models/admin_dtos.dart'; // Assuming DTOs will be defined here or a similar place

// TODO: Define PointsSettingsDTO and SpecialCategorySettingsDTO based on backend
class PointsSettingsDTO {
  int newUserReward;
  int correctAnswerReward;
  int incorrectAnswerPenalty;
  bool selfChallengeModeEnabled;
  int requiredPointsSelfChallenge;

  PointsSettingsDTO({
    required this.newUserReward,
    required this.correctAnswerReward,
    required this.incorrectAnswerPenalty,
    required this.selfChallengeModeEnabled,
    required this.requiredPointsSelfChallenge,
  });

  factory PointsSettingsDTO.fromJson(Map<String, dynamic> json) {
    return PointsSettingsDTO(
      newUserReward: json['newUserReward'] ?? 50,
      correctAnswerReward: json['correctAnswerReward'] ?? 2,
      incorrectAnswerPenalty: json['incorrectAnswerPenalty'] ?? 1,
      selfChallengeModeEnabled: json['selfChallengeModeEnabled'] ?? true,
      requiredPointsSelfChallenge: json['requiredPointsSelfChallenge'] ?? 2,
    );
  }

  Map<String, dynamic> toJson() => {
    'newUserReward': newUserReward,
    'correctAnswerReward': correctAnswerReward,
    'incorrectAnswerPenalty': incorrectAnswerPenalty,
    'selfChallengeModeEnabled': selfChallengeModeEnabled,
    'requiredPointsSelfChallenge': requiredPointsSelfChallenge,
  };
}

class SpecialCategorySettingsDTO {
  bool specialCategoryEnabled;
  String? category1Id;
  String? category2Id;

  SpecialCategorySettingsDTO({
    required this.specialCategoryEnabled,
    this.category1Id,
    this.category2Id,
  });

   factory SpecialCategorySettingsDTO.fromJson(Map<String, dynamic> json) {
    return SpecialCategorySettingsDTO(
      specialCategoryEnabled: json['specialCategoryEnabled'] ?? true,
      category1Id: json['category1Id'],
      category2Id: json['category2Id'],
    );
  }

   Map<String, dynamic> toJson() => {
    'specialCategoryEnabled': specialCategoryEnabled,
    'category1Id': category1Id,
    'category2Id': category2Id,
  };
}

class SettingsProvider with ChangeNotifier {
  PointsSettingsDTO? _pointsSettings;
  SpecialCategorySettingsDTO? _specialCategorySettings;
  bool _isLoading = false;
  String? _error;
  String? _token;

  PointsSettingsDTO? get pointsSettings => _pointsSettings;
  SpecialCategorySettingsDTO? get specialCategorySettings => _specialCategorySettings;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasToken => _token != null;

  // Method to update the token and trigger fetch
  void updateToken(String? newToken) {
    final bool hadTokenBefore = _token != null;
    _token = newToken;
    // Fetch settings ONLY if we just received the token
    // and didn't have one before, to avoid re-fetching unnecessarily.
    if (!hadTokenBefore && _token != null) {
      print('Token received in SettingsProvider, fetching settings...'); // Log
      fetchSettings(); 
    } else if (_token == null) {
        print('Token removed from SettingsProvider.'); // Log if token becomes null (e.g., logout)
        // Optionally clear settings if token is removed
        // _pointsSettings = null;
        // _specialCategorySettings = null;
        // _error = 'Authentication token is required.';
        // notifyListeners();
    }
    // No need to notifyListeners() here unless UI specifically depends on the token itself
    // fetchSettings() will call notifyListeners() 
  }

  // TODO: Replace with actual base URL from config/env
  final String _baseUrl = 'http://localhost:8090/api/admin/settings'; // Trỏ đến API Gateway, cổng 8090

  // Helper to get headers
  Map<String, String> _getHeaders() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<void> fetchSettings() async {
    if (_token == null) {
      _error = 'Authentication token not available.';
       print('Error fetching settings (fetchSettings called but token is null).'); 
      _isLoading = false;
      // Don't reset loading=true if we never started
      // Only notify if the error state actually changed
      if (_error != 'Authentication token not available.') {
          notifyListeners();
      }
      return; 
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('SettingsProvider: Fetching settings with token...'); // Log
      // Fetch points settings
      final pointsResponse = await http.get(
        Uri.parse('$_baseUrl/points'),
        headers: _getHeaders(), // <<< USE HEADERS
      );
      if (pointsResponse.statusCode == 200) {
        _pointsSettings = PointsSettingsDTO.fromJson(json.decode(pointsResponse.body));
      } else if (pointsResponse.statusCode == 401) {
        throw Exception('Unauthorized: Invalid or missing token (401)');
      } else {
        throw Exception('Failed to load points settings (${pointsResponse.statusCode})');
      }

      // Fetch special category settings
      final specialCatsResponse = await http.get(
        Uri.parse('$_baseUrl/special-categories'),
         headers: _getHeaders(), // <<< USE HEADERS
        );
       if (specialCatsResponse.statusCode == 200) {
        _specialCategorySettings = SpecialCategorySettingsDTO.fromJson(json.decode(specialCatsResponse.body));
      } else if (specialCatsResponse.statusCode == 401) {
         throw Exception('Unauthorized: Invalid or missing token (401)');
      } else {
         throw Exception('Failed to load special category settings (${specialCatsResponse.statusCode})');
      }

    } catch (e) {
      _error = e.toString();
      print('Error fetching settings: $_error'); // Log error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

   Future<bool> updatePointsSettings(PointsSettingsDTO data) async {
      if (_token == null) { // <<< ADD TOKEN CHECK
        _error = 'Authentication token not available.';
        print('Error updating points settings: $_error'); 
        notifyListeners();
        return false;
      }

     _isLoading = true;
     _error = null;
     notifyListeners();
     bool success = false;

     try {
        final response = await http.put(
          Uri.parse('$_baseUrl/points'),
          headers: _getHeaders(), // <<< USE HEADERS
          body: json.encode(data.toJson()),
       );

       if (response.statusCode == 200) {
          _pointsSettings = PointsSettingsDTO.fromJson(json.decode(response.body));
          success = true;
       } else if (response.statusCode == 401) { // <<< ADD 401 CHECK
         throw Exception('Unauthorized: Invalid or missing token (401)');
       } else {
         // Attempt to parse error message from backend if available
          String errorMessage = 'Failed to update points settings (${response.statusCode})';
         try {
           final errorBody = json.decode(response.body);
           errorMessage = errorBody['message'] ?? errorMessage;
         } catch (_) {}
         throw Exception(errorMessage);
       }
     } catch (e) {
       _error = e.toString();
        print('Error updating points settings: $_error'); // Log error
     } finally {
       _isLoading = false;
       notifyListeners();
     }
     return success;
   }

   Future<bool> updateSpecialCategorySettings(SpecialCategorySettingsDTO data) async {
       if (_token == null) { // <<< ADD TOKEN CHECK
         _error = 'Authentication token not available.';
         print('Error updating special category settings: $_error');
         notifyListeners();
         return false;
       }

      _isLoading = true;
     _error = null;
     notifyListeners();
     bool success = false;

      try {
         final response = await http.put(
          Uri.parse('$_baseUrl/special-categories'),
           headers: _getHeaders(), // <<< USE HEADERS
          body: json.encode(data.toJson()),
       );

       if (response.statusCode == 200) {
          _specialCategorySettings = SpecialCategorySettingsDTO.fromJson(json.decode(response.body));
           success = true;
       } else if (response.statusCode == 401) { // <<< ADD 401 CHECK
         throw Exception('Unauthorized: Invalid or missing token (401)');
       } else {
           String errorMessage = 'Failed to update special category settings (${response.statusCode})';
         try {
           final errorBody = json.decode(response.body);
           errorMessage = errorBody['message'] ?? errorMessage;
         } catch (_) {}
         throw Exception(errorMessage);
       }
     } catch (e) {
       _error = e.toString();
       print('Error updating special category settings: $_error'); // Log error
     } finally {
       _isLoading = false;
       notifyListeners();
     }
      return success;
   }

   // TODO: Add method to fetch available categories

} 