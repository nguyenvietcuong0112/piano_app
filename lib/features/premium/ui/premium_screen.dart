import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/helper/iap_helper.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_border_card.dart';
import '../../../core/widgets/primary_button.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  // 'monthly' or 'weekly'
  String _selectedPackage = 'monthly';

  @override
  void initState() {
    super.initState();
    AppConstants.isPremiumUser.addListener(_onPremiumStatusChanged);
    IAPHelper.queryProducts();
  }

  @override
  void dispose() {
    AppConstants.isPremiumUser.removeListener(_onPremiumStatusChanged);
    super.dispose();
  }

  void _onPremiumStatusChanged() {
    if (AppConstants.isPremiumUser.value && mounted) {
      EasyLoading.showSuccess('Premium Unlocked!');
      if (context.canPop()) {
        context.pop();
      }
    }
  }

  Future<void> _handleBuy() async {
    final productId = _selectedPackage == 'weekly'
        ? IAPHelper.weeklyProductId
        : IAPHelper.monthlyProductId;

    final productDetails = IAPHelper.productsMap.value[productId];

    if (productDetails != null) {
      final success = await IAPHelper.buyProduct(productDetails);
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.tr('purchase_init_error')),
          ),
        );
      }
    } else {
      // Fallback if products could not be fetched from store (e.g. Sandbox/Emulator without Store login)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.tr('store_not_available')),
        ),
      );
    }
  }

  Future<void> _handleRestore() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.tr('restoring_purchases')),
        duration: const Duration(seconds: 2),
      ),
    );
    await IAPHelper.restorePurchases();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0XFF06012F),
      body: ValueListenableBuilder<bool>(
        valueListenable: IAPHelper.isLoading,
        builder: (context, isLoading, child) {
          return Stack(
            children: [
              // Full Screen Background Image
              Positioned.fill(
                child: Image.asset(
                  'assets/images/img_bg_premium.webp',
                  fit: BoxFit.contain,
                ),
              ),

              // Scrollable Content
              SafeArea(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: 0.35.sh),

                          // Title: "Learn Piano"
                          Text(
                            context.tr('app_title'),
                            style: AppTextStyles.textWhite22.copyWith(
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // 2. Feature Checklist (6 items)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 40.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildFeatureItem("🚫", context.tr('remove_ads')),
                                SizedBox(height: 8.h),
                                _buildFeatureItem("🎵", context.tr('my_song_collection')),
                                SizedBox(height: 8.h),
                                _buildFeatureItem("🎨", context.tr('piano_keyboard_themes')),
                                SizedBox(height: 8.h),
                                _buildFeatureItem("🎹", context.tr('piano')),
                                SizedBox(height: 8.h),
                                _buildFeatureItem("🎙️", context.tr('recordings')),
                                SizedBox(height: 8.h),
                                _buildFeatureItem("⭐", context.tr('unlock_all_features')),
                              ],
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // 3. Package Selection Cards (Weekly vs Monthly)
                          ValueListenableBuilder(
                            valueListenable: IAPHelper.productsMap,
                            builder: (context, products, child) {
                              final weeklyProduct = products[IAPHelper.weeklyProductId];
                              final monthlyProduct = products[IAPHelper.monthlyProductId];

                              final weeklyPrice = weeklyProduct?.price ?? "\$3.99";
                              final monthlyPrice = monthlyProduct?.price ?? "\$8.99";

                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: Column(
                                  children: [
                                    // Weekly Package Card
                                    _buildPackageCard(
                                      packageKey: 'weekly',
                                      title: context.tr('weekly_pro'),
                                      price: weeklyPrice,
                                      isPopular: false,
                                    ),

                                    SizedBox(height: 12.h),

                                    // Monthly Package Card
                                    _buildPackageCard(
                                      packageKey: 'monthly',
                                      title: context.tr('monthly_pro'),
                                      price: monthlyPrice,
                                      subtitle: context.tr('save_44_percent'),
                                      isPopular: true,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),

                          SizedBox(height: 16.h),

                          // Pricing Note
                          Text(
                            context.tr('cancel_anytime'),
                            style: AppTextStyles.textWhite12.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // 4. CTA Button
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: PrimaryButton(
                              backgroundGradient: const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color(0xFF7A44DA),
                                  Color(0xFFCF6BEE),
                                ],
                              ),
                              borderGradient: null,
                              innerShadows: [
                                BoxShadow(
                                  offset: const Offset(1, 2),
                                  blurRadius: 2,
                                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.25),
                                ),
                                BoxShadow(
                                  offset: const Offset(-1, -2),
                                  blurRadius: 2,
                                  color: const Color(0xFFFFFFFF).withValues(alpha: 0.25),
                                ),
                              ],
                              text: isLoading ? '...' : context.tr('continue'),
                              onTap: isLoading ? () {} : _handleBuy,
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // 5. Footer Links (Restore Purchase | Privacy Policy | Terms of Use)
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildFooterLink(
                                  context.tr('restore_purchase'),
                                  onTap: _handleRestore,
                                ),
                                Text("|", style: AppTextStyles.textGrey12),
                                _buildFooterLink(context.tr('policy')),
                                Text("|", style: AppTextStyles.textGrey12),
                                _buildFooterLink(context.tr('terms_of_use')),
                              ],
                            ),
                          ),

                          SizedBox(height: 30.h),
                        ],
                      ),
                    ),

                    // Top Close Button (Top-Right)
                    Positioned(
                      top: 8.h,
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

                    if (isLoading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black38,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFCF6BEE),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
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
            style: AppTextStyles.textWhite14,
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

    return GradientBorderCard(
      onTap: () {
        setState(() {
          _selectedPackage = packageKey;
        });
      },
      height: 70.h,
      borderRadius: 30.r,
      strokeWidth: 2.0,
      backgroundGradient: isSelected
          ? const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF7A44DA),
                Color(0xFFCF6BEE),
              ],
            )
          : const LinearGradient(
              colors: [
                Color(0xFF191329),
                Color(0xFF191329),
              ],
            ),
      borderGradient: isSelected
          ? const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0x80FFFFFF),
                Color(0x00FFFFFF),
                Color(0x80AD57E6),
              ],
              stops: [0.0, 0.5, 1.0],
            )
          : LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color(0xFFFFFFFF).withValues(alpha: 0.25),
                const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                const Color(0xFFFFFFFF).withValues(alpha: 0.25),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
      innerShadows: isSelected
          ? [
              BoxShadow(
                offset: const Offset(-1, -2),
                blurRadius: 2,
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.25),
              ),
              BoxShadow(
                offset: const Offset(1, 2),
                blurRadius: 2,
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.25),
              ),
            ]
          : null,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.textWhite14.copyWith(
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
                              context.tr('most_popular'),
                              style: AppTextStyles.textWhite12.copyWith(
                                fontSize: 10,
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
            style: AppTextStyles.textWhite16.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap ??
          () {
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
