import 'package:dots_indicator/dots_indicator.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ads/dimens/ad_dimen.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardControllerProvider).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(onboardControllerProvider);
    final steps = controller.getSteps();

    return Scaffold(
      backgroundColor: AppColors.background,
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

    return Stack(
      children: [
        // Top Header Image
        Positioned.fill(
          child: Column(
            children: [
              Expanded(
                child: Image.asset(
                  step.image,
                  fit: step.fit,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: AppColors.surface,
                    child: const Center(
                      child: Icon(Icons.music_note, size: 80, color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              SizedBox(height: hasAd ? 340 : 180),
            ],
          ),
        ),

        // Bottom Section (Text + Indicators + Next Button + Native Ad)
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title & Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 20,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  step.desc,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 20),

              // Bottom Layout Conditional on Ad
              if (hasAd) ...[
                // Pages 1 & 4 (With Ads)
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 100),
                      _buildDotsIndicator(controller),
                      _buildTextNextButton(controller, steps),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                EasyNativeAd(
                  key: ValueKey(step.adId),
                  factoryId: step.factoryId,
                  adId: step.adId,
                  height: AdDimen.mediumNativeHeight,
                ),
              ] else ...[
                // Pages 2 & 3 (Without Ads)
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
        color: Colors.grey,
        activeColor: AppColors.primary,
        size: const Size(12, 8),
        activeSize: const Size(22, 8),
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
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => controller.onSelectNext(context, steps),
      child: Container(
        width: 100,
        color: Colors.transparent,
        alignment: Alignment.centerRight,
        height: 40,
        child: Text(
          controller.getTitleButton(introIndex),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
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
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          color: AppColors.primary,
        ),
        height: 50,
        child: Center(
          child: Text(
            controller.getTitleButton(introIndex).toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
