import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/shared_preference_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/gradient_tab_pill.dart';
import '../../../core/widgets/no_data_widget.dart';
import '../../../core/widgets/song_thumbnail.dart';
import '../domain/lesson_model.dart';
import '../state/lesson_provider.dart';
import 'difficulty_selection_dialog.dart';

class SongsLandscapeScreen extends ConsumerStatefulWidget {
  const SongsLandscapeScreen({super.key});

  @override
  ConsumerState<SongsLandscapeScreen> createState() =>
      _SongsLandscapeScreenState();
}

class _SongsLandscapeScreenState extends ConsumerState<SongsLandscapeScreen> {
  int _selectedCategoryId = -1; // -1 = All song
  final Map<String, int> _songStarsMap = {};

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _loadSongStars();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadSongStars([List<LessonsCategory>? categoriesList]) async {
    final lessonsResponse = ref.read(lessonsProvider).valueOrNull;
    final categories = (categoriesList != null && categoriesList.isNotEmpty)
        ? categoriesList
        : (lessonsResponse?.categories ?? []);

    Set<String> idsToLoad = {'1', '2', '3', '101'};
    for (var c in categories) {
      for (var item in c.items) {
        idsToLoad.add(item.id.toString());
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
    final displayCategories = lessonsAsync.asData?.value?.categories ?? [];

    if (displayCategories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_songStarsMap.length <= 4) {
          _loadSongStars(displayCategories);
        }
      });
    }

    // Filter items based on selected category
    final List<LessonsItem> allSongs = [];
    if (_selectedCategoryId == -1) {
      for (var cat in displayCategories) {
        allSongs.addAll(cat.items);
      }
    } else {
      final selectedCat = displayCategories.firstWhere(
        (c) => c.categoryID == _selectedCategoryId,
        orElse: () => LessonsCategory(
          categoryID: -1,
          categoryName: '',
          items: [],
        ),
      );
      allSongs.addAll(selectedCat.items);
    }

    return AppScaffold(
      backgroundColor: AppColors.scaffoldBackground,
      horizontalPadding: 16,
      verticalPadding: 8,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar: Back Button + Centered Title "Songs"
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: SvgPicture.asset(
                      'assets/icons/ic_back.svg',
                      width: 36,
                      height: 36,
                    ),
                  ),
                ),
                Text(
                  context.tr('all_lessons'),
                  style: AppTextStyles.textWhite20.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 6),

          // Horizontal Category Filter Pills Bar
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              children: [
                // "All song" Pill
                GradientTabPill(
                  label: context.tr('all'),
                  isSelected: _selectedCategoryId == -1,
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = -1;
                    });
                  },
                ),

                // Dynamic Category Pills
                ...displayCategories.map((cat) {
                  return GradientTabPill(
                    label: cat.categoryName,
                    isSelected: _selectedCategoryId == cat.categoryID,
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = cat.categoryID;
                      });
                    },
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Songs 3-Column Grid in Landscape
          Expanded(
            child: allSongs.isEmpty
                ? NoDataWidget(
                    title: context.tr('no_songs_found'),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.only(bottom: 12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: allSongs.length,
                    itemBuilder: (context, index) {
                      final song = allSongs[index];
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
                              DeviceOrientation.landscapeLeft,
                              DeviceOrientation.landscapeRight,
                            ]);
                            _loadSongStars();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 8),
                          decoration: BoxDecoration( 
                            borderRadius: BorderRadius.circular(14.r),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF161328), Color(0xFF110F20)],
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
                              // Song Thumbnail + Reward/VIP Badge
                              Stack(
                                children: [
                                  SongThumbnail(
                                    thumbnailUrl: song.fullThumbnailUrl,
                                    width: 50,
                                    height: 50,
                                    borderRadius: 8,
                                  ),
                                  if (showRewardBadge)
                                    Positioned(
                                      top: 2,
                                      left: 2,
                                      child: SvgPicture.asset(
                                        'assets/icons/ic_reward.svg',
                                        width: 16.r,
                                        height: 16.r,
                                        errorBuilder: (context, error, stack) =>
                                            const SizedBox.shrink(),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 8),

                              // Song Title, Artist & Stars
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                     Text(
                                       song.titleName,
                                       style: AppTextStyles.textWhite12.copyWith(
                                         fontWeight: FontWeight.bold,
                                       ),
                                       maxLines: 1,
                                       overflow: TextOverflow.ellipsis,
                                     ),
                                     const SizedBox(height: 2),
                                     Text(
                                       song.authorName,
                                       style: AppTextStyles.textGrey12.copyWith(
                                         fontSize: 10,
                                       ),
                                       maxLines: 1,
                                       overflow: TextOverflow.ellipsis,
                                     ),
                                    const SizedBox(height: 3),

                                    // 5 Stars Rating Row
                                    Row(
                                      children: List.generate(5, (starIndex) {
                                        final isEarned = starIndex < starCount;
                                        return Icon(
                                          isEarned
                                              ? Icons.star_rounded
                                              : Icons.star_outline_rounded,
                                          color: isEarned
                                              ? const Color(0xFFFFC107)
                                              : Colors.white24,
                                          size: 11.r,
                                        );
                                      }),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),

                              // Right Section (Play Button)
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFAD56E6),
                                        Color(0xFF7B38D8),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(12.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFAD56E6)
                                            .withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/ic_play.svg',
                                        width: 10.r,
                                        height: 10.r,
                                        colorFilter: const ColorFilter.mode(
                                            Colors.white, BlendMode.srcIn),
                                        errorBuilder:
                                            (context, error, stack) =>
                                                const Icon(
                                          Icons.play_arrow_rounded,
                                          color: Colors.white,
                                          size: 10,
                                        ),
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        context.tr('practice_now'),
                                        style: AppTextStyles.textWhite12.copyWith(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
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
      ), 
    );
  }
}
