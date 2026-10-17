import '../services/attendance_api_service.dart';
import '../model_data_absensi.dart';

class AttendanceRepository {
  final AttendanceApiService _apiService;

  AttendanceRepository(this._apiService);

  Future<DataAbsensi> submitAttendance({
    required String username,
    required double latitude,
    required double longitude,
    required String tipe,
    String? fotoPath,
    String? fotoBase64,
  }) async {
    final result = await _apiService.submitAttendance(
      username: username,
      latitude: latitude,
      longitude: longitude,
      tipe: tipe,
      fotoPath: fotoPath,
      fotoBase64: fotoBase64,
    );
    
    return DataAbsensi.fromJson(result['data'] ?? result);
  }

  Future<List<DataAbsensi>> getHistory(String username) async {
    final results = await _apiService.getHistory(username);
    return results.map((json) => DataAbsensi.fromJson(json)).toList();
  }
}
