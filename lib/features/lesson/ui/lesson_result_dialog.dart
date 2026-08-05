import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_text_styles.dart';
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

  String get _title {
    switch (state.stars) {
      case 5:
        return "✨ BẬC THẦY PIANO! ✨";
      case 4:
        return "🌟 XUẤT SẮC! 🌟";
      case 3:
        return "🎉 TUYỆT VỜI! 🎉";
      case 2:
        return "👍 KHÁ TỐT!";
      case 1:
        return "💪 CỐ GẮNG LÊN!";
      default:
        return "🎧 CHƯA HOÀN THÀNH";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 460),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 2),
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
            // Title
            Text(
              _title,
              style: AppTextStyles.textWhite20.copyWith(color: Colors.amberAccent),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              songTitle,
              style: AppTextStyles.textGrey14,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Star Rating Display
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final isFilled = index < state.stars;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Icon(
                    isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: isFilled ? Colors.amber : Colors.white24,
                    size: 38,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Stats Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2A3D),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildStatRow(
                    "Độ chính xác (Accuracy)",
                    "${state.accuracy.toStringAsFixed(1)}%",
                    Colors.lightBlueAccent,
                  ),
                  const Divider(color: Colors.white10, height: 12),
                  _buildStatRow(
                    "Tổng điểm (Score)",
                    "${state.score}",
                    Colors.amberAccent,
                  ),
                  const Divider(color: Colors.white10, height: 12),
                  _buildStatRow(
                    "Max Combo",
                    "${state.maxCombo}",
                    Colors.greenAccent,
                  ),
                  const Divider(color: Colors.white10, height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHitBadge("Perfect", state.perfectCount, Colors.green),
                      _buildHitBadge("Good", state.goodCount, Colors.orange),
                      _buildHitBadge("Miss", state.missCount, Colors.redAccent),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.pop();
                    },
                    icon: const Icon(Icons.list_rounded, size: 18),
                    label: Text("Danh sách", style: AppTextStyles.textWhite14.copyWith(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onReplay();
                    },
                    icon: const Icon(Icons.replay_rounded, size: 18),
                    label: Text("Chơi lại", style: AppTextStyles.textBlack14),
                  ),
                ),
                if (onNextSong != null) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onNextSong!();
                      },
                      icon: const Icon(Icons.skip_next_rounded, size: 18),
                      label: Text("Bài tiếp", style: AppTextStyles.textWhite14.copyWith(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.textGrey14,
        ),
        Text(
          value,
          style: AppTextStyles.textWhite16.copyWith(color: color),
        ),
      ],
    );
  }

  Widget _buildHitBadge(String label, int count, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.textWhite12.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          "$count",
          style: AppTextStyles.textWhite14.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
