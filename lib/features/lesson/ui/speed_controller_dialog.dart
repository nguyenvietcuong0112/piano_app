import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/widgets/gradient_border_card.dart';
import '../../../core/widgets/gradient_slider_track_shape.dart';

class SpeedControllerDialog extends StatefulWidget {
  final double initialSpeed;
  final ValueChanged<double> onSpeedChanged;

  const SpeedControllerDialog({
    super.key,
    required this.initialSpeed,
    required this.onSpeedChanged,
  });

  static Future<void> show({
    required BuildContext context,
    required double initialSpeed,
    required ValueChanged<double> onSpeedChanged,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => SpeedControllerDialog(
        initialSpeed: initialSpeed,
        onSpeedChanged: onSpeedChanged,
      ),
    );
  }

  @override
  State<SpeedControllerDialog> createState() => _SpeedControllerDialogState();
}

class _SpeedControllerDialogState extends State<SpeedControllerDialog> {
  late double _currentSpeed;

  @override
  void initState() {
    super.initState();
    _currentSpeed = widget.initialSpeed;
  }

  @override
  Widget build(BuildContext context) {
    // Value range 0.0 to 2.0
    const double minSpeed = 0.0;
    const double maxSpeed = 2.0;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: GradientBorderCard(
        width: 320.w,
        borderRadius: 20,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
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
                const Text(
                  "Speed Controller",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 28.h,
                      height: 28.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Value Indicator Pill above Slider
            LayoutBuilder(
              builder: (context, constraints) {
                final double trackWidth = constraints.maxWidth - 60; // space between 0.0 and 2.0
                final double clampedProgress = ((_currentSpeed - minSpeed) / (maxSpeed - minSpeed)).clamp(0.0, 1.0);
                final double pillOffset = 30 + (trackWidth * clampedProgress) - 18;

                return Column(
                  children: [
                    SizedBox(
                      height: 24,
                      child: Stack(
                        children: [
                          Positioned(
                            left: pillOffset.clamp(0.0, constraints.maxWidth - 36),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6B46C1).withValues(alpha: 0.7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _currentSpeed.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Slider Row: "0.0" | ----- Thumb ----- | "2.0"
                    Row(
                      children: [
                        const Text(
                          "0.0",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 4,
                              trackShape: const GradientSliderTrackShape(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFCF6BEE),
                                    Color(0xFF7A44DA),
                                  ],
                                ),
                              ),
                              inactiveTrackColor: Colors.white24,
                              thumbColor: Colors.white,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                              overlayColor: const Color(0xFFCF6BEE).withValues(alpha: 0.2),
                            ),
                            child: Slider(
                              value: _currentSpeed.clamp(minSpeed, maxSpeed),
                              min: minSpeed,
                              max: maxSpeed,
                              onChanged: (val) {
                                final roundedVal = (val * 10).round() / 10.0;
                                setState(() {
                                  _currentSpeed = roundedVal;
                                });
                                widget.onSpeedChanged(roundedVal);
                              },
                            ),
                          ),
                        ),
                        const Text(
                          "2.0",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
