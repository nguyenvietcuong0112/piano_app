import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/shared_preference_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
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

  Future<void> _loadSongStars() async {
    final lessonsResponse = ref.read(lessonsProvider).valueOrNull;
    List<int> idsToLoad = [1, 2, 3];
    if (lessonsResponse != null) {
      for (var c in lessonsResponse.categories) {
        for (var item in c.items) {
          idsToLoad.add(item.id);
        }
      }
    }
    for (var id in idsToLoad) {
      final stars = await SharedPreferenceService.getLessonStars(id.toString());
      if (mounted) {
        setState(() {
          _songStarsMap[id.toString()] = stars;
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

    // Filter categories based on selection
    final filteredCategories = _selectedCategoryId == -1
        ? displayCategories
        : displayCategories.where((c) => c.categoryID == _selectedCategoryId).toList();

    return AppScaffold(
      horizontalPadding: 0,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1E),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Songs",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 18),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),

          // Horizontal Category Filter Pills Bar
          SizedBox(
            height: 42.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: [
                // "All song" Pill
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = -1;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedCategoryId == -1 ? const Color(0xFF8B44CF) : const Color(0xFF1E1E2C),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _selectedCategoryId == -1 ? const Color(0xFFAD57E6) : Colors.white12,
                      ),
                    ),
                    child: Text(
                      "All song",
                      style: TextStyle(
                        color: _selectedCategoryId == -1 ? Colors.white : Colors.white70,
                        fontSize: 13,
                        fontWeight: _selectedCategoryId == -1 ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                // Category Pills
                ...displayCategories.map((cat) {
                  final isSelected = _selectedCategoryId == cat.categoryID;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryId = cat.categoryID;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF8B44CF) : const Color(0xFF1E1E2C),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? const Color(0xFFAD57E6) : Colors.white12,
                        ),
                      ),
                      child: Text(
                        cat.categoryName,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Songs grouped by Category
          Expanded(
            child: filteredCategories.isEmpty
                ? const Center(
                    child: Text(
                      "Không tìm thấy bài hát nào trong danh mục này",
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 40),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, catIndex) {
                      final category = filteredCategories[catIndex];
                      if (category.items.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Section Header
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                const Icon(Icons.folder_open_rounded, color: Color(0xFFAD57E6), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  category.categoryName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2A233D),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    "${category.items.length} bài hát",
                                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Songs List in this Category
                          ...category.items.map((song) {
                            final songIdStr = song.id.toString();
                            final starCount = _songStarsMap[songIdStr] ?? 0;
                            final difficulty = _getDifficultyText(song.level);
                            final diffColor = _getDifficultyColor(song.level);

                            return Container(
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
                                  // Song Thumbnail
                                  SongThumbnail(
                                    thumbnailUrl: song.thumbnail,
                                    width: 48,
                                    height: 48,
                                    borderRadius: 12,
                                  ),
                                  const SizedBox(width: 12),

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
                                        const SizedBox(height: 2),
                                        Text(
                                          "${song.authorName} • ${song.duration}",
                                          style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(height: 4),

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
                                          border: Border.all(color: diffColor.withValues(alpha: 0.6), width: 1),
                                        ),
                                        child: Text(
                                          difficulty,
                                          style: TextStyle(
                                            color: diffColor,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () async {
                                          await context.push('/lesson-play', extra: song);
                                          _loadSongStars();
                                        },
                                        child: Container(
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
                                                colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                              ),
                                              SizedBox(width: 5.w),
                                              Text(
                                                "Play",
                                                style: AppTextStyles.textWhite12.copyWith(fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 10),
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
