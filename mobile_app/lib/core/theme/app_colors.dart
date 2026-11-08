import 'package:flutter/material.dart';

class AppColors {
  // Deep Midnight Backgrounds
  static const Color bgDark = Color(0xFF080D1A);
  static const Color surfaceDark = Color(0xFF0F172A);
  static const Color surfaceDarkElevated = Color(0xFF162038);
  static const Color surfaceDarkInset = Color(0xFF0A0F1D);

  // Vibrant Accents
  static const Color primaryOrange = Color(0xFFFF6B00);
  static const Color primaryOrangeLight = Color(0xFFFFA043);
  static const Color accentCyan = Color(0xFF00D2FF);
  static const Color accentTeal = Color(0xFF00E599);
  static const Color accentPurple = Color(0xFF7928CA);
  static const Color accentGold = Color(0xFFFFB800);
  static const Color accentRed = Color(0xFFFF3B30);

  // Typography Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Borders & Dividers
  static const Color borderSubtle = Color(0xFF1E293B);
  static const Color borderGlow = Color(0x3300D2FF);

  // Neumorphic Dual Shadow Tokens
  static const Color shadowDark = Color(0xCC000000); // 80% opacity black
  static const Color shadowLight = Color(0x0FFFFFFF); // 6% specular rim light

  // Gradients
  static const LinearGradient orangeCtaGradient = LinearGradient(
    colors: [primaryOrange, primaryOrangeLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient droneHeaderGradient = LinearGradient(
    colors: [Color(0xFF1C2541), Color(0xFF0B132B)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient goldTrophyGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient teacherPurpleGradient = LinearGradient(
    colors: [Color(0xFF7928CA), Color(0xFF4E54C8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
