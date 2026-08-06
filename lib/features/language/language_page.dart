import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../ads/const/ad_id_extension.dart';
import '../../ads/const/ad_id_factory.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/dimens/ad_dimen.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
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

  Widget _buildNativeAd(LanguageController controller) {
    if (AppConstants.isPremiumUser.value ||
        !controller.isFirstLaunch ||
        !controller.isShouldShowAds) {
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
    final bool hideAd = AppConstants.isPremiumUser.value || !controller.isFirstLaunch;
    return ListView.builder(
      itemCount: controller.itemsList.length,
      scrollDirection: Axis.vertical,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 10,
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
              borderRadius: BorderRadius.circular(8),
              color: isSelected ? AppColors.primary : AppColors.surface,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      controller.itemsList[index].pngAsset,
                      width: 40,
                      height: 30,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.flag, color: Colors.white),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      controller.itemsList[index].title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textWhite,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                isSelected
                    ? Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 1, color: Colors.white),
                        ),
                        child: Center(
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
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
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textWhite,
                ),
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
