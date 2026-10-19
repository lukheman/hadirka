import 'package:flutter/material.dart';

class AppColors {
  // IPM HRIS official palette. Keep semantic names below for existing screens.
  static const surface = Color(0xFFF5F5F5); // --ipm-bg
  static const onSurface = Color(0xFF1A1A1A); // --ipm-ink
  static const onSurfaceVariant = Color(0xFF8C8C8C); // --ipm-muted

  static const ipmBlue = Color(0xFF1D5C96);
  static const ipmBlueLight = Color(0xFF2E7BB8);
  static const ipmBlueDark = Color(0xFF123F68);
  static const ipmBlueSoft = Color(0xFFCFE3F2);

  static const ipmOrange = Color(0xFFF2921D);
  static const ipmOrangeLight = Color(0xFFF7A94A);
  static const ipmOrangeDark = Color(0xFFD97706);
  static const ipmOrangeSoft = Color(0xFFFDE6C6);
  static const loginCard = Color(0xFFFFF8EF);

  static const primary = ipmOrange;
  static const onPrimary = Color(0xFFFFFFFF);
  static const primaryContainer = ipmOrangeSoft;
  static const onPrimaryContainer = ipmOrangeDark;

  static const secondary = ipmBlue;
  static const onSecondary = Color(0xFFFFFFFF);

  static const error = Color(0xFFFF3E1D);
  static const surfaceContainer = Color(0xFFFFFFFF);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerHigh = Color(0xFFF1F2F4);
  static const primaryFixed = ipmOrangeSoft;
  static const onPrimaryFixed = ipmOrangeDark;
  static const border = Color(0xFFD9DEE3);
  static const borderLight = Color(0xFFE9EAEC);
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF595959);
  static const textTertiary = Color(0xFF8C8C8C);

  // Data status colors. Do not use these for action buttons.
  static const success = Color(0xFF71DD37);
  static const successBg = Color(0xFFE8FADF);
  static const errorBg = Color(0xFFFFE0DB);
  static const warning = ipmBlue;
  static const warningBg = ipmBlueSoft;
  static const statusWarning = Color(0xFFFFAB00);
  static const statusWarningBg = Color(0xFFFFF2D6);
  static const info = Color(0xFF03C3EC);
  static const infoBg = Color(0xFFD7F5FC);
  static const neutral = Color(0xFF8592A3);
  static const neutralBg = Color(0xFFF1F2F4);
  static const izin = Color(0xFF696CFF);
  static const izinBg = Color(0xFFE7E7FF);
  static const cuti = Color(0xFF6F42C1);
  static const cutiBg = Color(0xFFEDE4F7);
  static const accentGreen = success;

  static const hrNavy = ipmBlueDark;
  static const hrSlate = ipmBlue;
  static const hrAccentCyan = info;
  static const hrAccentPurple = cuti;
  static const hrAccentRose = error;
  static const hrCyanBg = infoBg;
  static const hrPurpleBg = cutiBg;
  static const hrRoseBg = errorBg;

  static const LinearGradient hrHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      ipmBlueDark,
      ipmBlue,
      ipmBlueLight,
    ],
  );

  static const LinearGradient hrCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      ipmBlue,
      ipmBlueDark,
    ],
  );

  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      ipmBlueLight,
      ipmBlue,
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
