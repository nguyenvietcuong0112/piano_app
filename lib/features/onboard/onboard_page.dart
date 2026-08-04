import 'package:dots_indicator/dots_indicator.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ads/const/ad_id_extension.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/dimens/ad_dimen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
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
        child: Stack(
          children: [
            Positioned.fill(
              child: PageView.builder(
                controller: controller.pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: steps.length,
                onPageChanged: (index) {
                  controller.onChangePage(index);
                },
                itemBuilder: (context, index) {
                  return _buildIntroPage(controller, steps[index], index, steps);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroPage(OnboardController controller, OnboardStep step, int index, List<OnboardStep> steps) {
    return Stack(
      children: [
        Positioned.fill(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: 220),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  step.title,
                  style: const TextStyle(
                      fontSize: 20,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600),
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
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ),
              const SizedBox(height: 15),
              _buildNativeAdForStep(index),
              const SizedBox(height: 10),
              Container(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 20,
                  child: DotsIndicator(
                    dotsCount: controller.totalPage,
                    position: controller.currentTabOnboard,
                    decorator: DotsDecorator(
                        color: Colors.grey,
                        activeColor: AppColors.primary,
                        size: const Size(12, 8),
                        activeSize: const Size(22, 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        activeShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        spacing: const EdgeInsets.only(right: 8)),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              _buildBigButtonNext(controller, steps),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNativeAdForStep(int index) {
    if (AppConstants.isPremiumUser.value) return const SizedBox.shrink();

    if (index == 0) {
      return Container(
        height: 140,
        width: double.infinity,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: EasyNativeAd(
          factoryId: MyAdIdName.nativeOnboard1Ad,
          adId: MyAdIdName.nativeOnboard1Ad.getId,
          height: AdDimen.largeNativeAdHeight,
        ),
      );
    } else if (index == 3) {
      return Container(
        height: 140,
        width: double.infinity,
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: EasyNativeAd(
          factoryId: MyAdIdName.nativeOnboard3Ad,
          adId: MyAdIdName.nativeOnboard3Ad.getId,
          height: AdDimen.largeNativeAdHeight,

        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildBigButtonNext(OnboardController controller, List<OnboardStep> steps) {
    final int introIndex = controller.currentTabOnboard;
    return GestureDetector(
      onTap: () {
        controller.onSelectNext(context, steps);
      },
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
                color: Colors.white),
          ),
        ),
      ),
    );
  }
}
