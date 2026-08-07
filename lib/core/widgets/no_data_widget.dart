import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_text_styles.dart';

class NoDataWidget extends StatelessWidget {
  final String? imageAsset;
  final double? imageHeight;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final IconData? actionIcon;
  final EdgeInsetsGeometry? padding;

  const NoDataWidget({
    super.key,
    this.imageAsset = 'assets/images/img_nodata.png',
    this.imageHeight,
    this.title = "Không có dữ liệu",
    this.subtitle,
    this.actionText,
    this.onActionPressed,
    this.actionIcon,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: padding ?? EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (imageAsset != null && imageAsset!.isNotEmpty)
              Image.asset(
                imageAsset!,
                height: imageHeight ?? 160.h,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.inbox_rounded,
                  size: (imageHeight ?? 100).r,
                  color: Colors.white24,
                ),
              ),
            SizedBox(height: 16.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.textWhite18,
            ),
            if (subtitle != null && subtitle!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.textGrey14.copyWith( height: 1.4),
              ),
            ],
            if (actionText != null && onActionPressed != null) ...[
              SizedBox(height: 20.h),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFAD57E6),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 4,
                ),
                onPressed: onActionPressed,
                icon: Icon(actionIcon ?? Icons.explore_rounded, size: 18.r),
                label: Text(
                  actionText!,
                  style: AppTextStyles.textWhite14.copyWith( fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
