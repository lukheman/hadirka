import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ApiConstants {
  static const String keyCustomUrl = 'custom_server_url';
  static const String keyAuthToken = 'auth_token';
  
  
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    try {
      if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
        return 'http://localhost:3000/api';
      }
      if (Platform.isAndroid) {
        
        return 'http://192.168.1.58:3000/api';
      }
    } catch (_) {}
    return 'http://192.168.1.58:3000/api';
  }

  
  static const List<String> candidateIps = [
    'http://192.168.1.58:3000/api',
    'http://10.0.2.2:3000/api',
    'http://192.168.1.18:3000/api',
    'http://192.168.1.12:3000/api',
    'http://192.168.56.1:3000/api',
    'http://localhost:3000/api',
  ];
  
  static const Duration timeoutDuration = Duration(seconds: 8);

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

    if (!clean.contains(':3000')) {
      clean = clean.replaceAll('/api', '');
      if (clean.endsWith('/')) {
        clean = clean.substring(0, clean.length - 1);
      }
      clean = '$clean:3000';
    }

    if (!clean.endsWith('/api')) {
      if (clean.endsWith('/')) {
        clean = '${clean}api';
      } else {
        clean = '$clean/api';
      }
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
