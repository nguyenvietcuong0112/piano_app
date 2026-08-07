import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import '../../../core/widgets/app_loading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/shared_preference_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/gradient_border_card.dart';
import '../../../core/widgets/song_thumbnail.dart';
import '../../lesson/domain/lesson_model.dart';
import '../../lesson/state/lesson_provider.dart';
import '../../lesson/ui/difficulty_selection_dialog.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  final Map<String, int> _songStarsMap = {};

  @override
  void initState() {
    super.initState();
    _markAppOpened();
    _loadSongStars();
  }

  Future<void> _markAppOpened() async {
    await SharedPreferenceUtils.setIsNoFirstOpenApp(true);
  }

  Future<void> _loadSongStars([LessonsResponse? lessonsResponse]) async {
    final response = lessonsResponse ?? ref.read(lessonsProvider).valueOrNull;
    Set<String> idsToLoad = {'1', '2', '3'};
    if (response != null) {
      for (var c in response.categories) {
        for (var item in c.items) {
          idsToLoad.add(item.id.toString());
        }
      }
    }
    for (var id in idsToLoad) {
      final stars = await SharedPreferenceService.getLessonStars(id);
      if (mounted) {
        setState(() {
          _songStarsMap[id] = stars;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    final lessonsAsync = ref.watch(lessonsProvider);
    final unlockedLessons = ref.watch(unlockedLessonsProvider);

    return AppScaffold(
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 12.h, bottom: 90.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GradientBorderCard(
              height: 150.h,
              borderRadius: 20,
              bgImageAsset: 'assets/images/img_acoustic_piano.png',
              imageFit: BoxFit.fill,
              onTap: () => context.push('/play'),
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
              child: Row(
                children: [
                  Expanded(
                    flex: 6,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: "ACOUSTIC ", style: AppTextStyles.textWhite20),
                                TextSpan(text: "PIANO", style: AppTextStyles.textPurple20),
                              ],
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            context.tr('home_banner_sub'),
                            style: AppTextStyles.textWhite12,
                          ),
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.r),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7A44DA), Color(0xFFCF6BEE)],
                              ),
                              border: GradientBoxBorder(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFFFFFFF).withValues(alpha: 0.5),
                                    const Color(0xFFFFFFFF),
                                    const Color(0xFFAD57E6).withValues(alpha: 0.5),
                                  ],
                                ),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18.sp),
                                SizedBox(width: 4.w),
                                Text(
                                  context.tr('start_now'),
                                  style: AppTextStyles.textWhite12.copyWith(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.tr('lesson_list'),
                  style: AppTextStyles.textWhite18,
                ),
                GestureDetector(
                  onTap: () => context.push('/all-lessons'),
                  child: Row(
                    children: [
                      Text(
                        context.tr('view_all'),
                        style: AppTextStyles.textPurple14,
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.textPurple, size: 18),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            lessonsAsync.when(
              loading: () => SizedBox(
                height: 200.h,
                child: const Center(
                  child: AppLoading(),
                ),
              ),
              error: (err, stack) => Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Center(
                  child: Text(
                    "Error: $err",
                    style: AppTextStyles.textGrey14,
                  ),
                ),
              ),
              data: (lessonsResponse) {
                if (lessonsResponse != null && lessonsResponse.categories.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_songStarsMap.length <= 3) {
                      _loadSongStars(lessonsResponse);
                    }
                  });
                }
                final popularCategory = (lessonsResponse != null && lessonsResponse.categories.isNotEmpty)
                    ? lessonsResponse.categories.firstWhere(
                        (c) => c.categoryID == 1,
                        orElse: () => lessonsResponse.categories.first,
                      )
                    : null;
                final popularSongs = popularCategory?.items ?? [];

                if (popularSongs.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Center(
                      child: Text(
                        "No songs available",
                        style: AppTextStyles.textGrey14,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: popularSongs.length > 10 ? 10 : popularSongs.length,
                  itemBuilder: (context, index) {
                    final song = popularSongs[index];
                    final songIdStr = song.id.toString();
                    final starCount = _songStarsMap[songIdStr] ?? 0;
                    final showRewardBadge = !AppConstants.isPremiumUser.value &&
                        !unlockedLessons.contains(songIdStr);

                    return GestureDetector(
                      onTap: () async {
                        final selectedLevel = await DifficultySelectionDialog.show(
                          context,
                          song: song,
                        );
                        if (selectedLevel != null && context.mounted) {
                          final updatedSong = song.copyWith(level: selectedLevel);
                          await context.push('/lesson-play', extra: updatedSong);
                          await SystemChrome.setPreferredOrientations([
                            DeviceOrientation.portraitUp,
                          ]);
                          _loadSongStars();
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
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
                        child: Row(
                          children: [
                            // Song Thumbnail + VIP Crown Badge
                            Stack(
                              children: [
                                SongThumbnail(
                                  thumbnailUrl: song.thumbnail,
                                  width: 100.sp,
                                  height: 80.sp,
                                  borderRadius: 12,
                                ),
                                if (showRewardBadge)
                                  Positioned(
                                    top: 6.sp,
                                    left: 6.sp,
                                    child: SvgPicture.asset(
                                      'assets/icons/ic_reward.svg',
                                      width: 24.sp,
                                      height: 24.sp,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(width: 10.w),
                            // Song Title, Author & 5-Star Rating
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    song.titleName,
                                    style: AppTextStyles.textWhite14,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    song.authorName,
                                    style: AppTextStyles.textGrey12,
                                  ),
                                  SizedBox(height: 4.h),
                                  // Star Rating Row
                                  Row(
                                    children: List.generate(5, (starIndex) {
                                      bool isStarFilled = starIndex < starCount;
                                      return Padding(
                                        padding: const EdgeInsets.only(right: 2),
                                        child: Icon(
                                          Icons.star_rounded,
                                          size: 14.sp,
                                          color: isStarFilled ? AppColors.levelMedium : AppColors.keyWhiteBorder,
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            ),

                            // Play Button Pill
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD065F2),
                                borderRadius: BorderRadius.circular(16.r),
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF7745D3).withValues(alpha: 0.25),
                                    const Color(0xFFCC69EE).withValues(alpha: 0.25),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/ic_play.svg',
                                    width: 12.sp,
                                    height: 12.sp,
                                    colorFilter: const ColorFilter.mode(
                                      AppColors.textPurple,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  SizedBox(width: 5.w),
                                  Text(
                                    context.tr('practice_now'),
                                    style: AppTextStyles.textPurple12.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
