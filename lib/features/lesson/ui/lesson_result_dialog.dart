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
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                _title,
                style: AppTextStyles.textWhite20.copyWith(color: Colors.amberAccent, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                songTitle,
                style: AppTextStyles.textGrey14,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Star Rating Display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final isFilled = index < state.stars;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: isFilled ? Colors.amber : Colors.white24,
                      size: 30,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 10),

              // Stats Card
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2A3D),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildStatRow(
                      "Độ chính xác",
                      "${state.accuracy.toStringAsFixed(1)}%",
                      Colors.lightBlueAccent,
                    ),
                    const Divider(color: Colors.white10, height: 8),
                    _buildStatRow(
                      "Tổng điểm",
                      "${state.score}",
                      Colors.amberAccent,
                    ),
                    const Divider(color: Colors.white10, height: 8),
                    _buildStatRow(
                      "Max Combo",
                      "${state.maxCombo}",
                      Colors.greenAccent,
                    ),
                    const Divider(color: Colors.white10, height: 8),
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
              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        context.pop();
                      },
                      icon: const Icon(Icons.list_rounded, size: 16),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text("Danh sách", style: AppTextStyles.textWhite14.copyWith(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade700,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        onReplay();
                      },
                      icon: const Icon(Icons.replay_rounded, size: 16),
                      label: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text("Chơi lại", style: AppTextStyles.textBlack14),
                      ),
                    ),
                  ),
                  if (onNextSong != null) ...[
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          onNextSong!();
                        },
                        icon: const Icon(Icons.skip_next_rounded, size: 16),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text("Bài tiếp", style: AppTextStyles.textWhite14.copyWith(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.textGrey14,
            overflow: TextOverflow.ellipsis,
          ),
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
