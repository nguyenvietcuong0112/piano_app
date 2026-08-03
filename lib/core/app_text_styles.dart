import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Headings & App Titles
  static TextStyle get h1 => GoogleFonts.inter(
        fontSize: 26.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get h2 => GoogleFonts.inter(
        fontSize: 22.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
        height: 1.2,
      );

  static TextStyle get h3 => GoogleFonts.inter(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  static TextStyle get sectionHeader => GoogleFonts.inter(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  // Subtitles & Item Titles
  static TextStyle get titleMedium => GoogleFonts.inter(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get titleSmall => GoogleFonts.inter(
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      );

  // Body Text
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.textSecondary,
      );

  static TextStyle get bodyMedium => GoogleFonts.inter(
        fontSize: 13.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.textMuted,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: AppColors.textMuted,
      );

  // Buttons & Badges
  static TextStyle get buttonLabel => GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black,
        letterSpacing: 0.5,
      );

  static TextStyle get badgeText => GoogleFonts.inter(
        fontSize: 11.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
      );

  static TextStyle get pianoKeyBadge => GoogleFonts.inter(
        fontSize: 12.sp,
        fontWeight: FontWeight.w800,
        color: AppColors.textDark,
      );
}
