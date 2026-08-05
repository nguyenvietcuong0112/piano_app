import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  // 'monthly' or 'weekly'
  String _selectedPackage = 'monthly';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // Scrollable Content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  // 1. Top Illustration Graphic Header
                  Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        height: 320.h,
                        width: double.infinity,
                        foregroundDecoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                              Colors.black,
                            ],
                            stops: const [0.5, 0.85, 1.0],
                          ),
                        ),
                        child: Image.asset(
                          'assets/images/img_acoustic_piano.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: const Color(0xFF231138),
                            child: Icon(
                              Icons.piano_rounded,
                              size: 100.sp,
                              color: AppColors.brandPurple,
                            ),
                          ),
                        ),
                      ),

                      // Title: "Learn Piano"
                      Positioned(
                        bottom: 10.h,
                        child: Text(
                          "Learn Piano",
                          style: AppTextStyles.textWhite22.copyWith(
                            fontSize: 28.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // 2. Feature Checklist (6 items)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFeatureItem("🚫", "No Ads"),
                        SizedBox(height: 10.h),
                        _buildFeatureItem("🎵", "Unlock all Songs"),
                        SizedBox(height: 10.h),
                        _buildFeatureItem("🎨", "Unlock all Piano Themes"),
                        SizedBox(height: 10.h),
                        _buildFeatureItem("🎹", "Unlock Premium Instruments"),
                        SizedBox(height: 10.h),
                        _buildFeatureItem("🎙️", "Keyboard Recording"),
                        SizedBox(height: 10.h),
                        _buildFeatureItem("⭐", "Premium Features"),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 3. Package Selection Cards (Weekly vs Monthly)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      children: [
                        // Weekly Package Card
                        _buildPackageCard(
                          packageKey: 'weekly',
                          title: "Weekly PRO",
                          price: "\$3.99",
                          isPopular: false,
                        ),

                        SizedBox(height: 12.h),

                        // Monthly Package Card
                        _buildPackageCard(
                          packageKey: 'monthly',
                          title: "Monthly PRO",
                          price: "\$8.99",
                          subtitle: "Save 44% compared to weekly",
                          isPopular: true,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Pricing Note
                  Text(
                    "\$1.99/week. Cancel Anytime",
                    style: AppTextStyles.textWhite12.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 18.h),

                  // 4. Continue CTA Button
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: const Color(0xFF7E26D4),
                            content: Text(
                              "🎉 Bạn đã đăng ký thành công gói ${_selectedPackage.toUpperCase()} PRO!",
                              style: AppTextStyles.textWhite14,
                            ),
                          ),
                        );
                        context.pop();
                      },
                      child: Container(
                        width: double.infinity,
                        height: 52.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30.r),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFB158F0), Color(0xFF7E26D4)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB158F0).withValues(alpha: 0.4),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            "Continue",
                            style: AppTextStyles.textWhite16.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  // 5. Footer Links (Restore Purchase | Privacy Policy | Terms of Use)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildFooterLink("Restore Purchase"),
                        Text("|", style: AppTextStyles.textGrey12),
                        _buildFooterLink("Privacy Policy"),
                        Text("|", style: AppTextStyles.textGrey12),
                        _buildFooterLink("Terms of Use"),
                      ],
                    ),
                  ),

                  SizedBox(height: 30.h),
                ],
              ),
            ),

            // Top Close Button (Top-Right)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8.h,
              right: 16.w,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String iconText, String title) {
    return Row(
      children: [
        SizedBox(
          width: 24.w,
          child: Text(
            iconText,
            style: TextStyle(fontSize: 15.sp),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: AppTextStyles.textWhite14.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPackageCard({
    required String packageKey,
    required String title,
    required String price,
    String? subtitle,
    required bool isPopular,
  }) {
    final bool isSelected = _selectedPackage == packageKey;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackage = packageKey;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30.r),
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFB158F0), Color(0xFF7E26D4)],
                )
              : null,
          color: isSelected ? null : const Color(0xFF191329),
          border: Border.all(
            color: isSelected ? Colors.transparent : const Color(0xFF3B2B54),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.textWhite16.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isPopular) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected ? Colors.white70 : AppColors.brandPurple,
                            ),
                            color: Colors.transparent,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 11.sp,
                                color: isSelected ? Colors.white : AppColors.brandPurple,
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                "Most Popular",
                                style: AppTextStyles.textWhite12.copyWith(
                                  fontSize: 10.sp,
                                  color: isSelected ? Colors.white : AppColors.brandPurple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.textWhite12.copyWith(
                        color: isSelected ? Colors.white70 : AppColors.textGrey,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Text(
              price,
              style: AppTextStyles.textWhite18.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterLink(String title) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(title),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Text(
        title,
        style: AppTextStyles.textGrey12.copyWith(
          fontSize: 11.sp,
        ),
      ),
    );
  }
}
