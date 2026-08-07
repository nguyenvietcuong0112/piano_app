import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import '../theme/app_text_styles.dart';
import 'gradient_border_card.dart';

class RecordButton extends StatefulWidget {
  final bool isRecording;
  final VoidCallback onTap;

  const RecordButton({
    super.key,
    required this.isRecording,
    required this.onTap,
  });

  @override
  State<RecordButton> createState() => _RecordButtonState();
}

class _RecordButtonState extends State<RecordButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  Timer? _timer;
  int _recordSeconds = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    if (widget.isRecording) {
      _startRecordingState();
    }
  }

  @override
  void didUpdateWidget(covariant RecordButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecording != oldWidget.isRecording) {
      if (widget.isRecording) {
        _startRecordingState();
      } else {
        _stopRecordingState();
      }
    }
  }

  void _startRecordingState() {
    _recordSeconds = 0;
    _pulseController.repeat(reverse: true);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _recordSeconds++;
        });
      }
    });
  }

  void _stopRecordingState() {
    _pulseController.stop();
    _timer?.cancel();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    int minutes = _recordSeconds ~/ 60;
    int seconds = _recordSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    final defaultBgGradient = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xFF141126),
        Color(0xFF0F0F1E),
      ],
    );

    final recordingBgGradient = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Color(0xFFD32F2F),
        Color(0xFFB71C1C),
      ],
    );

    final defaultBorderGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        Colors.white.withValues(alpha: 0.1),
        Colors.white.withValues(alpha: 0.1),
      ],
    );

    final recordingBorderGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        const Color(0xFFFF5252).withValues(alpha: 0.8),
        const Color(0xFFFF1744).withValues(alpha: 0.8),
      ],
    );

    return GradientBorderCard(
      height: 36.h,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      borderRadius: 16,
      onTap: widget.onTap,
      backgroundGradient: widget.isRecording ? recordingBgGradient : defaultBgGradient,
      borderGradient: widget.isRecording ? recordingBorderGradient : defaultBorderGradient,
      child: Align(
        alignment: Alignment.center,
        widthFactor: 1.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Indicator Icon / Animated Pulsing Dot
            if (widget.isRecording)
              FadeTransition(
                opacity: _pulseController,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            else
              SvgPicture.asset(
                'assets/icons/ic_rec.svg',
                width: 22.h,
                height: 22.h,
              ),

            const SizedBox(width: 6),

            // Label Text (Shows active timer when recording, 'REC' when standby)
            Text(
              widget.isRecording ? _formattedTime : "REC",
              style: AppTextStyles.textWhite12.copyWith(
                color: widget.isRecording ? Colors.white : Colors.white70,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
