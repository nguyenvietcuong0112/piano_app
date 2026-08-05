import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background & Surfaces
  static const Color background = Color(0xFF0F0F1E);
  static const Color scaffoldBackground = Color(0xFF06060E);
  static const Color surface = Color(0xFF1E1E2C);
  static const Color surfaceDark = Color(0xFF14141A);
  static const Color cardDark = Color(0xFF181528);
  static const Color cardBackground = Color(0xFF1F0248);
  static const Color iconContainerBg = Color(0xFF2A233D);
  static const Color buttonDarkBg = Color(0xFF1E1C2E);

  // Primary Brand Colors (Purple theme)
  static const Color primary = Color(0xFFAD57E6);
  static const Color brandPurple = Color(0xFFAD57E6);
  static const Color brandPurpleLight = Color(0xFFCE75FF);
  static const Color brandPurpleDark = Color(0xFF8B44CF);
  static const Color primaryLight = Color(0xFFFFD54F);
  static const Color primaryDark = Color(0xFFFFB300);

  // Difficulty Level Colors
  static const Color levelEasy = Color(0xFF63F27B);
  static const Color levelMedium = Color(0xFFF2EE63);
  static const Color levelHard = Color(0xFFF26363);

  // Instrument Card Gradients
  static const Color organGradientStart = Color(0xFF381552);
  static const Color synthGradientStart = Color(0xFF0C2B4E);
  static const Color rhodesGradientStart = Color(0xFF0A3337);
  static const Color brightGradientStart = Color(0xFF45220E);

  // Accent & Highlight Colors
  static const Color accentPurple = Color(0xFF6B21A8);
  static const Color accentPurpleDark = Color(0xFF3B0764);
  static const Color accentOrange = Color(0xFFFFA726);
  static const Color accentBlue = Color(0xFF29B6F6);

  // Core Text Colors (4 Core Colors)
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textBlack = Color(0xFF000000);
  static const Color textGrey = Color(0xFF9592A5);
  static const Color textPurple = Color(0xFFD065F2);
  static const Color textDark = Color(0xFF1B3828);

  // Piano Key Colors & Badges
  static const Color keyWhite = Color(0xFFF9F9FB);
  static const Color keyWhiteBorder = Color(0xFFD0D0D5);
  static const Color keyBlack = Color(0xFF1E1E24);
  static const Color keyPressed = Color(0xFF4CAF50);

  // Key Label Octave Pill Colors
  static const Color octave3Pill = Color(0xFFA8E063);
  static const Color octave4Pill = Color(0xFF80E2B7);
  static const Color octave5Pill = Color(0xFF80D8FF);
  static const Color octaveDefaultPill = Color(0xFFCE93D8);

  // Status & Utility
  static const Color success = Colors.greenAccent;
  static const Color error = Colors.redAccent;
  static const Color warning = Colors.amber;
  static const Color recordRed = Colors.red;
}
