import '../services/services_api_service.dart';

class ServicesRepository {
  final ServicesApiService _apiService;

  ServicesRepository(this._apiService);

  Future<List<Map<String, dynamic>>> getUsers() async {
    final data = await _apiService.getUsers();
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getLeave() async {
    final data = await _apiService.getLeave();
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getLoans() async {
    final data = await _apiService.getLoans();
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getPayslips(String username) async {
    final data = await _apiService.getPayslips(username);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> getGeofence([String username = '']) async {
    final data = await _apiService.getGeofence(username);
    return List<Map<String, dynamic>>.from(data);
  }

  Future<bool> postLeave(Map<String, dynamic> data) async {
    return await _apiService.postLeave(data);
  }

  Future<bool> postLoan(Map<String, dynamic> data) async {
    return await _apiService.postLoan(data);
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    return await _apiService.updateProfile(data);
  }

  Future<bool> updatePassword(String username, String oldPass, String newPass) async {
    return await _apiService.updatePassword(username, oldPass, newPass);
  }
}
