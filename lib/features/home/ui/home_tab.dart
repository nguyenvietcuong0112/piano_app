import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/app_loading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/shared_preference_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/gradient_border_card.dart';
import '../../../core/widgets/song_thumbnail.dart';
import '../../lesson/domain/lesson_model.dart';
import '../../lesson/state/lesson_provider.dart';

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

  String _getDifficultyText(int level) {
    switch (level) {
      case 1:
        return "Easy";
      case 2:
        return "Medium";
      case 3:
        return "Hard";
      default:
        return "Easy";
    }
  }

  Color _getDifficultyColor(int level) {
    switch (level) {
      case 1:
        return AppColors.levelEasy;
      case 2:
        return AppColors.levelMedium;
      case 3:
        return AppColors.levelHard;
      default:
        return AppColors.levelEasy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonsAsync = ref.watch(lessonsProvider);

    return AppScaffold(
      body: lessonsAsync.when(
          loading: () => const AppLoading(),
          error: (err, stack) => Center(
            child: Text(
              "Error: $err",
              style: const TextStyle(color: Colors.white70),
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
            List<LessonsCategory> categories = lessonsResponse?.categories ?? [];
            List<LessonsItem> popularSongs = [];
            for (var c in categories) {
              popularSongs.addAll(c.items);
            }
            if (popularSongs.isEmpty) {
              popularSongs = [
                LessonsItem(
                  id: 1,
                  titleName: "A Thousand Years",
                  authorName: "Christina Perri",
                  duration: "03:45",
                  lessonsData: "a_thousand_years.json",
                  thumbnail: "",
                  level: 1, // 1 = Easy
                  startOctave: 4,
                  startKeyPosition: 0,
                  visibleWhiteKeysCount: 14,
                ),
                LessonsItem(
                  id: 2,
                  titleName: "A Thousand Years",
                  authorName: "Christina Perri",
                  duration: "03:45",
                  lessonsData: "a_thousand_years.json",
                  thumbnail: "",
                  level: 3, // 3 = Hard
                  startOctave: 4,
                  startKeyPosition: 0,
                  visibleWhiteKeysCount: 14,
                ),
                LessonsItem(
                  id: 3,
                  titleName: "A Thousand Years",
                  authorName: "Christina Perri",
                  duration: "03:45",
                  lessonsData: "a_thousand_years.json",
                  thumbnail: "",
                  level: 2, // 2 = Medium
                  startOctave: 4,
                  startKeyPosition: 0,
                  visibleWhiteKeysCount: 14,
                ),
              ];
            }
            return SingleChildScrollView(
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
                                  "Learn Piano anywhere,\nanytime. Real keys, real feel.",
                                  style: AppTextStyles.textWhite12,
                                ),
                                SizedBox(height: 12.h),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.r),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFB158F0), Color(0xFF7E26D4)],
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18.sp),
                                      SizedBox(width: 4.w),
                                      Text(
                                        "Play Now",
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
                      const Text(
                        "Popular Songs",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/all-lessons'),
                        child:  Row(
                          children: [
                            Text(
                              "See All",
                              style: AppTextStyles.textPurple14,
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.chevron_right_rounded, color: AppColors.textPurple, size: 18),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: popularSongs.length > 10 ? 10 : popularSongs.length,
                    itemBuilder: (context, index) {
                      final song = popularSongs[index];
                      final songIdStr = song.id.toString();
                      final starCount = _songStarsMap[songIdStr] ?? 0;
                      final difficulty = _getDifficultyText(song.level);
                      final diffColor = _getDifficultyColor(song.level);

                      return GestureDetector(
                        onTap: () async {
                          await context.push('/lesson-play', extra: song);
                          await SystemChrome.setPreferredOrientations([
                            DeviceOrientation.portraitUp,
                          ]);
                          _loadSongStars();
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

                              // Difficulty Tag & Play Button
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: diffColor.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: diffColor.withValues(alpha: 0.2), width: 1),
                                    ),
                                    child: Text(
                                      difficulty,
                                      style: TextStyle(
                                        color: diffColor,
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
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
                                          color: AppColors.textPurple,
                                        ),
                                        SizedBox(width: 5.w),
                                        Text(
                                          "Play",
                                          style: AppTextStyles.textPurple12.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
    );
  }
}
