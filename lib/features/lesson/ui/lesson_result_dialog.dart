import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_border_card.dart';
import '../controller/lesson_play_controller.dart';

class LessonResultDialog extends StatelessWidget {
  final LessonPlayState state;
  final String songTitle;
  final VoidCallback onReplay;
  final VoidCallback? onNextSong;

  const LessonResultDialog({
    super.key,
    required this.state,
    required this.songTitle,
    required this.onReplay,
    this.onNextSong,
  });

  @override
  Widget build(BuildContext context) {
    final int earnedStars = state.stars;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: GradientBorderCard(
        width: 150.w,
        borderRadius: 24,
        strokeWidth: 1.5,
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 8.w, 24.h),
        backgroundGradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1C182F),
            Color(0xFF12101F),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFAB47BC).withValues(alpha: 0.8),
            const Color(0xFF7B1FA2).withValues(alpha: 0.3),
            Colors.white.withValues(alpha: 0.2),
          ],
        ),
        child: Stack(
          children: [
            // Top Right Close Button
            Positioned(
              right: 0,
              top: 0,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 18.r,
                    ),
                  ),
                ),
              ),
            ),

            // Main Content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 36.h),
                // Star Rating Display (5 Stars)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final isFilled = index < earnedStars;
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 3.w),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (isFilled)
                            Container(
                              width: 28.w,
                              height: 28.h,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withValues(alpha: 0.6),
                                    blurRadius: 12.r,
                                    spreadRadius: 2.r,
                                  ),
                                ],
                              ),
                            ),
                          Icon(
                            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                            color: isFilled ? const Color(0xFFFFC107) : Colors.white24,
                            size: 34.r,
                          ),
                        ],
                      ),
                    );
                  }),
                ),

                SizedBox(height: 16.h),

                // Score Display
                Text(
                  "${state.score}",
                  style: AppTextStyles.textWhite22.copyWith(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 12.h),

                // Congratulations Subtitle
                Text(
                  context.tr('lesson_completed'),
                  style: AppTextStyles.textWhite14.copyWith(
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 24.h),

                // Action Buttons Row
                Row(
                  children: [
                    // Replay Button
                    Expanded(
                      child: GradientBorderCard(
                        height: 44.h,
                        borderRadius: 22,
                        strokeWidth: 1.0,
                        onTap: () {
                          Navigator.of(context).pop();
                          onReplay();
                        },
                        backgroundGradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFF382654),
                            Color(0xFF281C3F),
                          ],
                        ),
                        borderGradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            const Color(0xFFAB47BC).withValues(alpha: 0.5),
                            const Color(0xFF7B1FA2).withValues(alpha: 0.3),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            context.tr('replay'),
                            style: AppTextStyles.textWhite14.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 12.w),

                    // Next Lesson Button
                    Expanded(
                      child: GradientBorderCard(
                        height: 44.h,
                        borderRadius: 22,
                        strokeWidth: 1.0,
                        onTap: () {
                          Navigator.of(context).pop();
                          if (onNextSong != null) {
                            onNextSong!();
                          } else {
                            context.pop();
                          }
                        },
                        backgroundGradient: const LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Color(0xFFCF6BEE),
                            Color(0xFF9C27B0),
                          ],
                        ),
                        borderGradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.4),
                            const Color(0xFFCF6BEE).withValues(alpha: 0.6),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            context.tr('next_lesson'),
                            style: AppTextStyles.textWhite14.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
