import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_service.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/theme_image.dart';
import '../domain/theme_model.dart';

class ThemePreviewScreen extends ConsumerStatefulWidget {
  final ThemeItem theme;

  const ThemePreviewScreen({super.key, required this.theme});

  @override
  ConsumerState<ThemePreviewScreen> createState() => _ThemePreviewScreenState();
}

class _ThemePreviewScreenState extends ConsumerState<ThemePreviewScreen> {
  bool _isDownloaded = true;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _checkDownloadState();
  }

  void _checkDownloadState() {
    _isDownloaded = true;
  }

  void _startDownload() async {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 150));
      if (!mounted) return;
      setState(() {
        _downloadProgress = i / 10.0;
      });
    }

    if (!mounted) return;
    setState(() {
      _isDownloading = false;
      _isDownloaded = true;
    });

    _applyTheme();
  }

  Future<void> _applyTheme() async {
    await ThemeService.setTheme(widget.theme.resName, widget.theme.id);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${context.tr('applied_theme')} ${widget.theme.titleName}"),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: ThemeService.currentThemeRes,
      builder: (context, currentThemeRes, child) {
        final bool isCurrentlyActive = currentThemeRes == widget.theme.resName;

        return AppScaffold(
          backgroundColor: AppColors.scaffoldBackground,
          body: Column(
            children: [
              // Header Bar with Back Button & Title
              Padding(
                padding: EdgeInsets.only(top: 8.h, bottom: 20.h),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: GestureDetector(
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
                    ),
                    Text(
                      context.tr('preview'),
                      style: AppTextStyles.textWhite22.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Theme Preview Card Container
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.sp),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF141126), Color(0xFF0F0F1E)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  border: Border.all(
                    color: isCurrentlyActive
                        ? AppColors.textGrey.withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.10),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: SizedBox(
                        height: 160.h,
                        width: double.infinity,
                        child: ThemeImage(
                          resName: widget.theme.resName,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 28.h),

              // Dynamic Action Area: Success State vs Download/Apply Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: isCurrentlyActive
                    ? _buildAppliedSuccessSection(context)
                    : _buildDownloadOrApplyButton(),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Section displayed after theme is successfully applied
  Widget _buildAppliedSuccessSection(BuildContext context) {
    return Column(
      children: [
        // Success Notice Text
        Text(
          context.tr('applied'),
          style: AppTextStyles.textWhite16.copyWith(fontSize: 15.sp, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 24.h),

        // Primary Button: "Play Piano"
        PrimaryButton(
          text: context.tr('play_piano'),
          onTap: () {
            context.go('/themes');
            context.push('/play');
          },
        ),

        SizedBox(height: 14.h),

        // Secondary Button: "Explore More Themes"
        PrimaryButton(
          text: context.tr('explore_more_themes'),
          backgroundGradient: AppColors.secondaryButtonGradient,
          borderGradient: AppColors.secondaryBorderGradient,
          onTap: () => context.pop(),
        ),
      ],
    );
  }

  /// Single action button for Download or Apply
  Widget _buildDownloadOrApplyButton() {
    final String buttonText = _isDownloading
        ? "${context.tr('downloading')} ${(_downloadProgress * 100).toInt()}%"
        : (!_isDownloaded ? context.tr('download') : context.tr('apply'));

    return PrimaryButton(
      text: buttonText,
      onTap: () {
        if (_isDownloading) return;
        if (!_isDownloaded) {
          _startDownload();
        } else {
          _applyTheme();
        }
      },
    );
  }
}
