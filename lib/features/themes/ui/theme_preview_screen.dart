import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/widgets/app_loading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/shared_preference_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_service.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/gradient_border_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/theme_image.dart';
import '../domain/theme_model.dart';

class ThemePreviewScreen extends StatefulWidget {
  final ThemeItem theme;

  const ThemePreviewScreen({super.key, required this.theme});

  @override
  State<ThemePreviewScreen> createState() => _ThemePreviewScreenState();
}

class _ThemePreviewScreenState extends State<ThemePreviewScreen> {
  bool _isDownloaded = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  Timer? _downloadTimer;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  @override
  void dispose() {
    _downloadTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    final downloaded = await SharedPreferenceService.isThemeDownloaded(widget.theme.resName);
    if (mounted) {
      setState(() {
        _isDownloaded = downloaded;
      });
    }
  }

  void _startDownload() {
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    _downloadTimer?.cancel();
    _downloadTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _downloadProgress += 0.1;
        if (_downloadProgress >= 1.0) {
          _downloadProgress = 1.0;
          _isDownloading = false;
          _isDownloaded = true;
          timer.cancel();
          SharedPreferenceService.setThemeDownloaded(widget.theme.resName);
        }
      });
    });
  }

  Future<void> _applyTheme() async {
    await ThemeService.setTheme(widget.theme.resName, widget.theme.id);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Applied Theme: ${widget.theme.titleName}"),
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
              // Header Bar with Back Button & Title "Preview"
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
                      "Preview",
                      style: AppTextStyles.textWhite22.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Theme Preview Card Frame
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
                    color: isCurrentlyActive ? AppColors.textGrey.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.10),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Theme Image Area
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
                    // Theme Name
                    // Text(
                    //   widget.theme.titleName,
                    //   style: TextStyle(
                    //     color: Colors.white,
                    //     fontSize: 16.sp,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    //   textAlign: TextAlign.center,
                    // ),
                    // SizedBox(height: 6.h),
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
          "You’re currently using this theme",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 24.h),

        // Primary Button: "Play Piano"
        PrimaryButton(
          text: "Play Piano",
          onTap: () {
            context.go('/themes');
            context.push('/play');
          },
        ),

        SizedBox(height: 14.h),

        // Secondary Button: "Explore More Themes"
        PrimaryButton(
          text: "Explore More Themes",
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
        ? "Downloading ${(_downloadProgress * 100).toInt()}%"
        : (!_isDownloaded ? "Download" : "Apply");

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
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_isDownloading)
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: _downloadProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryButtonGradient,
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                  ),
                ),
              ),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // if (_isDownloading) ...[
              //   SizedBox(
              //     width: 24.sp,
              //     height: 24.sp,
              //     child: const AppLoading(width: 24, height: 24),
              //   ),
              //   SizedBox(width: 10.w),
              // ],
              Text(
                buttonText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
