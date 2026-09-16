import 'package:flutter/material.dart';

class AppColors {
  static const surface = Color(0xFFF8FAFC);
  static const onSurface = Color(0xFF0F172A);
  static const onSurfaceVariant = Color(0xFF475569);
  
  
  static const primary = Color(0xFF1E40AF); 
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = Color(0xFFDBEAFE); 
  static const onPrimaryContainer = Color(0xFF1E40AF);
  
  static const secondary = Color(0xFF3B82F6); 
  static const onSecondary = Color(0xFFFFFFFF);
  
  static const error = Color(0xFFEF4444);
  
  static const surfaceContainer = Color(0xFFFFFFFF); 
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerHigh = Color(0xFFF1F5F9); 
  
  static const primaryFixed = Color(0xFFDBEAFE);
  static const onPrimaryFixed = Color(0xFF1E40AF);
  
  static const border = Color(0xFFE2E8F0); 
  static const borderLight = Color(0xFFF1F5F9);
  
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF475569);
  static const textTertiary = Color(0xFF94A3B8);
  
  static const success = Color(0xFF10B981);
  static const successBg = Color(0xFFD1FAE5);
  static const errorBg = Color(0xFFFEE2E2);
  static const warning = Color(0xFFF59E0B);
  static const warningBg = Color(0xFFFEF3C7);
  static const accentGreen = Color(0xFF10B981);

  
  static const hrNavy = Color(0xFF0F172A);
  static const hrSlate = Color(0xFF1E293B);
  static const hrAccentCyan = Color(0xFF06B6D4);
  static const hrAccentPurple = Color(0xFF8B5CF6);
  static const hrAccentRose = Color(0xFFF43F5E);
  
  static const hrCyanBg = Color(0xFFECFEFF);
  static const hrPurpleBg = Color(0xFFF5F3FF);
  static const hrRoseBg = Color(0xFFFFF1F2);

  
  static const LinearGradient hrHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0F172A), 
      Color(0xFF1E3A8A), 
      Color(0xFF1E40AF), 
    ],
  );

  static const LinearGradient hrCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1E293B),
      Color(0xFF0F172A),
    ],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF3B82F6), 
      Color(0xFF1E40AF), 
    ],
  );
  
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF34D399), 
      Color(0xFF059669), 
    ],
  );
  
  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFA78BFA),
      Color(0xFF7C3AED),
    ],
  );
}
