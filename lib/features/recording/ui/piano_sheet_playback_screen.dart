import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/audio_engine.dart';
import '../../../core/services/recording_storage_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/gradient_border_card.dart';
import '../../piano/ui/piano_view.dart';

class PianoSheetPlaybackScreen extends StatefulWidget {
  final RecordingItemModel item;

  const PianoSheetPlaybackScreen({
    super.key,
    required this.item,
  });

  @override
  State<PianoSheetPlaybackScreen> createState() =>
      _PianoSheetPlaybackScreenState();
}

class _PianoSheetPlaybackScreenState extends State<PianoSheetPlaybackScreen> {
  Timer? _playbackTimer;
  int _currentMs = 0;
  int _totalMs = 10000; // Default 10s if empty
  bool _isPlaying = false;

  final Set<String> _activeKeys = {};
  final Map<String, Timer> _activeKeyTimers = {};
  int _nextNoteIndex = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _calculateTotalDuration();
    _startPlayback();
  }

  void _calculateTotalDuration() {
    if (widget.item.noteEvents != null && widget.item.noteEvents!.isNotEmpty) {
      final lastEvent = widget.item.noteEvents!.last;
      _totalMs = lastEvent.timestampMs + lastEvent.durationMs + 1000;
    }
  }

  @override
  void dispose() {
    _stopPlaybackTimer();
    _clearActiveKeys();
    AudioEngine().stopAllNotes();
    super.dispose();
  }

  void _clearActiveKeys() {
    for (var timer in _activeKeyTimers.values) {
      timer.cancel();
    }
    _activeKeyTimers.clear();
    _activeKeys.clear();
  }

  void _startPlayback() {
    _stopPlaybackTimer();
    setState(() => _isPlaying = true);

    _playbackTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (!mounted) return;

      setState(() {
        _currentMs += 30;
      });

      _processScheduledNotes();

      if (_currentMs >= _totalMs) {
        _pausePlayback();
      }
    });
  }

  void _pausePlayback() {
    _stopPlaybackTimer();
    setState(() => _isPlaying = false);
    AudioEngine().stopAllNotes();
  }

  void _stopPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }

  void _restartPlayback() {
    _pausePlayback();
    _clearActiveKeys();
    setState(() {
      _currentMs = 0;
      _nextNoteIndex = 0;
    });
    _startPlayback();
  }

  void _processScheduledNotes() {
    final events = widget.item.noteEvents;
    if (events == null || events.isEmpty) return;

    while (_nextNoteIndex < events.length) {
      final event = events[_nextNoteIndex];
      if (event.timestampMs <= _currentMs) {
        _triggerNoteEvent(event);
        _nextNoteIndex++;
      } else {
        break;
      }
    }
  }

  void _triggerNoteEvent(RecordedNoteEvent event) {
    AudioEngine().playNote(event.keyName);

    setState(() {
      _activeKeys.add(event.keyName);
    });

    _activeKeyTimers[event.keyName]?.cancel();
    _activeKeyTimers[event.keyName] =
        Timer(Duration(milliseconds: event.durationMs), () {
      if (mounted) {
        setState(() {
          _activeKeys.remove(event.keyName);
        });
      }
    });
  }

  String _formatTime(int ms) {
    int totalSec = (ms / 1000).round();
    int min = totalSec ~/ 60;
    int sec = totalSec % 60;
    return "${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    double progress = (_totalMs > 0) ? (_currentMs / _totalMs).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFF101014),
      body: SafeArea(
        child: Column(
          children: [
            // Top Toolbar Bar
            Container(
              width: double.infinity,
              height: 70.h,
              color: const Color(0xFF14141A),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: SvgPicture.asset(
                      'assets/icons/ic_back_home.svg',
                      width: 44.w,
                      height: 34.h,
                      errorBuilder: (context, error, stackTrace) => Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Title Card
                  GradientBorderCard(
                    height: 36.h,
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    backgroundGradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF141126), Color(0xFF0F0F1E)],
                    ),
                    borderRadius: 8,
                    borderGradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.1),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/icons/ic_music.svg',
                            width: 20.h,
                            height: 20.h,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            widget.item.title,
                            style: AppTextStyles.textWhite12.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // Controls: Play / Pause Button
                  GestureDetector(
                    onTap: () {
                      if (_isPlaying) {
                        _pausePlayback();
                      } else {
                        _startPlayback();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFCF6BEE),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 22.r,
                      ),
                    ),
                  ),

                  SizedBox(width: 10.w),

                  // Replay Button
                  GestureDetector(
                    onTap: _restartPlayback,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.replay_rounded,
                        color: Colors.white70,
                        size: 20.r,
                      ),
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // Progress Bar & Time Display
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          _formatTime(_currentMs),
                          style: AppTextStyles.textWhite12.copyWith(
                            fontSize: 11.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4.r),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white.withValues(alpha: 0.15),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFCF6BEE),
                              ),
                              minHeight: 6.h,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _formatTime(_totalMs),
                          style: AppTextStyles.textWhite12.copyWith(
                            fontSize: 11.sp,
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Interactive Piano View (Plays back recorded notes)
            Expanded(
              child: PianoView(
                startOctave: 3,
                visibleWhiteKeysCount: 14,
                showNoteNames: true,
                isLessonMode: false,
                externalActiveKeys: _activeKeys,
                onNotePressed: (keyName, label) {
                  AudioEngine().playNote(keyName);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
