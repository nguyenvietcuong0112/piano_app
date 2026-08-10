import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../theme/app_text_styles.dart';
import '../services/audio_recorder_service.dart';
import '../localization/app_localizations.dart';
import 'gradient_border_card.dart';

class RecordSelectionDialog extends StatelessWidget {
  const RecordSelectionDialog({super.key});

  static Future<RecordingMode?> show(BuildContext context) {
    return showDialog<RecordingMode>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => const RecordSelectionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: GradientBorderCard(
        margin:  EdgeInsets.symmetric(horizontal: 8.sp),
        padding: EdgeInsets.all(16.r),
        borderRadius: 16,
        child: SizedBox(
          width: 150.w,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title & Close Button Header
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        context.tr('record'),
                        style: AppTextStyles.textWhite16,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 40.r,
                          height: 40.r,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF28213B),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16.r,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Option 1: My recording
                _buildOptionTile(
                  context: context,
                  icon: Icons.mic_rounded,
                  label: context.tr('my_recordings'),
                  onTap: () => Navigator.pop(context, RecordingMode.mic),
                ),
                SizedBox(height: 10.h),

                // Option 2: Piano Sheets
                _buildOptionTile(
                  context: context,
                  icon: Icons.piano_rounded,
                  label: "Piano Sheets",
                  onTap: () => Navigator.pop(context, RecordingMode.internal),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 66.h,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        decoration: BoxDecoration(
          color: const Color(0xFF332450),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                color: const Color(0xFF8643ED),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 18.r,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: AppTextStyles.textWhite14.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordSaveDialog extends StatefulWidget {
  final String defaultTitle;
  final String? titleText;

  const RecordSaveDialog({
    super.key,
    required this.defaultTitle,
    this.titleText,
  });

  static Future<String?> show(
    BuildContext context, {
    required String defaultTitle,
    String? titleText,
  }) {
    return showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => RecordSaveDialog(
        defaultTitle: defaultTitle,
        titleText: titleText,
      ),
    );
  }

  @override
  State<RecordSaveDialog> createState() => _RecordSaveDialogState();
}

class _RecordSaveDialogState extends State<RecordSaveDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      child: GradientBorderCard(
        margin:  EdgeInsets.symmetric(horizontal: 8.sp),
        padding: EdgeInsets.all(16.r),
        borderRadius: 16,
        child: SizedBox(
          width: 150.w,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title & Close Button Header
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Text(
                        widget.titleText ?? context.tr('save_recording'),
                        style: AppTextStyles.textWhite16,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, null),
                        child: Container(
                          width: 28.r,
                          height: 28.r,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF28213B),
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 16.r,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Editable Input Box
                Container(
                  height: 48.h,
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF100C1D),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: const Color(0xFFCF6BEE).withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit_outlined,
                        color: Colors.white70,
                        size: 18.r,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: AppTextStyles.textWhite14.copyWith(fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: context.tr('enter_rec_title'),
                            hintStyle: AppTextStyles.textGrey14.copyWith(color: Colors.white38, fontSize: 14.r),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _controller.clear(),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white70,
                          size: 18.r,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),

                // Bottom Buttons: Cancel vs Save
                Row(
                  children: [
                    // Cancel Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context, null),
                        child: Container(
                          height: 42.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFF332450),
                            borderRadius: BorderRadius.circular(21.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              context.tr('cancel'),
                              style: AppTextStyles.textWhite14.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),

                    // Save Button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          final title = _controller.text.trim();
                          Navigator.pop(context, title.isNotEmpty ? title : widget.defaultTitle);
                        },
                        child: Container(
                          height: 42.h,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFB158F0), Color(0xFF7E26D4)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(21.r),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7E26D4).withValues(alpha: 0.4),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              context.tr('save'),
                              style: AppTextStyles.textWhite14.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
