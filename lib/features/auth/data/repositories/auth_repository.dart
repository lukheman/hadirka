import '../services/auth_api_service.dart';
import '../model_user.dart';

class AuthRepository {
  final AuthApiService _apiService;

  AuthRepository(this._apiService);

  Future<UserAccount> login(String identifier, String password) async {
    final result = await _apiService.login(identifier, password);
    
    final userJson = result['user'] ?? result;
    final user = UserAccount.fromJson(userJson);
    
    
    final token = result['token'] ?? userJson['token'];
    if (token != null) {
      await _apiService.saveToken(token.toString());
    }

    return user;
  }

  Future<UserAccount> register(Map<String, dynamic> userData) async {
    final result = await _apiService.register(userData);
    final userJson = result['user'] ?? result;
    return UserAccount.fromJson(userJson);
  }

  Future<Map<String, dynamic>> checkActivation(String identifier) {
    return _apiService.checkActivation(identifier);
  }

  Future<void> logout() async {
    await _apiService.deleteToken();
  }
}
