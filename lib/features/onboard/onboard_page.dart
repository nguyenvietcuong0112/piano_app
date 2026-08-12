import 'package:dots_indicator/dots_indicator.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ads/dimens/ad_dimen.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'onboard_controller.dart';

class OnboardPage extends ConsumerStatefulWidget {
  const OnboardPage({super.key});

  @override
  ConsumerState<OnboardPage> createState() => _OnboardPageState();
}

class _OnboardPageState extends ConsumerState<OnboardPage> {
  @override
  void initState() {
    super.initState();
    EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardControllerProvider).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(onboardControllerProvider);
    final steps = controller.getSteps();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: PageView.builder(
          controller: controller.pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: steps.length,
          onPageChanged: controller.onChangePage,
          itemBuilder: (context, index) {
            final step = steps[index];
            if (step.isFullAd) {
              return _buildFullAdPage(controller, step, steps);
            }
            return _buildIntroPage(controller, step, steps);
          },
        ),
      ),
    );
  }

  // --- Full Ad Screen ---
  Widget _buildFullAdPage(
      OnboardController controller, OnboardStep step, List<OnboardStep> steps) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.background,
      child: Stack(
        children: [
          Positioned.fill(
            child: step.fullAd?.show() ?? const SizedBox.shrink(),
          ),
          if (controller.isFullAdNextButtonVisible)
            Positioned(
              right: 20,
              top: 30,
              child: SafeArea(
                child: GestureDetector(
                  onTap: () => controller.onSelectNext(context, steps),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- Standard Onboard Screen ---
  Widget _buildIntroPage(
      OnboardController controller, OnboardStep step, List<OnboardStep> steps) {
    final bool hasAd = step.adId.isNotEmpty && !AppConstants.isPremiumUser.value;

    return Column(
      children: [
        // Top Header Image (Fills all available remaining space)
        Expanded(
          child: Image.asset(
            step.image,
            fit: step.fit,
            width: double.infinity,
          ),
        ),

        // Bottom Section (Text + Indicators + Next Button + Native Ad)
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            // Title & Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                context.tr(step.titleKey),
                style: AppTextStyles.textWhite20,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                context.tr(step.descKey),
                style: AppTextStyles.textGrey14,
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 20),

            // Bottom Layout Conditional on Page Index
            if (controller.currentTabOnboard == 0 || controller.currentTabOnboard == 3) ...[
              // Pages 1 & 4 (Small Button Layout)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildDotsIndicator(controller),
                    _buildTextNextButton(controller, steps),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              if (hasAd)
                EasyNativeAd(
                  key: ValueKey(step.adId),
                  factoryId: step.factoryId,
                  adId: step.adId,
                  adIdName: step.adIdName,
                  height: AdDimen.mediumNativeHeight,
                )
              else
                SizedBox(height: AdDimen.mediumNativeHeight),
            ] else ...[
              // Pages 2 & 3 (Big Button Layout)
              SizedBox(
                height: 20,
                child: Center(child: _buildDotsIndicator(controller)),
              ),
              const SizedBox(height: 15),
              _buildBigNextButton(controller, steps),
              const SizedBox(height: 15),
            ],
          ],
        ),
      ],
    );
  }

  // --- UI Elements ---
  Widget _buildDotsIndicator(OnboardController controller) {
    return DotsIndicator(
      dotsCount: controller.totalPage,
      position: controller.currentTabOnboard,
      decorator: DotsDecorator(
        color: Color(0XFF141126),
        activeColor: AppColors.textPurple,
        size: const Size(30, 8),
        activeSize: const Size(30, 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        spacing: const EdgeInsets.only(right: 8),
      ),
    );
  }

  Widget _buildTextNextButton(
      OnboardController controller, List<OnboardStep> steps) {
    final int introIndex = controller.currentTabOnboard;
    final bool isPage1Loading = introIndex == 0 && controller.isIntro1AdLoading;
    final bool isPage4Loading = introIndex == 3 && controller.isIntro4AdLoading;
    final bool isLoading = isPage1Loading || isPage4Loading;

    if (isLoading) {
      return Container(
        width: 100,
        alignment: Alignment.centerRight,
        height: 40,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.primary,
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => controller.onSelectNext(context, steps),
      child: Container(
        color: Colors.transparent,
        alignment: Alignment.centerRight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(color: AppColors.textPurple,width: 1),
            borderRadius: BorderRadius.circular(32)
          ),
          padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
          child: Text(
            controller.getTitleButton(introIndex, context),
            style: AppTextStyles.textPurple14,
          ),
        ),
      ),
    );
  }

  Widget _buildBigNextButton(
      OnboardController controller, List<OnboardStep> steps) {
    final int introIndex = controller.currentTabOnboard;

    return GestureDetector(
      onTap: () => controller.onSelectNext(context, steps),
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [ Color(0xFF7A44DA),Color(0xFFCF6BEE)],
          ),
        ),
        height: 50,
        child: Center(
          child: Text(
            controller.getTitleButton(introIndex, context).toUpperCase(),
            style: AppTextStyles.textWhite16,
          ),
        ),
      ),
    );
  }
}
