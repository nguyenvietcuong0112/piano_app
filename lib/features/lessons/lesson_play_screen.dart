import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:project_flutter/core/audio_engine.dart';
import 'package:project_flutter/core/theme_service.dart';
import 'package:project_flutter/features/piano/piano_view.dart';
import 'package:project_flutter/features/piano/record_button.dart';
import 'lesson_datasource.dart';
import 'lesson_model.dart';

class LessonPlayScreen extends ConsumerStatefulWidget {
  final LessonsItem lesson;

  const LessonPlayScreen({super.key, required this.lesson});

  @override
  ConsumerState<LessonPlayScreen> createState() => _LessonPlayScreenState();
}

class _LessonPlayScreenState extends ConsumerState<LessonPlayScreen> {
  final GlobalKey<PianoViewState> _pianoKey = GlobalKey<PianoViewState>();
  List<LessonNote> _noteList = [];
  int _currentNoteIndex = 0;
  int _score = 0;
  bool _isPlaying = false;
  bool _isRecording = false;
  double _noteSpeedMultiplier = 1.0;
  Timer? _noteTimer;

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
    final notes = await ds.getLessonNotes(widget.lesson.lessonsData);
    setState(() {
      _noteList = notes;
    });
  }

  void _startFallingNotesSequence() {
    _noteTimer?.cancel();
    if (_currentNoteIndex >= _noteList.length) {
      _currentNoteIndex = 0;
    }
    _scheduleNextNote();
  }

  void _scheduleNextNote() {
    if (!_isPlaying || _currentNoteIndex >= _noteList.length) return;

    final targetNote = _noteList[_currentNoteIndex];
    final keyPrefix = targetNote.type == 0 ? "w" : "b";
    final targetKeyName =
        "$keyPrefix${targetNote.group}${targetNote.position}";
    final label = "${targetNote.group}${targetNote.position}";

    _pianoKey.currentState
        ?.addFallingNote(targetKeyName, label, targetNote.type == 1);

    setState(() {
      _currentNoteIndex++;
    });

    if (_currentNoteIndex < _noteList.length) {
      int delayMs =
          (targetNote.breakTime * 1.35 / _noteSpeedMultiplier).round().clamp(180, 3000);
      _noteTimer = Timer(Duration(milliseconds: delayMs), _scheduleNextNote);
    } else {
      _finishLesson();
    }
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
    });
    if (_isPlaying) {
      _startFallingNotesSequence();
    } else {
      _noteTimer?.cancel();
    }
  }

  void _finishLesson() {
    _noteTimer?.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                bool hasStar = index < 4;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Image.asset(
                    hasStar
                        ? 'assets/icons/ic_star_finish_lesson.png'
                        : 'assets/icons/ic_non_star_finish_lesson.png',
                    width: 36,
                    height: 36,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.star,
                      color: hasStar ? Colors.amber : Colors.grey,
                      size: 32,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            Text(
              "🎉 Completed ${widget.lesson.titleName}!",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Your Practice Score:",
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              "$_score Pts",
              style: const TextStyle(
                color: Colors.greenAccent,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                child: Text(
                  "DONE",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
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
    int totalNotes = _noteList.length;
    double progress = totalNotes > 0 ? (_currentNoteIndex / totalNotes) : 0.0;
    int elapsedSec = (_currentNoteIndex * 0.5).toInt();
    String elapsedStr =
        "${(elapsedSec ~/ 60).toString().padLeft(2, '0')}:${(elapsedSec % 60).toString().padLeft(2, '0')}";

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
                    child: Image.asset(
                      'assets/images/$themeRes.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/$themeRes.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, err, stack) =>
                            Container(color: const Color(0xFF121212)),
                      ),
                    ),
                  ),
                );
              },
            ),

            Column(
              children: [
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  color: Colors.black87,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Image.asset(
                          'assets/icons/ic_back.png',
                          width: 36,
                          height: 32,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(width: 8),

                      Container(
                        width: 140,
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A3D),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/icons/ic_music.png',
                              width: 16,
                              height: 16,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.music_note,
                                      color: Colors.amber, size: 16),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                widget.lesson.titleName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),

                      Text(
                        elapsedStr,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                      ),

                      Expanded(
                        child: SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6),
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
                        widget.lesson.duration,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 11),
                      ),
                      const SizedBox(width: 8),

                      RecordButton(
                        isRecording: _isRecording,
                        onTap: () {
                          setState(() {
                            _isRecording = !_isRecording;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(_isRecording
                                  ? "🔴 Recording Started"
                                  : "Saved Recording"),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 6),

                      Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF252533),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<double>(
                            value: _noteSpeedMultiplier,
                            dropdownColor: const Color(0xFF1E1E2C),
                            icon: const Icon(Icons.speed,
                                color: Colors.amber, size: 16),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            items: const [
                              DropdownMenuItem(
                                  value: 0.5, child: Text("0.5x Slow")),
                              DropdownMenuItem(
                                  value: 0.75, child: Text("0.75x Practice")),
                              DropdownMenuItem(
                                  value: 1.0, child: Text("1.0x Normal")),
                              DropdownMenuItem(
                                  value: 1.5, child: Text("1.5x Fast")),
                              DropdownMenuItem(
                                  value: 2.0, child: Text("2.0x Turbo")),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _noteSpeedMultiplier = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          _isPlaying
                              ? Icons.pause_circle_filled
                              : Icons.play_circle_filled,
                          color: Colors.amber,
                          size: 32,
                        ),
                        onPressed: _togglePlayback,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PianoView(
                    key: _pianoKey,
                    startOctave: 4,
                    visibleWhiteKeysCount: 14,
                    showNoteNames: true,
                    isLessonMode: true,
                    noteSpeed: 7.5 * _noteSpeedMultiplier,
                    onNotePressed: (keyName, label) {
                      setState(() {
                        _score += 10;
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
