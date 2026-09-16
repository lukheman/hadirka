import 'package:flutter/material.dart';
import '../theme/app_colors.dart';


class AppNotification {
  
  static void showSuccess(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    _showCustomSnackBar(
      context,
      message: message,
      backgroundColor: const Color(0xFF1E293B), 
      borderColor: AppColors.success,
      textColor: const Color(0xFF34D399), 
      duration: duration,
    );
  }

  
  static void showError(BuildContext context, String message, {Duration duration = const Duration(seconds: 4)}) {
    _showCustomSnackBar(
      context,
      message: message,
      backgroundColor: const Color(0xFF1E293B),
      borderColor: AppColors.error,
      textColor: const Color(0xFFF87171), 
      duration: duration,
    );
  }

  
  static void showInfo(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    _showCustomSnackBar(
      context,
      message: message,
      backgroundColor: const Color(0xFF1E293B),
      borderColor: AppColors.primary,
      textColor: const Color(0xFF60A5FA), 
      duration: duration,
    );
  }

  
  static void showWarning(BuildContext context, String message, {Duration duration = const Duration(seconds: 4)}) {
    _showCustomSnackBar(
      context,
      message: message,
      backgroundColor: const Color(0xFF1E293B),
      borderColor: AppColors.warning,
      textColor: const Color(0xFFFBBF24), 
      duration: duration,
    );
  }

  static void _showCustomSnackBar(
    BuildContext context, {
    required String message,
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
    required Duration duration,
  }) {
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    String cleanMessage = message;
    try {
      cleanMessage = message.replaceAll(RegExp(r'[\u{1F300}-\u{1F9FF}✅❌ℹ️⚠️🔒🗑️🎉🌅🌇🏢👤]', unicode: true), '').trim();
    } catch (_) {
      cleanMessage = message.trim();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        content: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor.withOpacity(0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  cleanMessage,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
