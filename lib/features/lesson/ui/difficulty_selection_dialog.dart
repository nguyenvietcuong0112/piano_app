import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/rewarded_ad_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/song_thumbnail.dart';
import '../domain/lesson_model.dart';
import '../state/lesson_provider.dart';

class DifficultySelectionDialog extends ConsumerStatefulWidget {
  final LessonsItem song;

  const DifficultySelectionDialog({super.key, required this.song});

  static Future<int?> show(BuildContext context, {required LessonsItem song}) {
    return showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (context) => DifficultySelectionDialog(song: song),
    );
  }

  @override
  ConsumerState<DifficultySelectionDialog> createState() =>
      _DifficultySelectionDialogState();
}

class _DifficultySelectionDialogState
    extends ConsumerState<DifficultySelectionDialog> {
  late int _selectedLevel;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.song.level.clamp(1, 3);
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape ||
            MediaQuery.of(context).size.height < 500;

    final unlockedLessons = ref.watch(unlockedLessonsProvider);
    final songIdStr = widget.song.id.toString();
    final isPremium = AppConstants.isPremiumUser.value;
    final isUnlocked = isPremium || unlockedLessons.contains(songIdStr);
    final showRewardBadge = !isUnlocked;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 12.w : 20.w,
        vertical: isLandscape ? 8.h : 20.h,
      ),
      child: Container(
        width: isLandscape ? 250.w : 340.w,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        padding: EdgeInsets.all(isLandscape ? 12.r : 20.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1633), Color(0xFF120F24)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Title & Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.tr('select_difficulty') != 'select_difficulty'
                        ? context.tr('select_difficulty')
                        : 'Chọn độ khó',
                    style: (isLandscape
                            ? AppTextStyles.textWhite14
                            : AppTextStyles.textWhite18)
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(null),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                      size: isLandscape ? 18 : 24,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isLandscape ? 8.h : 14.h),

              // Song Info Summary Card
              Container(
                padding: EdgeInsets.all(isLandscape ? 6.r : 10.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF221C3F),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        SongThumbnail(
                          thumbnailUrl: widget.song.thumbnail,
                          width: isLandscape ? 36 : 50,
                          height: isLandscape ? 36 : 50,
                          borderRadius: 8,
                        ),
                        if (showRewardBadge)
                          Positioned(
                            top: 3,
                            left: 3,
                            child: SvgPicture.asset(
                              'assets/icons/ic_reward.svg',
                              width: isLandscape ? 14 : 18,
                              height: isLandscape ? 14 : 18,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.song.titleName,
                            style: (isLandscape
                                    ? AppTextStyles.textWhite12
                                    : AppTextStyles.textWhite14)
                                .copyWith(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            widget.song.authorName,
                            style: AppTextStyles.textGrey12.copyWith(
                              fontSize: isLandscape ? 10 : 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isLandscape ? 10.h : 16.h),

              // Difficulty Options
              _buildOption(
                level: 1,
                title: context.tr('easy'),
                color: AppColors.levelEasy,
                icon: Icons.speed_rounded,
                isLandscape: isLandscape,
              ),
              SizedBox(height: isLandscape ? 6.h : 10.h),
              _buildOption(
                level: 2,
                title: context.tr('medium'),
                color: AppColors.levelMedium,
                icon: Icons.equalizer_rounded,
                isLandscape: isLandscape,
              ),
              SizedBox(height: isLandscape ? 6.h : 10.h),
              _buildOption(
                level: 3,
                title: context.tr('hard'),
                color: AppColors.levelHard,
                icon: Icons.local_fire_department_rounded,
                isLandscape: isLandscape,
              ),

              SizedBox(height: isLandscape ? 12.h : 20.h),

              // Continue Button
              GestureDetector(
                onTap: () {
                  final currentUnlockedLessons = ref.read(unlockedLessonsProvider);
                  final isCurrentlyUnlocked = AppConstants.isPremiumUser.value ||
                      currentUnlockedLessons.contains(songIdStr);

                  if (isCurrentlyUnlocked) {
                    Navigator.of(context).pop(_selectedLevel);
                  } else {
                    RewardedAdService.showRewardedAd(
                      context: context,
                      songId: songIdStr,
                      onRewardEarned: () async {
                        await ref
                            .read(unlockedLessonsProvider.notifier)
                            .unlockLesson(songIdStr);
                        if (context.mounted) {
                          Navigator.of(context).pop(_selectedLevel);
                        }
                      },
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  height: isLandscape ? 50.h : 44.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14.r),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFCF6BEE), Color(0xFF7A44DA)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF7A44DA).withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      context.tr('continue') != 'continue'
                          ? context.tr('continue')
                          : 'Tiếp tục',
                      style: (isLandscape
                              ? AppTextStyles.textWhite14
                              : AppTextStyles.textWhite16)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required int level,
    required String title,
    required Color color,
    required IconData icon,
    required bool isLandscape,
  }) {
    final bool isSelected = _selectedLevel == level;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedLevel = level;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(
          horizontal: isLandscape ? 10.w : 14.w,
          vertical: isLandscape ? 8.h : 12.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.18)
              : const Color(0xFF1E1935),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isLandscape ? 6.r : 8.r),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: isLandscape ? 16 : 20,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.textWhite14.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isSelected ? color : Colors.white,
                  fontSize: isLandscape ? 12 : 14,
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? color : Colors.white38,
              size: isLandscape ? 18 : 22,
            ),
          ],
        ),
      ),
    );
  }
}
