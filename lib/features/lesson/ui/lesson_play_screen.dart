import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/audio_engine.dart';
import '../../../core/services/audio_recorder_service.dart';
import '../../../core/services/shared_preference_service.dart';
import '../../../core/theme/theme_service.dart';
import '../../../core/widgets/theme_image.dart';
import '../../../core/widgets/record_button.dart';
import '../../piano/ui/piano_view.dart';
import '../data/lesson_datasource.dart';
import '../domain/lesson_model.dart';
import '../controller/lesson_play_controller.dart';
import 'lesson_result_dialog.dart';

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
      ref.read(lessonPlayControllerProvider.notifier).initSong(_noteList.length);
    }
  }

  double _calculateTotalSongDuration() {
    int parsedMetaSec = 180;
    final parts = widget.lesson.duration.split(':');
    if (parts.length == 2) {
      parsedMetaSec = (int.tryParse(parts[0]) ?? 0) * 60 + (int.tryParse(parts[1]) ?? 0);
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
    _playbackTickerTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
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

    if (!state.isPlaying || state.isPaused || state.currentNoteIndex >= _noteList.length) return;

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
      int delayMs =
          (nextDelayMs / state.noteSpeedMultiplier).round().clamp(20, 5000);
      _noteTimer = Timer(Duration(milliseconds: delayMs), _scheduleNextNote);
    } else {
      // Synchronize: Wait until the last spawned note travels down screen to keybed & finishes audio!
      int lastNoteDuration = _noteList.isNotEmpty ? _noteList.last.duration : 500;
      int finishDelayMs = ((2200 + lastNoteDuration) / state.noteSpeedMultiplier).round();
      _noteTimer = Timer(Duration(milliseconds: finishDelayMs), () {
        _finishLesson();
      });
    }
  }

  void _togglePlayback() {
    final controller = ref.read(lessonPlayControllerProvider.notifier);
    final state = ref.read(lessonPlayControllerProvider);

    if (state.isPaused) {
      _resumeWithCountdown();
      return;
    }

    controller.togglePlayback();
    final isPlaying = ref.read(lessonPlayControllerProvider).isPlaying;

    if (isPlaying) {
      _startFallingNotesSequence();
    } else {
      _noteTimer?.cancel();
    }
  }

  void _pauseGame() {
    final controller = ref.read(lessonPlayControllerProvider.notifier);
    controller.setPaused(true);
    _noteTimer?.cancel();
    _showPauseOverlay();
  }

  void _resumeWithCountdown() {
    setState(() {
      _countdownValue = 3;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdownValue > 1) {
        setState(() {
          _countdownValue--;
        });
      } else {
        timer.cancel();
        setState(() {
          _countdownValue = 0;
        });
        final controller = ref.read(lessonPlayControllerProvider.notifier);
        controller.setPaused(false);
        controller.setPlayback(true);
        _startFallingNotesSequence();
      }
    });
  }

  void _showPauseOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pause_circle_filled, color: Colors.amber, size: 28),
            SizedBox(width: 8),
            Text(
              "TẠM DỪNG LESSON",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.lesson.titleName,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                _resumeWithCountdown();
              },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text("Tiếp tục (Resume)", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white30),
                minimumSize: const Size.fromHeight(44),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                ref.read(lessonPlayControllerProvider.notifier).resetNoteIndex();
                _pianoKey.currentState?.clearFallingNotes();
                _startFallingNotesSequence();
              },
              icon: const Icon(Icons.replay_rounded),
              label: const Text("Chơi lại từ đầu"),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: Colors.redAccent,
                minimumSize: const Size.fromHeight(44),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                context.pop();
              },
              icon: const Icon(Icons.exit_to_app_rounded),
              label: const Text("Thoát bài học"),
            ),
          ],
        ),
      ),
    );
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

  void _handleRecordTap() async {
    final controller = ref.read(lessonPlayControllerProvider.notifier);
    final state = ref.read(lessonPlayControllerProvider);
    final recorder = AudioRecorderService();

    if (state.isRecording) {
      controller.toggleRecording();
      final item = await recorder.stopRecording(title: widget.lesson.titleName);
      if (mounted && item != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green.shade800,
            content: Text("✅ Đã lưu bản ghi: ${item.title}"),
          ),
        );
      }
    } else {
      // Show mode selector dialog
      showModalBottomSheet(
        context: context,
        backgroundColor: const Color(0xFF1E1E2C),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "CHỌN CHẾ ĐỘ THU ÂM",
                style: TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.piano, color: Colors.cyanAccent),
                title: const Text("Internal Audio Synth (Âm sạch 100%)", style: TextStyle(color: Colors.white)),
                subtitle: const Text("Thu trực tiếp âm thanh tiếng đàn từ App", style: TextStyle(color: Colors.white54, fontSize: 12)),
                onTap: () async {
                  Navigator.pop(context);
                  bool success = await recorder.startRecording(mode: RecordingMode.internal, songTitle: widget.lesson.titleName);
                  if (success) {
                    controller.toggleRecording();
                  }
                },
              ),
              const Divider(color: Colors.white10),
              ListTile(
                leading: const Icon(Icons.mic, color: Colors.orangeAccent),
                title: const Text("Microphone Audio (Kèm tiếng ngoài)", style: TextStyle(color: Colors.white)),
                subtitle: const Text("Thu tiếng đàn kết hợp mic ngoài", style: TextStyle(color: Colors.white54, fontSize: 12)),
                onTap: () async {
                  Navigator.pop(context);
                  bool success = await recorder.startRecording(mode: RecordingMode.mic, songTitle: widget.lesson.titleName);
                  if (success) {
                    controller.toggleRecording();
                  } else if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("⚠️ Chưa được cấp quyền Microphone")),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _stopPlaybackTicker();
    AudioEngine().stopAllNotes();
    _noteTimer?.cancel();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lessonState = ref.watch(lessonPlayControllerProvider);
    final controller = ref.read(lessonPlayControllerProvider.notifier);

    double progress = _totalDurationSeconds > 0 ? (_elapsedTimeSeconds / _totalDurationSeconds).clamp(0.0, 1.0) : 0.0;
    int currentSec = _elapsedTimeSeconds.toInt();
    String elapsedStr =
        "${(currentSec ~/ 60).toString().padLeft(2, '0')}:${(currentSec % 60).toString().padLeft(2, '0')}";
    int totalDurSec = _totalDurationSeconds.toInt();
    String totalDurationStr =
        "${(totalDurSec ~/ 60).toString().padLeft(2, '0')}:${(totalDurSec % 60).toString().padLeft(2, '0')}";

    int startOctave = _lessonContainer?.startOctave ?? widget.lesson.startOctave;
    int currentEffectiveOctave = (startOctave + lessonState.octaveShift).clamp(1, 7);

    return Scaffold(
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
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  color: Colors.black87,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Image.asset(
                            'assets/icons/ic_back_home.png',
                            width: 32,
                            height: 30,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Title Chip
                        Container(
                          width: 130,
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A3D),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/icons/ic_music.png',
                                width: 14,
                                height: 14,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.music_note, color: Colors.amber, size: 14),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  widget.lesson.titleName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        Text(
                          elapsedStr,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),

                        SizedBox(
                          width: 100,
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                            ),
                            child: Slider(
                              value: progress.clamp(0.0, 1.0),
                              activeColor: Colors.amber,
                              inactiveColor: Colors.white24,
                              onChanged: (val) {},
                            ),
                          ),
                        ),

                        Text(
                          totalDurationStr,
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        const SizedBox(width: 6),

                        // Record Button
                        RecordButton(
                          isRecording: lessonState.isRecording,
                          onTap: _handleRecordTap,
                        ),
                        const SizedBox(width: 6),

                        // Octave Shift Control (- / +)
                        Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF252533),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => controller.setOctaveShift(lessonState.octaveShift - 1),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(Icons.remove, color: Colors.white70, size: 16),
                                ),
                              ),
                              Text(
                                "C$currentEffectiveOctave",
                                style: const TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              InkWell(
                                onTap: () => controller.setOctaveShift(lessonState.octaveShift + 1),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(Icons.add, color: Colors.white70, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Note Label Mode Toggle Button
                        InkWell(
                          onTap: () {
                            String nextMode = 'scientific';
                            if (lessonState.noteLabelMode == 'scientific') {
                              nextMode = 'solfege';
                            } else if (lessonState.noteLabelMode == 'solfege') {
                              nextMode = 'off';
                            }
                            controller.setNoteLabelMode(nextMode);
                          },
                          child: Container(
                            height: 30,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF252533),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Center(
                              child: Text(
                                lessonState.noteLabelMode == 'solfege'
                                    ? "DoReMi"
                                    : lessonState.noteLabelMode == 'scientific'
                                        ? "C D E"
                                        : "Off",
                                style: const TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Speed Multiplier
                        Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF252533),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<double>(
                              value: lessonState.noteSpeedMultiplier,
                              dropdownColor: const Color(0xFF1E1E2C),
                              icon: const Icon(Icons.speed, color: Colors.amber, size: 14),
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              items: const [
                                DropdownMenuItem(value: 0.25, child: Text("0.25x")),
                                DropdownMenuItem(value: 0.5, child: Text("0.5x")),
                                DropdownMenuItem(value: 1.0, child: Text("1.0x")),
                                DropdownMenuItem(value: 1.5, child: Text("1.5x")),
                                DropdownMenuItem(value: 2.0, child: Text("2.0x")),
                              ],
                              onChanged: (val) {
                                if (val != null) controller.setSpeedMultiplier(val);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // Play/Pause Control
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: Icon(
                            lessonState.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                            color: Colors.amber,
                            size: 32,
                          ),
                          onPressed: () {
                            if (lessonState.isPlaying) {
                              _pauseGame();
                            } else {
                              _togglePlayback();
                            }
                          },
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
                    startKeyPosition: _lessonContainer?.startKeyPosition ?? widget.lesson.startKeyPosition,
                    visibleWhiteKeysCount: _lessonContainer?.visibleWhiteKeysCount ?? widget.lesson.visibleWhiteKeysCount,
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
                      style: const TextStyle(
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
    );
  }
}

