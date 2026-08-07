import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/services/audio_engine.dart';
import '../../../core/services/audio_recorder_service.dart';
import '../../../core/services/recording_storage_service.dart';
import '../../../core/services/shared_preference_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_service.dart';
import '../../../core/widgets/exit_confirmation_dialog.dart';
import '../../../core/widgets/gradient_border_card.dart';
import '../../../core/widgets/gradient_slider_track_shape.dart';
import '../../../core/widgets/theme_image.dart';
import '../../../core/widgets/record_button.dart';
import '../../../core/widgets/recording_dialogs.dart';
import '../../piano/ui/piano_view.dart';
import '../data/lesson_datasource.dart';
import '../domain/lesson_model.dart';
import '../controller/lesson_play_controller.dart';
import 'lesson_result_dialog.dart';
import 'speed_controller_dialog.dart';

class LessonPlayScreen extends ConsumerStatefulWidget {
  final LessonsItem lesson;

  const LessonPlayScreen({super.key, required this.lesson});

  @override
  ConsumerState<LessonPlayScreen> createState() => _LessonPlayScreenState();
}

class _LessonPlayScreenState extends ConsumerState<LessonPlayScreen> {
  final GlobalKey<PianoViewState> _pianoKey = GlobalKey<PianoViewState>();
  LessonNoteContainer? _lessonContainer;
  List<LessonNote> _noteList = [];
  Timer? _noteTimer;
  Timer? _playbackTickerTimer;
  double _elapsedTimeSeconds = 0.0;
  double _totalDurationSeconds = 180.0;
  bool _isAutoGuideMode = false;
  int _countdownValue = 0;

  @override
  void initState() {
    super.initState();
    AudioEngine().loadInstrument("bright");
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _loadLessonNotes();
  }

  Future<void> _loadLessonNotes() async {
    final ds = LessonDataSource();
    final container = await ds.getLessonContainer(widget.lesson.lessonsData);
    if (mounted) {
      if (container != null) {
        setState(() {
          _lessonContainer = container;
          _noteList = container.data ?? [];
          _totalDurationSeconds = _calculateTotalSongDuration();
        });
      } else {
        final notes = await ds.getLessonNotes(widget.lesson.lessonsData);
        setState(() {
          _noteList = notes;
          _totalDurationSeconds = _calculateTotalSongDuration();
        });
      }
      ref
          .read(lessonPlayControllerProvider.notifier)
          .initSong(_noteList.length);
    }
  }

  double _calculateTotalSongDuration() {
    int parsedMetaSec = 180;
    final parts = widget.lesson.duration.split(':');
    if (parts.length == 2) {
      parsedMetaSec =
          (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
    }

    if (_noteList.isNotEmpty) {
      int totalNoteMs = 0;
      for (var n in _noteList) {
        totalNoteMs += n.breakTime;
      }
      int lastNoteMs = _noteList.last.duration;
      // 2000ms is the falling duration from top screen to keyboard
      double calcSec = (totalNoteMs + lastNoteMs + 2000) / 1000.0;
      if (calcSec > 5) {
        return calcSec;
      }
    }
    return parsedMetaSec > 0 ? parsedMetaSec.toDouble() : 180.0;
  }

  void _startPlaybackTicker() {
    _playbackTickerTimer?.cancel();
    _playbackTickerTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      final state = ref.read(lessonPlayControllerProvider);
      if (!state.isPlaying || state.isPaused) return;

      if (mounted) {
        setState(() {
          _elapsedTimeSeconds += 0.1 * state.noteSpeedMultiplier;
          if (_elapsedTimeSeconds > _totalDurationSeconds) {
            _elapsedTimeSeconds = _totalDurationSeconds;
          }
        });
      }
    });
  }

  void _stopPlaybackTicker() {
    _playbackTickerTimer?.cancel();
  }

  void _startFallingNotesSequence() {
    _noteTimer?.cancel();
    final controller = ref.read(lessonPlayControllerProvider.notifier);
    final state = ref.read(lessonPlayControllerProvider);

    if (state.currentNoteIndex >= _noteList.length) {
      controller.resetNoteIndex();
      setState(() {
        _elapsedTimeSeconds = 0.0;
      });
    }
    _startPlaybackTicker();
    _scheduleNextNote();
  }

  void _scheduleNextNote() {
    final controller = ref.read(lessonPlayControllerProvider.notifier);
    final state = ref.read(lessonPlayControllerProvider);

    if (!state.isPlaying ||
        state.isPaused ||
        state.currentNoteIndex >= _noteList.length)
      return;

    int currentIndex = state.currentNoteIndex;
    int nextDelayMs = 0;

    while (currentIndex < _noteList.length) {
      final targetNote = _noteList[currentIndex];
      final keyPrefix = targetNote.type == 0 ? "w" : "b";
      final targetKeyName =
          "$keyPrefix${targetNote.group}${targetNote.position}";
      final label = "${targetNote.group}${targetNote.position}";

      _pianoKey.currentState?.addFallingNote(
        targetKeyName,
        label,
        targetNote.type == 1,
        durationMs: targetNote.duration,
      );

      currentIndex++;
      controller.incrementNoteIndex();
      nextDelayMs = targetNote.breakTime;

      if (nextDelayMs > 0) {
        break; // Wait for break delay
      }
    }

    if (currentIndex < _noteList.length) {
      int delayMs = (nextDelayMs / state.noteSpeedMultiplier).round().clamp(
        20,
        5000,
      );
      _noteTimer = Timer(Duration(milliseconds: delayMs), _scheduleNextNote);
    } else {
      // Synchronize: Wait until the last spawned note travels down screen to keybed & finishes audio!
      int lastNoteDuration = _noteList.isNotEmpty
          ? _noteList.last.duration
          : 500;
      int finishDelayMs =
          ((2200 + lastNoteDuration) / state.noteSpeedMultiplier).round();
      _noteTimer = Timer(Duration(milliseconds: finishDelayMs), () {
        _finishLesson();
      });
    }
  }

  void _togglePlayback() {
    final controller = ref.read(lessonPlayControllerProvider.notifier);
    final state = ref.read(lessonPlayControllerProvider);

    if (state.isPlaying) {
      _pauseGame();
    } else {
      controller.setPaused(false);
      controller.setPlayback(true);
      _startFallingNotesSequence();
      _startPlaybackTicker();
    }
  }

  void _pauseGame() {
    final controller = ref.read(lessonPlayControllerProvider.notifier);
    controller.setPaused(true);
    controller.setPlayback(false);
    _noteTimer?.cancel();
    _stopPlaybackTicker();
  }

  Future<void> _finishLesson() async {
    _noteTimer?.cancel();
    _stopPlaybackTicker();
    if (mounted) {
      setState(() {
        _elapsedTimeSeconds = _totalDurationSeconds;
      });
    }

    final state = ref.read(lessonPlayControllerProvider);
    if (state.isRecording) {
      await _stopRecordingAndPromptSave();
    }

    final lessonIdStr = widget.lesson.id.toString();

    // Save high score / stars & completed song record
    await SharedPreferenceService.saveLessonStars(lessonIdStr, state.stars);
    await SharedPreferenceService.saveCompletedSongRecord(
      songId: lessonIdStr,
      titleName: widget.lesson.titleName,
      authorName: widget.lesson.authorName,
      duration: widget.lesson.duration,
      lessonsData: widget.lesson.lessonsData,
      level: widget.lesson.level,
      stars: state.stars,
      score: state.score,
      accuracy: state.accuracy,
    );

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LessonResultDialog(
        state: state,
        songTitle: widget.lesson.titleName,
        onReplay: () {
          ref.read(lessonPlayControllerProvider.notifier).resetNoteIndex();
          _pianoKey.currentState?.clearFallingNotes();
          if (mounted) {
            setState(() {
              _elapsedTimeSeconds = 0.0;
            });
          }
          _startFallingNotesSequence();
        },
      ),
    );
  }

  Future<void> _stopRecordingAndPromptSave() async {
    final controller = ref.read(lessonPlayControllerProvider.notifier);
    final state = ref.read(lessonPlayControllerProvider);
    final recorder = AudioRecorderService();

    if (!state.isRecording) return;
    controller.toggleRecording();

    final item = await recorder.stopRecording(title: widget.lesson.titleName);

    if (!mounted) return;

    final now = DateTime.now();
    final dateStr =
        "${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}";
    final timeStr = now.millisecondsSinceEpoch.toString().substring(5);
    final defaultTitle = "Record_$timeStr";

    final savedTitle = await RecordSaveDialog.show(
      context,
      defaultTitle: defaultTitle,
    );

    if (savedTitle != null && savedTitle.isNotEmpty && item != null) {
      final minutes = (_elapsedTimeSeconds ~/ 60).toString().padLeft(2, '0');
      final seconds = (_elapsedTimeSeconds % 60).toString().padLeft(2, '0');
      final durationStr = "$minutes:$seconds";

      final newItem = RecordingItemModel(
        id: item.id,
        title: savedTitle,
        date: dateStr,
        duration: durationStr == "00:00" ? "00:07" : durationStr,
        filePath: item.filePath,
      );

      await RecordingStorageService.addRecording(newItem);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF7E48F0),
            content: Text("✅ ${context.tr('saved_recording')} $savedTitle"),
          ),
        );
      }
    } else {
      if (item != null) {
        final f = File(item.filePath);
        if (await f.exists()) await f.delete();
      }
    }
  }

  void _handleRecordTap() async {
    final controller = ref.read(lessonPlayControllerProvider.notifier);
    final state = ref.read(lessonPlayControllerProvider);
    final recorder = AudioRecorderService();

    if (state.isRecording) {
      await _stopRecordingAndPromptSave();
    } else {
      final selectedMode = await RecordSelectionDialog.show(context);
      if (selectedMode != null) {
        bool success = await recorder.startRecording(
          mode: selectedMode,
          songTitle: widget.lesson.titleName,
        );
        if (success) {
          controller.toggleRecording();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("⚠️ ${context.tr('mic_permission_required')}"),
            ),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _stopPlaybackTicker();
    AudioEngine().stopAllNotes();
    _noteTimer?.cancel();
    super.dispose();
  }

  Future<void> _exitScreen() async {
    final shouldExit = await ExitConfirmationDialog.show(
      context,
      title: context.tr('quit_lesson_title'),
      message: context.tr('quit_lesson_msg'),
      confirmText: context.tr('quit'),
      cancelText: context.tr('stay'),
    );
    if (shouldExit && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonState = ref.watch(lessonPlayControllerProvider);
    final controller = ref.read(lessonPlayControllerProvider.notifier);

    double progress = _totalDurationSeconds > 0
        ? (_elapsedTimeSeconds / _totalDurationSeconds).clamp(0.0, 1.0)
        : 0.0;
    int currentSec = _elapsedTimeSeconds.toInt();
    String elapsedStr =
        "${(currentSec ~/ 60).toString().padLeft(2, '0')}:${(currentSec % 60).toString().padLeft(2, '0')}";
    int totalDurSec = _totalDurationSeconds.toInt();
    String totalDurationStr =
        "${(totalDurSec ~/ 60).toString().padLeft(2, '0')}:${(totalDurSec % 60).toString().padLeft(2, '0')}";

    int startOctave =
        _lessonContainer?.startOctave ?? widget.lesson.startOctave;
    int currentEffectiveOctave = (startOctave + lessonState.octaveShift).clamp(
      1,
      7,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _exitScreen();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        body: SafeArea(
          child: Stack(
            children: [
              ValueListenableBuilder<String>(
                valueListenable: ThemeService.currentThemeRes,
                builder: (context, themeRes, child) {
                  return Positioned.fill(
                    child: Opacity(
                      opacity: 0.95,
                      child: ThemeImage(resName: themeRes),
                    ),
                  );
                },
              ),
              Column(
                children: [
                  // Toolbar Header
                  Container(
                    width: double.infinity,
                    height: 100.r, 
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: const Color(0xFF14141A),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: _exitScreen,
                            child: SvgPicture.asset(
                              'assets/icons/ic_back_home.svg',
                              width: 48.w,
                              height: 36.h,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Title Chip
                          GradientBorderCard(
                            height: 36.h,
                            width: 50.w,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                                const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                              ],
                            ),
                            child: Center(
                              child: Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/ic_music.svg',
                                    width: 24.h,
                                    height: 24.h,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      widget.lesson.titleName,
                                      style: AppTextStyles.textWhite12.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Player Controls & Progress Card (Combined)
                          GradientBorderCard(
                            height: 64.h,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                                const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Play / Pause Icon inside Chip
                                GestureDetector(
                                  onTap: _togglePlayback,
                                  child: Icon(
                                    lessonState.isPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 8),

                                SizedBox(
                                  width: 36,
                                  child: Text(
                                    elapsedStr,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.textWhite12.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),

                                SizedBox(
                                  width: 100.w,
                                  child: SliderTheme(
                                    data: SliderTheme.of(context).copyWith(
                                      trackHeight: 3,
                                      trackShape:
                                          const GradientSliderTrackShape(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFFCF6BEE),
                                                Color(0xFF7A44DA),
                                              ],
                                            ),
                                          ),
                                      thumbColor: Colors.white,
                                      thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 5,
                                      ),
                                      inactiveTrackColor: Colors.white24,
                                    ),
                                    child: Slider(
                                      value: progress.clamp(0.0, 1.0),
                                      onChanged: (val) {},
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),

                                SizedBox(
                                  width: 36,
                                  child: Text(
                                    totalDurationStr,
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.textWhite12.copyWith(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => context.push('/recordings'),
                            child: SvgPicture.asset(
                              'assets/icons/ic_list_records.svg',
                              width: 48.h,
                              height: 36.h,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Record Button
                          RecordButton(
                            isRecording: lessonState.isRecording,
                            onTap: _handleRecordTap,
                          ),
                          const SizedBox(width: 12),

                          // Octave Shift Control (- / +)
                          GradientBorderCard(
                            height: 36.h,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
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
                                const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                                const Color(0xFFFFFFFF).withValues(alpha: 0.1),
                              ],
                            ),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () => controller.setOctaveShift(
                                    lessonState.octaveShift - 1,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                  ),
                                ),
                                Text(
                                  "C$currentEffectiveOctave",
                                  style: AppTextStyles.textWhite12.copyWith(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                InkWell(
                                  onTap: () => controller.setOctaveShift(
                                    lessonState.octaveShift + 1,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white70,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Speed Multiplier (Triggers SpeedControllerDialog)
                          GestureDetector(
                            onTap: () {
                              SpeedControllerDialog.show(
                                context: context,
                                initialSpeed: lessonState.noteSpeedMultiplier,
                                onSpeedChanged: (speed) {
                                  controller.setSpeedMultiplier(speed);
                                },
                              );
                            },
                            child: SvgPicture.asset(
                              'assets/icons/ic_speed.svg',
                              width: 48.h,
                              height: 36.h,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Piano Game Area
                  Expanded(
                    child: PianoView(
                      key: _pianoKey,
                      startOctave: startOctave,
                      octaveShift: lessonState.octaveShift,
                      startKeyPosition:
                          _lessonContainer?.startKeyPosition ??
                          widget.lesson.startKeyPosition,
                      visibleWhiteKeysCount:
                          _lessonContainer?.visibleWhiteKeysCount ??
                          widget.lesson.visibleWhiteKeysCount,
                      showNoteNames: lessonState.noteLabelMode != 'off',
                      noteLabelMode: lessonState.noteLabelMode,
                      isLessonMode: true,
                      isAutoGuideMode: _isAutoGuideMode,
                      noteSpeed: 3.2 * lessonState.noteSpeedMultiplier,
                      onNoteHit: (keyName, isPerfect) {
                        controller.recordHit(isPerfect: isPerfect);
                      },
                      onNoteMissed: () {
                        controller.recordMiss();
                      },
                    ),
                  ),
                ],
              ),

              // Countdown Overlay
              if (_countdownValue > 0)
                Positioned.fill(
                  child: Container(
                    color: Colors.black87,
                    child: Center(
                      child: Text(
                        "$_countdownValue",
                        style: AppTextStyles.textWhite22.copyWith(
                          color: Colors.amberAccent,
                          fontSize: 90,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
