import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

import '../../ads/const/ad_id_extension.dart';
import '../../ads/const/ad_id_factory.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/dimens/ad_dimen.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/firebase_remote_config_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'language_controller.dart';

class LanguagePage extends ConsumerStatefulWidget {
  final bool isFirstLaunch;

  const LanguagePage({super.key, this.isFirstLaunch = false});

  @override
  ConsumerState<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends ConsumerState<LanguagePage> {
  @override
  void initState() {
    super.initState();
    if (widget.isFirstLaunch) {
      EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(true);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(languageControllerProvider)
          .init(firstLaunch: widget.isFirstLaunch);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(languageControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    _buildNavigation(controller),
                    Expanded(child: _buildContent(controller)),
                    _buildNativeAd(controller),
                  ],
                ),
              ),
            ),
            if (controller.isLoading)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF131722).withValues(alpha: 0.8),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowLanguageAd(LanguageController controller) {
    if (AppConstants.isPremiumUser.value ||
        !controller.isFirstLaunch ||
        !controller.isShouldShowAds) {
      return false;
    }
    final isClick = controller.isShowClickAds;
    if (isClick) {
      return FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.native_language_click,
      );
    } else {
      return FirebaseRemoteConfigService.getBoolConfigByKey(
        FirebaseRemoteConfigService.native_language,
      );
    }
  }

  Widget _buildNativeAd(LanguageController controller) {
    if (!_shouldShowLanguageAd(controller)) {
      return const SizedBox.shrink();
    }

    final isClick = controller.isShowClickAds;
    return isClick
        ? EasyNativeAdHigh(
            key: const ValueKey('nativeLanguageClick'),
            factoryId: NativeFactoryId.nativeMedia2,
            adId: MyAdIdName.nativeLanguageClick.getId,
            adIdHigh: MyAdIdName.nativeLanguageClickHigh.getId,
            adIdName: MyAdIdName.nativeLanguageClick,
            adIdNameHigh: MyAdIdName.nativeLanguageClickHigh,
            height: AdDimen.mediumNativeHeight,
          )
        : EasyNativeAdHigh(
            key: const ValueKey('nativeLanguage'),
            factoryId: NativeFactoryId.nativeMedia,
            adId: MyAdIdName.nativeLanguage.getId,
            adIdHigh: MyAdIdName.nativeLanguageHigh.getId,
            adIdName: MyAdIdName.nativeLanguage,
            adIdNameHigh: MyAdIdName.nativeLanguageHigh,
            height: AdDimen.mediumNativeHeight,
          );
  }

  Widget _buildContent(LanguageController controller) {
    final bool hideAd = !_shouldShowLanguageAd(controller);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 20, right: 20, top: 4, bottom: 12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              context.tr('select_language_subtitle'),
              style: AppTextStyles.textGrey14,
              textAlign: TextAlign.left,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: controller.itemsList.length,
            scrollDirection: Axis.vertical,
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 0,
              bottom: hideAd ? 20 : AdDimen.mediumNativeHeight + 10,
            ),
            itemBuilder: (context, index) {
              final isSelected = controller.selectedIndex == index;
              return GestureDetector(
                onTap: () => controller.onSelectItem(index),
                child: Container(
                  height: 44,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF141126), Color(0xFF0F0F1E)],
                    ),
                    border: GradientBoxBorder(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFFFF).withOpacity(0.5), // opacity 0.5
                          Color(0xFFFFFF), // opacity 0.5
                          Color(0xAD57E6).withOpacity(0.5),
                        ],
                      ),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              controller.itemsList[index].pngAsset,
                              width: 38,
                              height: 26,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.flag, color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Text(
                            controller.itemsList[index].title,
                            style: AppTextStyles.textWhite14.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      isSelected
                          ? Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(width: 1, color: AppColors.textPurple),
                              ),
                              child: Center(
                                child: Container(
                                  width: 15,
                                  height: 15,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.textPurple,
                                  ),
                                ),
                              ),
                            )
                          : Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(width: 1, color: Colors.grey),
                              ),
                            ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNavigation(LanguageController controller) {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Text(
                context.tr('language'),
                style: AppTextStyles.textWhite20,
              ),
            ),
          ),
          if (!controller.isFirstLaunch)
            Positioned(
              left: 16,
              bottom: 0,
              top: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () => controller.onSelectBack(context),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/ic_back.svg',
                        width: 40,
                        height: 40,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.arrow_back,
                          color: AppColors.textWhite,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (controller.selectedIndex != 100 && controller.isShouldShowNext)
            Positioned(
              right: 20,
              bottom: 0,
              top: 0,
              child: GestureDetector(
                onTap: () {
                  controller.onClickNext(
                    context,
                    ref: ref,
                    onNavigateNext: () => context.go('/onboard'),
                  );
                },
                child: const Row(
                  children: [
                    SizedBox(
                      width: 80,
                      height: 36,
                      child: Center(
                        child: Icon(
                          Icons.done,
                          color: AppColors.textWhite,
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (controller.selectedIndex != 100 && !controller.isShouldShowNext)
            const Positioned(
              right: 20,
              bottom: 0,
              top: 0,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
