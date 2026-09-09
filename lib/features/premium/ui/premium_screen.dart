import 'dart:async';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/helper/firebase_helper.dart';
import '../../../core/helper/iap_helper.dart';
import '../../../core/services/firebase_remote_config_service.dart';
import '../../../core/services/shared_preference_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_border_card.dart';
import '../../../core/widgets/primary_button.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  // 'weekly', 'monthly', 'yearly', 'lifetime', 'lifetime_sale'
  String _selectedPackage = 'lifetime_sale';

  bool _isFlashSaleActive = false;
  Duration _flashSaleRemaining = Duration.zero;
  Timer? _flashSaleTimer;

  int _countdown = 0;
  int _totalCountdown = 0;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    FirebaseHelper.logEventName(FirebaseHelper.premium_view);
    AppConstants.isPremiumUser.addListener(_onPremiumStatusChanged);
    IAPHelper.queryProducts();

    _initFlashSale();

    _totalCountdown = FirebaseRemoteConfigService.getIntConfigByKey(
      FirebaseRemoteConfigService.time_delay_close_premium,
      defaultValue: 3,
    );
    _countdown = _totalCountdown;
    if (_countdown > 0) {
      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_countdown > 1) {
          setState(() {
            _countdown--;
          });
        } else {
          setState(() {
            _countdown = 0;
          });
          timer.cancel();
        }
      });
    }
  }

  Future<void> _initFlashSale() async {
    final remaining = await SharedPreferenceService.getFlashSaleRemainingDuration();
    if (!mounted) return;

    if (remaining > Duration.zero) {
      setState(() {
        _isFlashSaleActive = true;
        _flashSaleRemaining = remaining;
        _selectedPackage = 'lifetime_sale';
      });
      _startFlashSaleTimer();
    } else {
      setState(() {
        _isFlashSaleActive = false;
        _selectedPackage = 'weekly';
      });
    }
  }

  void _startFlashSaleTimer() {
    _flashSaleTimer?.cancel();
    _flashSaleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_flashSaleRemaining.inSeconds > 1) {
        setState(() {
          _flashSaleRemaining -= const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
        setState(() {
          _flashSaleRemaining = Duration.zero;
          _isFlashSaleActive = false;
          if (_selectedPackage == 'lifetime_sale') {
            _selectedPackage = 'weekly';
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _flashSaleTimer?.cancel();
    AppConstants.isPremiumUser.removeListener(_onPremiumStatusChanged);
    super.dispose();
  }

  void _onPremiumStatusChanged() {
    if (AppConstants.isPremiumUser.value && mounted) {
      EasyLoading.showSuccess('Premium Unlocked!');
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    }
  }

  Future<void> _handleBuy() async {
    EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);

    String productId;
    switch (_selectedPackage) {
      case 'weekly':
        productId = IAPHelper.weeklyProductId;
        FirebaseHelper.logEventClickPurchaseWeekly(productId: productId);
        break;
      case 'monthly':
        productId = IAPHelper.monthlyProductId;
        FirebaseHelper.logEventClickPurchaseMonthly(productId: productId);
        break;
      case 'yearly':
        productId = IAPHelper.yearlyProductId;
        FirebaseHelper.logEventClickPurchaseYearly(productId: productId);
        break;
      case 'lifetime':
        productId = IAPHelper.lifetimeProductId;
        FirebaseHelper.logEventClickPurchaseLifetime(productId: productId);
        break;
      case 'lifetime_sale':
      default:
        productId = IAPHelper.effectiveLifetimeSaleProductId;
        FirebaseHelper.logEventClickPurchaseLifetimeSale(productId: productId);
        break;
    }

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
    EasyAds.instance.appLifecycleReactor?.setIsExcludeScreen(true);
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
    return PopScope(
      canPop: _countdown == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _countdown == 0) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/home');
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0XFF06012F),
        body: ValueListenableBuilder<bool>(
          valueListenable: IAPHelper.isLoading,
          builder: (context, isLoading, child) {
            return Stack(
              children: [
                // Top Full Screen Background Image
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/img_bg_premium.webp',
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
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
                            SizedBox(height: 0.31.sh),

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

                            // 2-Column Feature Checklist
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildFeatureItem("🚫", context.tr('remove_ads')),
                                        SizedBox(height: 6.h),
                                        _buildFeatureItem("🎵", context.tr('unlock_all_songs')),
                                        SizedBox(height: 6.h),
                                        _buildFeatureItem("🎨", context.tr('unlock_all_themes')),
                                      ],
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildFeatureItem("🎹", context.tr('unlock_premium_instruments')),
                                        SizedBox(height: 6.h),
                                        _buildFeatureItem("🎙️", context.tr('keyboard_recording')),
                                        SizedBox(height: 6.h),
                                        _buildFeatureItem("⭐", context.tr('premium_features')),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 12.h),
                            Padding(
                              padding: EdgeInsets.only(left: 16.w,right: 4.w),
                              child: _buildFlashSaleBanner(),
                            ),
                            SizedBox(height: 8.h),

                            // 3. Package Selection Cards (Dynamic according to Flash Sale state)
                            ValueListenableBuilder<Map<String, ProductDetails>>(
                              valueListenable: IAPHelper.productsMap,
                              builder: (context, products, child) {
                                final weeklyProduct = products[IAPHelper.weeklyProductId];
                                final monthlyProduct = products[IAPHelper.monthlyProductId];
                                final yearlyProduct = products[IAPHelper.yearlyProductId];
                                final lifetimeProduct = products[IAPHelper.lifetimeProductId];
                                final saleProduct = products[IAPHelper.effectiveLifetimeSaleProductId];

                                final weeklyPrice = weeklyProduct?.price ?? "\$3.99";
                                final monthlyPrice = monthlyProduct?.price ?? "\$8.99";
                                final yearlyPrice = yearlyProduct?.price ?? "\$29.99";
                                final lifetimePrice = lifetimeProduct?.price ?? "\$59.99";
                                final salePrice = saleProduct?.price ?? "\$29.99";

                                if (_isFlashSaleActive) {
                                  // --- FLASH SALE STATE UI ---
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                                    child: Column(
                                      children: [
                                        // Featured Lifetime 50% Card
                                        _buildFeaturedLifetimeSaleCard(
                                          originalPrice: lifetimePrice,
                                          salePrice: salePrice,
                                        ),

                                        SizedBox(height: 10.h),

                                        // Weekly Package Card
                                        _buildPackageCard(
                                          packageKey: 'weekly',
                                          title: context.tr('weekly_pro'),
                                          price: weeklyPrice,
                                        ),

                                        SizedBox(height: 10.h),

                                        // Monthly Package Card
                                        _buildPackageCard(
                                          packageKey: 'monthly',
                                          title: context.tr('monthly_pro'),
                                          price: monthlyPrice,
                                        ),

                                        SizedBox(height: 10.h),

                                        // Yearly Package Card
                                        _buildPackageCard(
                                          packageKey: 'yearly',
                                          title: context.tr('yearly_pro'),
                                          price: yearlyPrice,
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                // --- NORMAL STATE UI (Flash sale expired) ---
                                return Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                                  child: Column(
                                    children: [
                                      // Weekly Package Card
                                      _buildPackageCard(
                                        packageKey: 'weekly',
                                        title: context.tr('weekly_pro'),
                                        price: weeklyPrice,
                                      ),

                                      SizedBox(height: 10.h),

                                      // Monthly Package Card
                                      _buildPackageCard(
                                        packageKey: 'monthly',
                                        title: context.tr('monthly_pro'),
                                        price: monthlyPrice,
                                      ),

                                      SizedBox(height: 10.h),

                                      // Yearly Package Card
                                      _buildPackageCard(
                                        packageKey: 'yearly',
                                        title: context.tr('yearly_pro'),
                                        price: yearlyPrice,
                                      ),

                                      SizedBox(height: 10.h),

                                      // Lifetime Package Card
                                      _buildPackageCard(
                                        packageKey: 'lifetime',
                                        title: context.tr('lifetime_pro'),
                                        price: lifetimePrice,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: 16.h),

                            // Pricing Subtext
                            Text(
                              context.tr('cancel_anytime'),
                              style: AppTextStyles.textWhite12.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                            ),

                            SizedBox(height: 20.h),

                            // 4. CTA Continue Button
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
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

                            SizedBox(height: 20.h),

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

                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),

                      // Top Close Button (Top-Right)
                      Positioned(
                        top: 8.h,
                        right: 16.w,
                        child: _countdown > 0
                            ? SizedBox(
                                width: 36.r,
                                height: 36.r,
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    TweenAnimationBuilder<double>(
                                      tween: Tween<double>(
                                        begin: 1.0,
                                        end: _totalCountdown > 0
                                            ? _countdown / _totalCountdown
                                            : 0.0,
                                      ),
                                      duration: const Duration(seconds: 1),
                                      builder: (context, value, _) {
                                        return SizedBox(
                                          width: 36.r,
                                          height: 36.r,
                                          child: CircularProgressIndicator(
                                            value: value,
                                            color: Colors.white70,
                                            strokeWidth: 2,
                                          ),
                                        );
                                      },
                                    ),
                                    Text(
                                      '$_countdown',
                                      style: AppTextStyles.textWhite14.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : GestureDetector(
                                onTap: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go('/home');
                                  }
                                },
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
      ),
    );
  }

  Widget _buildFeatureItem(String iconText, String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          iconText,
          style: TextStyle(fontSize: 13.sp),
        ),
        SizedBox(width: 6.w),
        Flexible(
          child: Text(
            title,
            style: AppTextStyles.textWhite12.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  /// Flash Sale Banner with Figma 3D Graphic (banner_sales.png) & Live Countdown Timer
  Widget _buildFlashSaleBanner() {
    final hours = _flashSaleRemaining.inHours.toString().padLeft(2, '0');
    final minutes = (_flashSaleRemaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_flashSaleRemaining.inSeconds % 60).toString().padLeft(2, '0');

    return AspectRatio(
      aspectRatio: 1185 / 414,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Figma 3D Graphic Banner (Preserves true aspect ratio, zero distortion)
          Positioned.fill(
            child: Image.asset(
              'assets/images/banner_sales.webp',
              fit: BoxFit.contain,
            ),
          ),

          // 2. Positioned countdown timer in the right purple section
          Positioned.fill(
            child: Row(
              children: [
                // Left 54% is occupied by the 3D Graphic & SALE 50% tag
                const Spacer(flex: 54),

                // Right 46% contains the Countdown Timer
                Expanded(
                  flex: 46,
                  child: Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          context.tr('ends_in'),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTimerColumn(hours, context.tr('hours')),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 3.h),
                              child: Text(
                                ':',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                            _buildTimerColumn(minutes, context.tr('minutes')),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 3.h),
                              child: Text(
                                ':',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                            _buildTimerColumn(seconds, context.tr('seconds')),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerColumn(String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildTimerBox(value),
        SizedBox(height: 2.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 7.sp,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTimerBox(String value) {
    return Container(
      width: 25.w,
      height: 25.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF130826).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(5.r),
        border: Border.all(
          color: const Color(0xFF6E40A8).withValues(alpha: 0.9),
          width: 1.0,
        ),
      ),
      child: Text(
        value,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w900, 
          color: Colors.white,
        ),
      ),
    );
  }

  /// Featured Lifetime PRO 50% Card (Light Pink glowing card)
  Widget _buildFeaturedLifetimeSaleCard({
    required String originalPrice,
    required String salePrice,
  }) {
    final bool isSelected = _selectedPackage == 'lifetime_sale';

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPackage = 'lifetime_sale';
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF0F8), Color(0xFFFFDDF0)],
          ),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF2A85) : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFFF2A85).withValues(alpha: 0.45)
                  : const Color(0xFFFF2A85).withValues(alpha: 0.2),
              blurRadius: isSelected ? 14 : 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        context.tr('lifetime_pro'),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF1E0A2A),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF1493),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          context.tr('best_deal'),
                          style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    context.tr('one_time_purchase_desc'),
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF6B3A6F),
                    ),
                  ),
                ],
              ),
            ),

            // Price column: Strikethrough original price & bold bright sale price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  originalPrice,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                Text(
                  salePrice,
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFFF1493),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Standard Package Card for Weekly, Monthly, Yearly, Lifetime
  Widget _buildPackageCard({
    required String packageKey,
    required String title,
    required String price,
  }) {
    final bool isSelected = _selectedPackage == packageKey;

    return GradientBorderCard(
      onTap: () {
        setState(() {
          _selectedPackage = packageKey;
        });
      },
      width: double.infinity,
      height: 58.h,
      borderRadius: 24.r,
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
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTextStyles.textWhite14.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
          Text(
            price,
            style: AppTextStyles.textWhite16.copyWith(
              fontWeight: FontWeight.w900,
              fontSize: 15.sp,
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
