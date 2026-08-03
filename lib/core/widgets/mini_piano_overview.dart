import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MiniPianoOverview extends ConsumerWidget {
  final int currentStartOctave;
  final int visibleWhiteKeysCount;
  final Function(int octave)? onScrollOctave;

  const MiniPianoOverview({
    super.key,
    required this.currentStartOctave,
    this.visibleWhiteKeysCount = 14,
    this.onScrollOctave,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF181820),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double totalWidth = constraints.maxWidth;
          const int totalOctaves = 7;
          final double octaveWidth = totalWidth / totalOctaves;

          final double viewportWidth =
              (visibleWhiteKeysCount / 7.0) * octaveWidth;
          final double viewportLeft =
              ((currentStartOctave - 1).clamp(0, totalOctaves - 1)) *
                  octaveWidth;

          return GestureDetector(
            onHorizontalDragUpdate: (details) {
              final double dx = details.localPosition.dx;
              int targetOctave = ((dx / totalWidth) * totalOctaves).floor() + 1;
              targetOctave = targetOctave.clamp(1, 6);
              onScrollOctave?.call(targetOctave);
            },
            onTapDown: (details) {
              final double dx = details.localPosition.dx;
              int targetOctave = ((dx / totalWidth) * totalOctaves).floor() + 1;
              targetOctave = targetOctave.clamp(1, 6);
              onScrollOctave?.call(targetOctave);
            },
            child: Stack(
              children: [
                Row(
                  children: List.generate(totalOctaves, (octIndex) {
                    int octNum = octIndex + 1;
                    return Container(
                      width: octaveWidth,
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Colors.white.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          "C$octNum",
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  }),
                ),

                Positioned(
                  left: viewportLeft.clamp(0.0, totalWidth - viewportWidth),
                  top: 2,
                  bottom: 2,
                  width: viewportWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.3),
                      border: Border.all(color: Colors.amber, width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        "C$currentStartOctave",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
