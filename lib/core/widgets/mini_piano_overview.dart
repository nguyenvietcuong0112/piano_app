import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'gradient_border_card.dart';

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

  void _handleInteraction(Offset localPosition, double width) {
    if (width <= 0) return;
    final double fraction = (localPosition.dx / width).clamp(0.0, 1.0);
    // 7 total octaves
    int targetOctave = (fraction * 7).floor() + 1;
    targetOctave = targetOctave.clamp(1, 6);
    onScrollOctave?.call(targetOctave);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GradientBorderCard(
      height: 64.h,
      padding: EdgeInsets.all(1),
      borderRadius: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            return GestureDetector(
              onTapDown: (details) =>
                  _handleInteraction(details.localPosition, width),
              onHorizontalDragUpdate: (details) =>
                  _handleInteraction(details.localPosition, width),
              child: CustomPaint(
                size: Size(width, constraints.maxHeight),
                painter: _MiniPianoPainter(
                  currentStartOctave: currentStartOctave,
                  visibleWhiteKeysCount: visibleWhiteKeysCount,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MiniPianoPainter extends CustomPainter {
  final int currentStartOctave;
  final int visibleWhiteKeysCount;

  _MiniPianoPainter({
    required this.currentStartOctave,
    required this.visibleWhiteKeysCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const int totalOctaves = 7;
    const int whiteKeysPerOctave = 7;
    const int totalWhiteKeys = totalOctaves * whiteKeysPerOctave; // 49

    final double wkWidth = size.width / totalWhiteKeys;

    // Calculate active white key index range
    final int startWhiteKey =
        ((currentStartOctave - 1) * whiteKeysPerOctave).clamp(0, totalWhiteKeys - 1);
    final int endWhiteKey =
        (startWhiteKey + visibleWhiteKeysCount).clamp(0, totalWhiteKeys);

    final Paint whiteKeyPaint = Paint()..style = PaintingStyle.fill;
    final Paint linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 1. Draw White Keys
    for (int i = 0; i < totalWhiteKeys; i++) {
      final bool isActive = i >= startWhiteKey && i < endWhiteKey;
      final double left = i * wkWidth;
      final Rect rect = Rect.fromLTWH(left, 0, wkWidth, size.height);

      // Fill color
      whiteKeyPaint.color = isActive
          ? const Color(0xFFFFFFFF)
          : const Color(0xFF3A3A42);
      canvas.drawRect(rect, whiteKeyPaint);

      // Separator line between white keys
      linePaint.color = isActive
          ? const Color(0xFFC0C0C8)
          : const Color(0xFF222228);
      canvas.drawLine(
        Offset(left + wkWidth, 0),
        Offset(left + wkWidth, size.height),
        linePaint,
      );
    }

    // 2. Draw Black Keys
    final double bkWidth = wkWidth * 0.65;
    final double bkHeight = size.height * 0.60;

    final Paint blackKeyPaint = Paint()..style = PaintingStyle.fill;
    final Paint blackBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    // Relative white key positions before a black key in an octave
    const List<int> blackKeyPositions = [0, 1, 3, 4, 5];

    for (int oct = 0; oct < totalOctaves; oct++) {
      for (final int relPos in blackKeyPositions) {
        final int whiteIndex = oct * whiteKeysPerOctave + relPos;
        final double centerX = (whiteIndex + 1) * wkWidth;
        final double left = centerX - (bkWidth / 2);

        final bool isActive =
            whiteIndex >= startWhiteKey && whiteIndex < endWhiteKey - 1;

        final Rect bkRect = Rect.fromLTWH(left, 0, bkWidth, bkHeight);
        final RRect bkRRect = RRect.fromRectAndCorners(
          bkRect,
          bottomLeft: const Radius.circular(1),
          bottomRight: const Radius.circular(1),
        );

        // Fill color
        blackKeyPaint.color = isActive
            ? const Color(0xFF08080C)
            : const Color(0xFF16161C);
        canvas.drawRRect(bkRRect, blackKeyPaint);

        // Border color
        blackBorderPaint.color = isActive
            ? const Color(0xFF333340)
            : const Color(0xFF101014);
        canvas.drawRRect(bkRRect, blackBorderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MiniPianoPainter oldDelegate) {
    return oldDelegate.currentStartOctave != currentStartOctave ||
        oldDelegate.visibleWhiteKeysCount != visibleWhiteKeysCount;
  }
}
