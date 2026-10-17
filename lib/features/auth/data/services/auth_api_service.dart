import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService(this._apiClient);

  Future<Map<String, dynamic>> login(String identifier, String password) async {
    final response = await _apiClient.post('/auth/login', data: {
      'identifier': identifier,
      'password': password,
    });
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    final response = await _apiClient.post('/auth/register', data: userData);
    return response as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> checkActivation(String identifier) async {
    final response = await _apiClient.post('/auth/check', data: {
      'identifier': identifier.trim(),
    });
    return Map<String, dynamic>.from(response as Map);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(ApiConstants.keyAuthToken, token);
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.keyAuthToken);
  }
}
