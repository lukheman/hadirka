import 'package:dio/dio.dart';
import '../constants/api_constants.dart';


class ApiConfig {
  
  static Future<void> loadCustomUrl() async {
    await ApiConstants.loadCustomUrl();
  }

  
  static Future<void> setCustomUrl(String input) async {
    await ApiConstants.setCustomUrl(input);
  }

  
  static Future<void> resetCustomUrl() async {
    await ApiConstants.resetCustomUrl();
  }

  
  static String get baseUrl {
    return ApiConstants.baseUrl;
  }

  
  static Future<bool> testConnection([String? targetUrl]) async {
    final urlToTest = targetUrl ?? baseUrl;
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      );
      final response = await dio.get('$urlToTest/geofence');
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  
  static const Duration timeoutDuration = Duration(milliseconds: 15000);
}
