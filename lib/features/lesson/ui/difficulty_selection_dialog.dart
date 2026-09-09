import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/rewarded_ad_service.dart';
import '../../../core/services/shared_preference_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/song_thumbnail.dart';
import '../domain/lesson_model.dart';
import '../state/lesson_provider.dart';

class DifficultySelectionDialog extends ConsumerStatefulWidget {
  final LessonsItem song;
  final bool isFreeOverride;

  const DifficultySelectionDialog({
    super.key,
    required this.song,
    this.isFreeOverride = false,
  });

  static Future<int?> show(
    BuildContext context, {
    required LessonsItem song,
    bool isFreeOverride = false,
  }) {
    return showDialog<int>(
      context: context,
      barrierDismissible: true,
      builder: (context) => DifficultySelectionDialog(
        song: song,
        isFreeOverride: isFreeOverride,
      ),
    );
  }

  @override
  ConsumerState<DifficultySelectionDialog> createState() =>
      _DifficultySelectionDialogState();
}

class _DifficultySelectionDialogState
    extends ConsumerState<DifficultySelectionDialog> {
  late int _selectedLevel;
  bool _isDownloading = false;
  bool _isDownloaded = false;

  bool _isFlashSaleActive = false;
  Duration _flashSaleRemaining = Duration.zero;
  Timer? _flashSaleTimer;

  @override
  void initState() {
    super.initState();
    _selectedLevel = widget.song.level.clamp(1, 3);
    // Consider song downloaded if lessonsData is present
    _isDownloaded = widget.song.lessonsData.isNotEmpty;

    // Initialize Flash Sale countdown state
    _flashSaleRemaining = SharedPreferenceService.getFlashSaleRemainingDurationSync();
    _isFlashSaleActive = _flashSaleRemaining > Duration.zero;
    if (_isFlashSaleActive) {
      _startFlashSaleTimer();
    }
    _initFlashSale();
  }

  Future<void> _initFlashSale() async {
    final remaining = await SharedPreferenceService.getFlashSaleRemainingDuration();
    if (!mounted) return;
    if (remaining > Duration.zero) {
      setState(() {
        _isFlashSaleActive = true;
        _flashSaleRemaining = remaining;
      });
      _startFlashSaleTimer();
    } else {
      setState(() {
        _isFlashSaleActive = false;
        _flashSaleRemaining = Duration.zero;
      });
    }
  }

  void _startFlashSaleTimer() {
    _flashSaleTimer?.cancel();
    _flashSaleTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_flashSaleRemaining.inSeconds > 1) {
        setState(() {
          _flashSaleRemaining -= const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
        setState(() {
          _flashSaleRemaining = Duration.zero;
          _isFlashSaleActive = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _flashSaleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape ||
            MediaQuery.of(context).size.height < 500;

    final unlockedLessons = ref.watch(unlockedLessonsProvider);
    final songIdStr = widget.song.id.toString();
    final isPremium = AppConstants.isPremiumUser.value;
    final isUnlocked = isPremium || unlockedLessons.contains(songIdStr) || widget.isFreeOverride;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isLandscape ? 12.w : 20.w,
        vertical: isLandscape ? 8.h : 20.h,
      ),
      child: Container(
        width: isLandscape ? 160.w : 340.w,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        padding: EdgeInsets.all(isLandscape ? 12.r : 20.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: const LinearGradient(
            colors: [Color(0xFF1F1A3A), Color(0xFF131026)],
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Bar: Close Button X
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(null),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: Colors.white70,
                      size: isLandscape ? 16 : 20,
                    ),
                  ),
                ),
              ),

              // State 1: Locked -> Unlock This Song
              if (!isUnlocked)
                _buildLockedState(isLandscape, songIdStr)
              // State 2: Unlocked & Not Downloaded -> Download
              else if (!_isDownloaded)
                _buildDownloadState(isLandscape)
              // State 3: Unlocked & Downloaded -> Ready to Play (with 3 Mode Chips above Play Now)
              else
                _buildReadyToPlayState(isLandscape, songIdStr),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STATE 1: Locked (Unlock This Song)
  // ---------------------------------------------------------------------------
  Widget _buildLockedState(bool isLandscape, String songIdStr) {
    final thumbSize = isLandscape ? 56.0 : 90.0;

    return Column(
      children: [
        // Song Thumbnail with Crown Badge
        Stack(
          children: [
        SongThumbnail(
          thumbnailUrl: widget.song.fullThumbnailUrl,
          width: thumbSize,
          height: thumbSize,
          borderRadius: 14,
        ),
            Positioned(
              top: 4,
              left: 4,
              child: SvgPicture.asset(
                'assets/icons/ic_reward.svg',
                width: isLandscape ? 16 : 22,
                height: isLandscape ? 16 : 22,
              ),
            ),
          ],
        ),
        SizedBox(height: isLandscape ? 10.h : 14.h),

        // Title: Unlock This Song (with 'Song' in purple)
        Builder(
          builder: (context) {
            final title = context.tr('unlock_this_song');
            final baseStyle = (isLandscape
                    ? AppTextStyles.textWhite16
                    : AppTextStyles.textWhite20)
                .copyWith(fontWeight: FontWeight.bold);

            if (title.contains('Song')) {
              final parts = title.split('Song');
              return RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: baseStyle,
                  children: [
                    TextSpan(text: parts[0]),
                    TextSpan(
                      text: 'Song',
                      style: baseStyle.copyWith(color: const Color(0xFFCF6BEE)),
                    ),
                    if (parts.length > 1) TextSpan(text: parts[1]),
                  ],
                ),
              );
            }
            return Text(
              title,
              textAlign: TextAlign.center,
              style: baseStyle,
            );
          },
        ),
        SizedBox(height: isLandscape ? 4.h : 6.h),

        // Subtitle
        Text(
          context.tr('unlock_song_sub'),
          textAlign: TextAlign.center,
          style: AppTextStyles.textGrey12.copyWith(
            fontSize: isLandscape ? 10 : 12,
          ),
        ),

        // Flash Sale Banner (if active)
        if (_isFlashSaleActive) ...[
          SizedBox(height: isLandscape ? 8.h : 5.h),
          _buildFlashSaleBanner(isLandscape),
        ],

        SizedBox(height: isLandscape ? 10.h : 14.h),

        // Button 1: Get Premium (with ic_get_premium.svg)
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop(null);
            context.push('/premium');
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 10.w : 14.w,
              vertical: isLandscape ? 8.h : 10.h,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: const LinearGradient(
                colors: [Color(0xFF7A44DA),Color(0xFFCF6BEE)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              border:  GradientBoxBorder(
                width: 1,
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFCE64F0).withValues(alpha: 0.5),
                    Color(0xFF999999).withValues(alpha: 0.5),
                    Color(0xFFFFFFFF).withValues(alpha: 0.5),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/ic_get_premium.svg',
                  width: isLandscape ? 16 : 32,
                  height: isLandscape ? 16 : 32,
                  errorBuilder: (context, error, stack) => const Icon(
                    Icons.star_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('get_premium'),
                        style: AppTextStyles.textWhite14.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isLandscape ? 12 : 14,
                        ),
                      ),
                      Text(
                        context.tr('get_premium_sub'),
                        style: AppTextStyles.textWhite12.copyWith(
                          fontSize: isLandscape ? 9 : 11,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white,
                  size: isLandscape ? 18 : 22,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: isLandscape ? 8.h : 10.h),

        // Button 2: Continue with Ad
        GestureDetector(
          onTap: () {
            RewardedAdService.showRewardedAd(
              context: context,
              songId: songIdStr,
              onRewardEarned: () async {
                await ref
                    .read(unlockedLessonsProvider.notifier)
                    .unlockLesson(songIdStr);
                if (mounted) {
                  setState(() {
                    // Triggers rebuild into state 2 or 3
                  });
                }
              },
            );
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: isLandscape ? 10.w : 14.w,
              vertical: isLandscape ? 8.h : 10.h,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF231E3D),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/ic_continue_with_ads.svg',
                  width: 32.r,
                  height: 32.r,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('continue_with_ad'),
                        style: AppTextStyles.textWhite14.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isLandscape ? 12 : 14,
                        ),
                      ),
                      Text(
                        context.tr('watch_ad_sub'),
                        style: AppTextStyles.textGrey12.copyWith(
                          fontSize: isLandscape ? 9 : 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.white54,
                  size: isLandscape ? 18 : 22,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Flash Sale Banner for Unlock Popup (banner_sales_popup.png with live countdown timer)
  Widget _buildFlashSaleBanner(bool isLandscape) {
    final hours = _flashSaleRemaining.inHours.toString().padLeft(2, '0');
    final minutes = (_flashSaleRemaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (_flashSaleRemaining.inSeconds % 60).toString().padLeft(2, '0');

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(null);
        context.push('/premium');
      },
      child: AspectRatio(
        aspectRatio: 855 / 276,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 1. Popup Flash Sale Banner Graphic (Fixed aspect ratio 855:276, zero distortion)
            Positioned.fill(
              child: Image.asset(
                'assets/images/banner_sales_popup.webp',
                fit: BoxFit.contain,
              ),
            ),

            // 2. Countdown Timer overlay in the right dark purple section
            Positioned.fill(
              child: Row(
                children: [
                  // Left ~46% is occupied by the 3D Lightning & FLASH SALE text
                  const Spacer(flex: 46),

                  // Right ~54% contains the Countdown Timer
                  Expanded(
                    flex: 54,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: isLandscape ? 6.w : 10.w,
                        top: isLandscape ? 2.h : 3.h,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 20.h,),
                          Text(
                            context.tr('ends_in'),
                            style: TextStyle(
                              fontSize: isLandscape ? 8 : 10.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: isLandscape ? 2.h : 3.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPopupTimerColumn(
                                hours,
                                context.tr('hours'),
                                isLandscape,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isLandscape ? 1.5.w : 2.5.w,
                                  vertical: isLandscape ? 1.h : 2.h,
                                ),
                                child: Text(
                                  ':',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isLandscape ? 9 : 12,
                                  ),
                                ),
                              ),
                              _buildPopupTimerColumn(
                                minutes,
                                context.tr('minutes'),
                                isLandscape,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isLandscape ? 1.5.w : 2.5.w,
                                  vertical: isLandscape ? 1.h : 2.h,
                                ),
                                child: Text(
                                  ':',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isLandscape ? 9 : 12,
                                  ),
                                ),
                              ),
                              _buildPopupTimerColumn(
                                seconds,
                                context.tr('seconds'),
                                isLandscape,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopupTimerColumn(String value, String label, bool isLandscape) {
    final boxSize = isLandscape ? 12.w : 23.w;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: boxSize,
          height: boxSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: const Color(0xFF130826).withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(isLandscape ? 3.r : 4.r),
            border: Border.all(
              color: const Color(0xFF6E40A8).withValues(alpha: 0.9),
              width: 1.0,
            ),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: isLandscape ? 8 : 11,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ),
        SizedBox(height: isLandscape ? 1.h : 2.h),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isLandscape ? 5.5 : 6.5,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STATE 2: Download (Unlocked but Data Not Downloaded)
  // ---------------------------------------------------------------------------
  Widget _buildDownloadState(bool isLandscape) {
    final thumbSize = isLandscape ? 56.0 : 90.0;

    return Column(
      children: [
        // Song Thumbnail
        SongThumbnail(
          thumbnailUrl: widget.song.thumbnail,
          width: thumbSize,
          height: thumbSize,
          borderRadius: 14,
        ),
        SizedBox(height: isLandscape ? 10.h : 14.h),

        // Song Title
        Text(
          widget.song.titleName,
          textAlign: TextAlign.center,
          style: (isLandscape
                  ? AppTextStyles.textWhite16
                  : AppTextStyles.textWhite20)
              .copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isLandscape ? 4.h : 6.h),

        // Subtitle
        Text(
          widget.song.authorName.isNotEmpty
              ? widget.song.authorName
              : "Get this special song and spread the holiday joy!",
          textAlign: TextAlign.center,
          style: AppTextStyles.textGrey12.copyWith(
            fontSize: isLandscape ? 10 : 12,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isLandscape ? 14.h : 20.h),

        // Download Button
        GestureDetector(
          onTap: _isDownloading
              ? null
              : () async {
                  setState(() {
                    _isDownloading = true;
                  });
                  // Simulate/fetch song data loading
                  await Future.delayed(const Duration(milliseconds: 600));
                  if (mounted) {
                    setState(() {
                      _isDownloading = false;
                      _isDownloaded = true;
                    });
                  }
                },
          child: Container(
            width: double.infinity,
            height: isLandscape ? 36.h : 44.h,
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
              child: _isDownloading
                  ? SizedBox(
                      width: isLandscape ? 16 : 20,
                      height: isLandscape ? 16 : 20,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      context.tr('download'),
                      style: (isLandscape
                              ? AppTextStyles.textWhite14
                              : AppTextStyles.textWhite16)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // STATE 3: Ready to Play (3 Difficulty Chips ABOVE Play Now button)
  // ---------------------------------------------------------------------------
  Widget _buildReadyToPlayState(bool isLandscape, String songIdStr) {
    final thumbSize = isLandscape ? 48.0 : 80.0;

    return Column(
      children: [
        // Song Thumbnail
        SongThumbnail(
          thumbnailUrl: widget.song.fullThumbnailUrl,
          width: thumbSize,
          height: thumbSize,
          borderRadius: 14,
        ),
        SizedBox(height: isLandscape ? 8.h : 12.h),

        // Song Title
        Text(
          widget.song.titleName,
          textAlign: TextAlign.center,
          style: (isLandscape
                  ? AppTextStyles.textWhite14
                  : AppTextStyles.textWhite18)
              .copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isLandscape ? 2.h : 4.h),

        // Subtitle
        Text(
          widget.song.authorName.isNotEmpty
              ? widget.song.authorName
              : context.tr('ready_to_play'),
          textAlign: TextAlign.center,
          style: AppTextStyles.textGrey12.copyWith(
            fontSize: isLandscape ? 10 : 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: isLandscape ? 10.h : 14.h),

        // 3 DIFFICULTY CHIPS IN A SINGLE HORIZONTAL ROW (PLACED ABOVE PLAY NOW BUTTON)
        Row(
          children: [
            Expanded(
              child: _buildDifficultyOptionHorizontal(
                level: 1,
                title: context.tr('easy'),
                color: AppColors.levelEasy,
                icon: Icons.speed_rounded,
                isLandscape: isLandscape,
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: _buildDifficultyOptionHorizontal(
                level: 2,
                title: context.tr('medium'),
                color: AppColors.levelMedium,
                icon: Icons.equalizer_rounded,
                isLandscape: isLandscape,
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: _buildDifficultyOptionHorizontal(
                level: 3,
                title: context.tr('hard'),
                color: AppColors.levelHard,
                icon: Icons.local_fire_department_rounded,
                isLandscape: isLandscape,
              ),
            ),
          ],
        ),

        SizedBox(height: isLandscape ? 12.h : 16.h),

        // PLAY NOW BUTTON
        GestureDetector(
          onTap: () {
            Navigator.of(context).pop(_selectedLevel);
          },
          child: Container(
            width: double.infinity,
            height: isLandscape ? 36.h : 44.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              gradient: const LinearGradient(
                colors: [Color(0xFF9E4BE6), Color(0xFF7A44DA)],
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
                context.tr('play_now'),
                style: (isLandscape
                        ? AppTextStyles.textWhite14
                        : AppTextStyles.textWhite16)
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Helper Widget for Difficulty Selector Chip (Compact Horizontal Layout)
  Widget _buildDifficultyOptionHorizontal({
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
          horizontal: 4.w,
          vertical: isLandscape ? 5.h : 8.h,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.22)
              : const Color(0xFF1E1935),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.white54,
              size: isLandscape ? 14 : 16,
            ),
            SizedBox(height: 3.h),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: AppTextStyles.textWhite12.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? color : Colors.white70,
                  fontSize: isLandscape ? 10 : 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
