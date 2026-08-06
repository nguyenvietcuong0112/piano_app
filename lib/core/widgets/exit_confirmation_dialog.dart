import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'gradient_border_card.dart';

class ExitConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;

  const ExitConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
  });

  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmText,
    required String cancelText,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => ExitConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: GradientBorderCard(
        width: 320.w,
        borderRadius: 20,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Bar: Title + Close 'X' Button
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(false),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Description Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.85),
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w400,
              ),
            ),

            const SizedBox(height: 24),

            // Action Buttons: Cancel | Confirm
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: GradientBorderCard(
                    height: 42,
                    borderRadius: 21,
                    onTap: () => Navigator.of(context).pop(false),
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
                        cancelText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Confirm Button
                Expanded(
                  child: GradientBorderCard(
                    height: 42,
                    borderRadius: 21,
                    onTap: () => Navigator.of(context).pop(true),
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
                        confirmText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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
      ),
    );
  }
}
