import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/shared_preference_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/no_data_widget.dart';
import '../../../core/widgets/gradient_tab_pill.dart';
import '../../../core/widgets/song_thumbnail.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../domain/lesson_model.dart';
import '../state/lesson_provider.dart';

class AllLessonsScreen extends ConsumerStatefulWidget {
  final List<LessonsCategory> categories;

  const AllLessonsScreen({super.key, this.categories = const []});

  @override
  ConsumerState<AllLessonsScreen> createState() => _AllLessonsScreenState();
}

class _AllLessonsScreenState extends ConsumerState<AllLessonsScreen> {
  int _selectedCategoryId = -1; // -1 = All song
  final Map<String, int> _songStarsMap = {};

  @override
  void initState() {
    super.initState();
    _loadSongStars();
  }

  Future<void> _loadSongStars([List<LessonsCategory>? categoriesList]) async {
    final lessonsResponse = ref.read(lessonsProvider).valueOrNull;
    final categories = (categoriesList != null && categoriesList.isNotEmpty)
        ? categoriesList
        : (widget.categories.isNotEmpty ? widget.categories : (lessonsResponse?.categories ?? []));

    Set<String> idsToLoad = {'1', '2', '3'};
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
    final displayCategories = widget.categories.isNotEmpty
        ? widget.categories
        : (lessonsAsync.asData?.value?.categories ?? []);

    if (displayCategories.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_songStarsMap.length <= 3) {
          _loadSongStars(displayCategories);
        }
      });
    }

    final filteredCategories = _selectedCategoryId == -1
        ? displayCategories
        : displayCategories.where((c) => c.categoryID == _selectedCategoryId).toList();

    return AppScaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar with Back Button & Title
          Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    width: 40.sp,
                    height: 40.sp,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
                    ),
                    child:  SvgPicture.asset(
                      'assets/icons/ic_back.svg',
                      width: 40.sp,
                      height: 40.sp,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
                Text(
                  "Songs",
                  style: AppTextStyles.textWhite22,
                ),
              ],
            ),
          ),
          // Horizontal Category Filter Pills Bar
          SizedBox(
            height: 42.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.zero,
              children: [
                // "All song" Pill
                GradientTabPill(
                  label: "All song",
                  isSelected: _selectedCategoryId == -1,
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = -1;
                    });
                  },
                ),

                // Category Pills
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

          SizedBox(height: 12.h),

          // Songs grouped by Category
          Expanded(
            child: filteredCategories.isEmpty
                ? const NoDataWidget(
                    title: "Không tìm thấy bài hát nào",
                    subtitle: "Không có bài hát nào phù hợp với danh mục hoặc từ khóa bạn chọn.",
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 40),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, catIndex) {
                      final category = filteredCategories[catIndex];
                      if (category.items.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Songs List in this Category
                          ...category.items.map((song) {
                            final songIdStr = song.id.toString();
                            final starCount = _songStarsMap[songIdStr] ?? 0;
                            final difficulty = _getDifficultyText(song.level);
                            final diffColor = _getDifficultyColor(song.level);

                            return GestureDetector(
                              onTap: () async {
                                await context.push('/lesson-play', extra: song);
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
                                    // Song Thumbnail + VIP Reward Badge
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
                                    // Song Title, Artist & Stars
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            song.titleName,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 3.h),
                                          Text(
                                            "${song.authorName} • ${song.duration}",
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12,
                                            ),
                                          ),
                                          SizedBox(height: 3.h),

                                          // Stars Rating Row
                                          Row(
                                            children: List.generate(5, (starIndex) {
                                              return Icon(
                                                starIndex < starCount
                                                    ? Icons.star_rounded
                                                    : Icons.star_outline_rounded,
                                                color: starIndex < starCount ? Colors.amber : Colors.white24,
                                                size: 14,
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
                                                const Color(0xFFCC69EE).withValues(alpha: 0.25),
                                                const Color(0xFF7745D3).withValues(alpha: 0.25),
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
                                              ),
                                              SizedBox(width: 5.w),
                                              Text(
                                                "Play",
                                                style: AppTextStyles.textPurple12,
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
                          }),
                          SizedBox(height: 10.h),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
