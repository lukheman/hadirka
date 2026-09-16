import 'dart:convert';

class PasswordUtils {
  
  
  static String hashPassword(String password) {
    final salt = 'TJS_SECURE_SALT_2026_';
    final bytes = utf8.encode(salt + password);
    return base64Encode(bytes);
  }
}
