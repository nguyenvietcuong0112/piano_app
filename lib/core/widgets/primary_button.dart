import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'gradient_border_card.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final double? width;
  final double height;
  final double borderRadius;
  final Gradient? backgroundGradient;
  final Gradient? borderGradient;
  final Widget? icon;
  final Widget? child;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onTap,
    this.width = double.infinity,
    this.height = 52,
    this.borderRadius = 26,
    this.backgroundGradient,
    this.borderGradient,
    this.icon,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBgGradient = backgroundGradient ?? AppColors.primaryButtonGradient;
    final effectiveBorderGradient = borderGradient ?? AppColors.secondaryBorderGradient;

    return GradientBorderCard(
      width: width,
      height: height.h,
      borderRadius: borderRadius.r,
      strokeWidth: 1.0,
      backgroundGradient: effectiveBgGradient,
      borderGradient: effectiveBorderGradient,
      onTap: onTap,
      child: Center(
        child: child ??
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  icon!,
                  SizedBox(width: 8.w),
                ],
                Text(
                  text,
                  style: AppTextStyles.textWhite16.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
      ),
    );
  }
}
