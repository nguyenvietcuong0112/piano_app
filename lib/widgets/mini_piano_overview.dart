import 'package:flutter/material.dart';

class MiniPianoOverview extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
          double totalWidth = constraints.maxWidth;
          // 7 octaves total (0 to 6)
          double octaveWidth = totalWidth / 7.0;
          double highlightLeft = currentStartOctave * octaveWidth;
          double highlightWidth =
              (visibleWhiteKeysCount / 7.0).clamp(1.0, 3.0) * octaveWidth;

          return GestureDetector(
            onTapDown: (details) {
              int clickedOctave =
                  (details.localPosition.dx / octaveWidth).floor().clamp(0, 6);
              onScrollOctave?.call(clickedOctave);
            },
            onHorizontalDragUpdate: (details) {
              int draggedOctave =
                  (details.localPosition.dx / octaveWidth).floor().clamp(0, 6);
              onScrollOctave?.call(draggedOctave);
            },
            child: Stack(
              children: [
                // Render Mini Piano Keyboard (52 Mini White Keys + 36 Mini Black Keys)
                CustomPaint(
                  size: Size(totalWidth, constraints.maxHeight),
                  painter: MiniPianoPainter(),
                ),

                // Active Viewport Box Highlight (White box matching user's screenshot)
                Positioned(
                  left: highlightLeft.clamp(0, totalWidth - highlightWidth),
                  width: highlightWidth.clamp(octaveWidth, totalWidth),
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0x45FFFFFF),
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(2),
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

class MiniPianoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    const int totalWhiteKeys = 52;

    final double whiteKeyWidth = width / totalWhiteKeys;
    final double blackKeyWidth = whiteKeyWidth * 0.65;
    final double blackKeyHeight = height * 0.58;

    final Paint whiteKeyPaint = Paint()..color = const Color(0xFFE8E8EC);
    final Paint whiteBorderPaint = Paint()
      ..color = const Color(0xFF888890)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final Paint blackKeyPaint = Paint()..color = const Color(0xFF111115);

    // Draw Mini White Keys
    for (int i = 0; i < totalWhiteKeys; i++) {
      double left = i * whiteKeyWidth;
      Rect rect = Rect.fromLTRB(left, 0, left + whiteKeyWidth, height);
      canvas.drawRect(rect, whiteKeyPaint);
      canvas.drawRect(rect, whiteBorderPaint);
    }

    // Draw Mini Black Keys
    int whiteIndex = 0;
    for (int oct = 0; oct < 8; oct++) {
      for (int i = 0; i < 7; i++) {
        if (whiteIndex >= totalWhiteKeys) break;
        if (i != 2 && i != 6) {
          double right = (whiteIndex + 1) * whiteKeyWidth;
          double bLeft = right - (blackKeyWidth / 2.0);
          Rect bRect =
              Rect.fromLTRB(bLeft, 0, bLeft + blackKeyWidth, blackKeyHeight);
          canvas.drawRect(bRect, blackKeyPaint);
        }
        whiteIndex++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
