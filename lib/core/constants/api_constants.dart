import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ApiConstants {
  static const String keyCustomUrl = 'custom_server_url';
  static const String keyAuthToken = 'auth_token';

  
  static String _env(String key) {
    if (!dotenv.isInitialized) return '';
    return dotenv.env[key]?.trim() ?? '';
  }

  
  static String get defaultBaseUrl {
    final fromEnv = _env('API_BASE_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    try {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        return 'http://localhost:8000/api';
      }
      if (Platform.isAndroid) {
        
        return 'http://10.174.154.8:8000/api';
      }
    } catch (_) {}
    return 'http://10.174.154.8:8000/api';
  }

  
  static const List<String> _defaultCandidateIps = [
    'http://10.174.154.8:8000/api',
    'http://10.0.2.2:8000/api',
    'http://192.168.1.18:8000/api',
    'http://192.168.1.12:8000/api',
    'http://192.168.56.1:8000/api',
    'http://localhost:8000/api',
    'http://10.174.154.8/ipm-hris/api',
    'http://localhost/ipm-hris/api',
  ];

  
  static List<String> get candidateIps {
    final fromEnv = _env('API_FALLBACK_IPS');
    if (fromEnv.isEmpty) return _defaultCandidateIps;
    return fromEnv
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
  
  
  static Duration get timeoutDuration {
    final seconds = int.tryParse(_env('API_TIMEOUT_SECONDS'));
    if (seconds == null || seconds <= 0) return const Duration(seconds: 8);
    return Duration(seconds: seconds);
  }

  static String? _customServerUrl;

  
  static Future<void> loadCustomUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _customServerUrl = prefs.getString(keyCustomUrl);
    } catch (_) {}
  }

  
  static String get baseUrl {
    return _customServerUrl ?? defaultBaseUrl;
  }

  
  static Future<void> setCustomUrl(String input) async {
    String clean = input.trim();
    if (clean.isEmpty) return;

    if (!clean.startsWith('http://') && !clean.startsWith('https://')) {
      clean = 'http://$clean';
    }

    // Rapikan slash di akhir, lalu pastikan berakhiran '/api'.
    // Server baru = website HRD (contoh: http://192.168.x.x/ipm-hris atau
    // http://192.168.x.x:8000 saat dev) sehingga port lama tidak dipaksa lagi.
    while (clean.endsWith('/')) {
      clean = clean.substring(0, clean.length - 1);
    }
    if (!clean.endsWith('/api')) {
      clean = '$clean/api';
    }

    _customServerUrl = clean;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyCustomUrl, clean);
    } catch (_) {}
  }

  static Future<void> resetCustomUrl() async {
    _customServerUrl = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(keyCustomUrl);
    } catch (_) {}
  }
}
