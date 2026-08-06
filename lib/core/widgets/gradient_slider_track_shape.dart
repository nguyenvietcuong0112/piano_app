import 'package:flutter/material.dart';

class GradientSliderTrackShape extends RoundedRectSliderTrackShape {
  final LinearGradient gradient;

  const GradientSliderTrackShape({
    this.gradient = const LinearGradient(
      colors: [
        Color(0xFFCF6BEE),
        Color(0xFF7A44DA),
      ],
    ),
  });

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required TextDirection textDirection,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    double additionalActiveTrackHeight = 0,
  }) {
    final Canvas canvas = context.canvas;
    final Rect trackRect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );

    final double trackHeight = sliderTheme.trackHeight ?? 4.0;
    final Radius trackRadius = Radius.circular(trackHeight / 2);

    // 1. Draw Inactive Track
    final Paint inactivePaint = Paint()
      ..color = sliderTheme.inactiveTrackColor ?? Colors.white24
      ..style = PaintingStyle.fill;

    final RRect inactiveRRect = RRect.fromRectAndRadius(
      Rect.fromLTRB(
        trackRect.left,
        thumbCenter.dy - trackHeight / 2,
        trackRect.right,
        thumbCenter.dy + trackHeight / 2,
      ),
      trackRadius,
    );
    canvas.drawRRect(inactiveRRect, inactivePaint);

    // 2. Draw Active Gradient Track
    final double activeTrackRight = thumbCenter.dx.clamp(trackRect.left, trackRect.right);
    if (activeTrackRight > trackRect.left) {
      final Rect activeRect = Rect.fromLTRB(
        trackRect.left,
        thumbCenter.dy - trackHeight / 2,
        activeTrackRight,
        thumbCenter.dy + trackHeight / 2,
      );

      final Paint activePaint = Paint()
        ..shader = gradient.createShader(
          Rect.fromLTRB(trackRect.left, trackRect.top, trackRect.right, trackRect.bottom),
        )
        ..style = PaintingStyle.fill;

      final RRect activeRRect = RRect.fromRectAndRadius(activeRect, trackRadius);
      canvas.drawRRect(activeRRect, activePaint);
    }
  }
}
