import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_service.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/theme_image.dart';
import '../domain/theme_model.dart';

class AllThemesScreen extends ConsumerStatefulWidget {
  final ThemeCategory category;

  const AllThemesScreen({super.key, required this.category});

  @override
  ConsumerState<AllThemesScreen> createState() => _AllThemesScreenState();
}

class _AllThemesScreenState extends ConsumerState<AllThemesScreen> {
  Future<void> _applyTheme(ThemeItem theme) async {
    await ThemeService.setTheme(theme.resName, theme.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Applied Theme: ${theme.titleName}"),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Header Bar with Back Button & Category Title
          Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40.sp,
                    height: 40.sp,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/ic_back.svg',
                      width: 40.sp,
                      height: 40.sp,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Text(
                    widget.category.categoryName,
                    style: AppTextStyles.textWhite22.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Subtitle Header
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Text(
              widget.category.categoryName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // List of Theme Cards
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: 30.h),
              itemCount: widget.category.items.length,
              itemBuilder: (context, index) {
                final theme = widget.category.items[index];
                return _buildThemeCard(theme);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeCard(ThemeItem theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: const Color(0xFF141126),
        gradient: const LinearGradient(
          colors: [Color(0xFF141126), Color(0xFF0F0F1E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/theme-preview', extra: theme),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(12.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Theme Image Banner Area
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: SizedBox(
                    height: 140.h,
                    child: ThemeImage(
                      resName: theme.resName,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(height: 10.h),
                // Theme Title Name
                Text(
                  theme.titleName,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
