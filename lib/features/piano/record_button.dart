import 'dart:async';
import 'package:flutter/material.dart';

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
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: widget.isRecording
              ? const Color(0xFFD32F2F)
              : const Color(0xFF252533),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.isRecording
                ? const Color(0xFFFF5252)
                : Colors.white24,
            width: 1.5,
          ),
          boxShadow: [
            if (widget.isRecording)
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.5),
                blurRadius: 10,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
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
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
              ),

            const SizedBox(width: 8),

            // Label Text (Shows active timer when recording, 'REC' when standby)
            Text(
              widget.isRecording ? _formattedTime : "REC",
              style: TextStyle(
                color: widget.isRecording ? Colors.white : Colors.white70,
                fontSize: 12,
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
