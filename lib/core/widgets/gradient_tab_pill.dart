import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import '../theme/app_text_styles.dart';
import 'gradient_border_card.dart';

class GradientTabPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const GradientTabPill({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(right: 8),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              gradient: const LinearGradient(
                colors: [Color(0xFF5333A5),Color(0xFF8B56ED)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              border:  GradientBoxBorder(
                width: 1,
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFCE64F0).withValues(alpha: 0.5),
                    Color(0xFF999999).withValues(alpha: 0.5),
                    Color(0xFFFFFFFF).withValues(alpha: 0.5),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
            child: Center(
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: Text(
                label,
                style: AppTextStyles.textWhite14.copyWith(fontWeight: FontWeight.bold,fontSize: 14),
              ),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xFF181528),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.textGrey14.copyWith(fontWeight: FontWeight.bold,fontSize: 14),
        ),
      ),
    );
  }
}
