import '../../../../core/network/api_client.dart';

class AttendanceApiService {
  final ApiClient _apiClient;

  AttendanceApiService(this._apiClient);

  
  
  Future<Map<String, dynamic>> submitAttendance({
    required String username,
    required double latitude,
    required double longitude,
    required double accuracy,
    required String tipe, 
    String? fotoPath,
    String? fotoBase64,
  }) async {
    final payload = {
      'username': username,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'tipe': tipe,
      'fotoPath': fotoPath,
      'fotoBase64': fotoBase64,
    };
    
    
    
    final response = await _apiClient.post('/attendance/submit', data: payload);
    return response as Map<String, dynamic>;
  }

  
  Future<List<Map<String, dynamic>>> getHistory(String username) async {
    final response = await _apiClient.get('/attendance', queryParameters: {
      'username': username,
    });
    return List<Map<String, dynamic>>.from(response);
  }
}
