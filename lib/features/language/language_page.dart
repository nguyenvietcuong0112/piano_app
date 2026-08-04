import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ads/const/ad_id_extension.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/dimens/ad_dimen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
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
                child: Column(
                  children: [
                    buildNavigation(controller),
                    Expanded(child: buildContent(controller)),
                    buildNativeAd(controller),
                  ],
                ),
              ),
            ),
            if (controller.isLoading)
              Positioned.fill(
                child: Container(
                  color: const Color(0xFF131722).withOpacity(0.8),
                  child: const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget buildNativeAd(LanguageController controller) {
    if (AppConstants.isPremiumUser.value) return const SizedBox.shrink();

    final isClick = controller.isShowAltAds;
    return Container(
      height: 150,
      width: double.infinity,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 10),
      child: isClick
          ? EasyNativeAdHigh(
              factoryId: MyAdIdName.nativeLanguageClick,
              adId: MyAdIdName.nativeLanguageClick.getId,
              adIdHigh: MyAdIdName.nativeLanguageClickHigh.getId,
              height: AdDimen.largeNativeAdHeight,
            )
          : EasyNativeAdHigh(
              factoryId: MyAdIdName.nativeLanguage,
              adId: MyAdIdName.nativeLanguage.getId,
              adIdHigh: MyAdIdName.nativeLanguageHigh.getId,
              height: AdDimen.largeNativeAdHeight,
            ),
    );
  }

  Widget buildContent(LanguageController controller) {
    return ListView.builder(
      itemCount: controller.itemsList.length,
      scrollDirection: Axis.vertical,
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 10),
      itemBuilder: (context, index) {
        final isSelected = controller.selectedIndex == index;
        return GestureDetector(
          onTap: () {
            controller.onSelectItem(index);
          },
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
                        color: AppColors.textPrimary,
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

  Widget buildNavigation(LanguageController controller) {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: Stack(
        children: [
          const Positioned.fill(
            child: Center(
              child: Text(
                "Language",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
          if (!controller.isFirstLaunch)
            Positioned(
              left: 0,
              bottom: 0,
              top: 0,
              child: GestureDetector(
                onTap: () {
                  controller.onSelectBack(context);
                },
                child: const AspectRatio(
                  aspectRatio: 1,
                  child: Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                        size: 25,
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
                    onNavigateNext: () {
                      context.go('/onboard');
                    },
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
                          color: AppColors.textPrimary,
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
                  width: 25,
                  height: 25,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
