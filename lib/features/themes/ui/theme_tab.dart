import 'package:flutter/material.dart';
import '../../../core/widgets/app_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../../ads/const/ad_id_extension.dart';
import '../../../ads/const/ad_id_factory.dart';
import '../../../ads/const/ad_id_name.dart';
import '../../../ads/dimens/ad_dimen.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/ads_service.dart';
import '../../../core/services/firebase_remote_config_service.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/no_data_widget.dart';
import '../../../core/widgets/theme_image.dart';
import '../domain/theme_model.dart';
import '../state/theme_provider.dart';

class ThemeTab extends ConsumerStatefulWidget {
  const ThemeTab({super.key});

  @override
  ConsumerState<ThemeTab> createState() => _ThemeTabState();
}

class _ThemeTabState extends ConsumerState<ThemeTab> {
  @override
  Widget build(BuildContext context) {
    final themesAsync = ref.watch(themesProvider);

    return AppScaffold(
      body: themesAsync.when(
        loading: () => const AppLoading(),
        error: (err, stack) => Center(
          child: Text(
            '${context.tr('error_loading_themes')}: $err',
            style: AppTextStyles.textGrey14,
          ),
        ),
        data: (themeResponse) {
          final List<ThemeCategory> rawCategories =
              themeResponse?.themeCategories ?? [];

          // Fallback if JSON fails or empty
          final List<ThemeCategory> categories = rawCategories.isNotEmpty
              ? rawCategories
              : [
                  ThemeCategory(
                    categoryID: 1,
                    categoryName: "Default Themes",
                    folder: "default",
                    items: [
                      ThemeItem(
                        id: 1,
                        titleName: "Classic Wood",
                        imageName: "theme_1",
                        resName: "theme_1",
                        folder: "default",
                      ),
                      ThemeItem(
                        id: 2,
                        titleName: "Ocean Waves",
                        imageName: "theme_2",
                        resName: "theme_2",
                        folder: "default",
                      ),
                    ],
                  ),
                ];

          if (categories.isEmpty) {
            return NoDataWidget(
              title: context.tr('no_themes_found'),
              subtitle: context.tr('no_themes_sub'),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!AppConstants.isPremiumUser.value &&
                  !AdsService.isOrganic.value &&
                  FirebaseRemoteConfigService.getBoolConfigByKey(
                    FirebaseRemoteConfigService.native_themes,
                  )) ...[
                Padding(
                  padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
                  child: EasyNativeAd(
                    factoryId: NativeFactoryId.nativeMediaSmall,
                    adId: MyAdIdName.nativeAll.getId,
                    adIdName: MyAdIdName.nativeAll,
                    height: AdDimen.smallNativeAdHeight,
                  ),
                ),
              ],
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.only(bottom: 90.h),
                  itemCount: categories.length,
                  itemBuilder: (context, catIndex) {
                    final category = categories[catIndex];
                    if (category.items.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category Title & See All Header Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              category.categoryName,
                              style: AppTextStyles.textWhite16
                                  .copyWith(fontWeight: FontWeight.w500),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  context.push('/all-themes', extra: category),
                              child: Row(
                                children: [
                                  Text(
                                    context.tr('view_all'),
                                    style: AppTextStyles.textPurple14,
                                  ),
                                  SizedBox(width: 2.w),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.textPurple,
                                    size: 18.sp,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        // Theme items under this category (show 3rd and 4th preview items as requested)
                        ...(() {
                          final previewItems = category.items.length >= 4
                              ? category.items.sublist(5, 7)
                              : (category.items.length >= 2
                                  ? category.items.sublist(0, 2)
                                  : category.items);
                          return previewItems
                              .map((theme) => _buildThemeCard(theme));
                        })(),

                        SizedBox(height: 12.h),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeCard(ThemeItem theme) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF141126), Color(0xFF0F0F1E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/theme-preview', extra: theme),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(12.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Theme Image Banner Area
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: SizedBox(
                    height: 140.h,
                    width: double.infinity,
                    child: ThemeImage(
                      resName: theme.resName,
                      fit: BoxFit.cover,
                      showOverlay: true,
                    ),
                  ),
                ),
                // SizedBox(height: 10.h),
                // // Theme Title Name
                // Text(
                //   theme.titleName,
                //   style: AppTextStyles.textWhite14.copyWith(fontSize: 14.sp, fontWeight: FontWeight.bold),
                //   textAlign: TextAlign.center,
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
