import '../../../../core/network/api_client.dart';

class ServicesApiService {
  final ApiClient _apiClient;

  ServicesApiService(this._apiClient);

  Future<List<dynamic>> getUsers() async {
    final response = await _apiClient.get('/users');
    return response as List<dynamic>;
  }

  Future<List<dynamic>> getLeave() async {
    final response = await _apiClient.get('/leave');
    return response as List<dynamic>;
  }

  Future<List<dynamic>> getLoans() async {
    final response = await _apiClient.get('/loan');
    return response as List<dynamic>;
  }

  Future<List<dynamic>> getPayslips(String username, {String? periode}) async {
    final query = <String, dynamic>{};
    if (periode != null && periode.trim().isNotEmpty) {
      query['periode'] = periode.trim();
    }

    final response = await _apiClient.get(
      '/payslip',
      queryParameters: query,
    );
    return response as List<dynamic>;
  }

  Future<List<dynamic>> getGeofence([String username = '']) async {
    final response = await _apiClient.get(
      '/geofence',
      queryParameters: username.isNotEmpty ? {'username': username} : null,
    );
    return response as List<dynamic>;
  }

  Future<bool> postLeave(Map<String, dynamic> data) async {
    await _apiClient.post('/leave', data: data);
    return true;
  }

  Future<bool> postLoan(Map<String, dynamic> data) async {
    await _apiClient.post('/loan', data: data);
    return true;
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    await _apiClient.put('/user/profile', data: data);
    return true;
  }

  Future<bool> updatePassword(
      String username, String oldPass, String newPass) async {
    await _apiClient.put('/user/password', data: {
      'username': username,
      'oldPassword': oldPass,
      'newPassword': newPass,
    });
    return true;
  }
}
