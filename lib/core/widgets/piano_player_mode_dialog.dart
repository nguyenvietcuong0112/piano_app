import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../localization/app_localizations.dart';
import '../theme/app_text_styles.dart';

class PianoPlayerModeDialog extends StatefulWidget {
  final bool initialIsDualMode;

  const PianoPlayerModeDialog({
    super.key,
    required this.initialIsDualMode,
  });

  static Future<bool?> show(
    BuildContext context, {
    required bool initialIsDualMode,
  }) async {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (context) => PianoPlayerModeDialog(
        initialIsDualMode: initialIsDualMode,
      ),
    );
  }

  @override
  State<PianoPlayerModeDialog> createState() => _PianoPlayerModeDialogState();
}

class _PianoPlayerModeDialogState extends State<PianoPlayerModeDialog> {
  late bool _isDualMode;

  @override
  void initState() {
    super.initState();
    _isDualMode = widget.initialIsDualMode;
  }

  void _toggleMode() {
    setState(() {
      _isDualMode = !_isDualMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        width: 320.w,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E24),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Navigation Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Back / Close Button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(null),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),

                // Title: Chế độ người chơi
                Text(
                  context.tr('player_mode_title') == 'player_mode_title'
                      ? 'Chế độ người chơi'
                      : context.tr('player_mode_title'),
                  style: AppTextStyles.textWhite18.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),

                // Save Button (Lưu)
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(_isDualMode),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2196F3),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      context.tr('save'),
                      style: AppTextStyles.textWhite14.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Mode Selector Area with Left/Right arrows
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left Arrow Button
                GestureDetector(
                  onTap: _toggleMode,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white70,
                      size: 28,
                    ),
                  ),
                ),

                SizedBox(width: 14.w),

                // Main Mode Preview Card
                GestureDetector(
                  onTap: _toggleMode,
                  child: Container(
                    width: 210.w,
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14141A),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: const Color(0xFF2196F3).withValues(alpha: 0.8),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Piano Keys Graphical Preview
                        Container(
                          height: _isDualMode ? 70.h : 55.h,
                          width: double.infinity,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A36),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildMiniRowPreview(),
                              if (_isDualMode) ...[
                                SizedBox(height: 4.h),
                                _buildMiniRowPreview(),
                              ],
                            ],
                          ),
                        ),

                        SizedBox(height: 12.h),

                        // Mode Label Text
                        Text(
                          _isDualMode
                              ? (context.tr('dual_row_mode') == 'dual_row_mode'
                                  ? 'Chế độ hàng kép'
                                  : context.tr('dual_row_mode'))
                              : (context.tr('single_row_mode') == 'single_row_mode'
                                  ? 'Chế độ hàng đơn'
                                  : context.tr('single_row_mode')),
                          style: AppTextStyles.textWhite14.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 14.w),

                // Right Arrow Button
                GestureDetector(
                  onTap: _toggleMode,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white70,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 14.h),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniRowPreview() {
    return Container(
      height: 24.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        children: List.generate(10, (index) {
          final isBlackKey = index == 1 || index == 3 || index == 6 || index == 8;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              decoration: BoxDecoration(
                color: isBlackKey ? Colors.black : Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(2.r),
                  bottomRight: Radius.circular(2.r),
                ),
                border: Border.all(color: Colors.grey.shade400, width: 0.5),
              ),
            ),
          );
        }),
      ),
    );
  }
}
