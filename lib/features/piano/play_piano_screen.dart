import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import 'package:go_router/go_router.dart';

import 'package:project_flutter/core/audio_engine.dart';
import 'package:project_flutter/core/theme_service.dart';
import 'package:project_flutter/features/lessons/lesson_model.dart';
import 'piano_provider.dart';
import 'piano_view.dart';
import 'mini_piano_overview.dart';
import 'record_button.dart';

class PlayPianoScreen extends ConsumerStatefulWidget {
  const PlayPianoScreen({super.key});

  @override
  ConsumerState<PlayPianoScreen> createState() => _PlayPianoScreenState();
}

class _PlayPianoScreenState extends ConsumerState<PlayPianoScreen> {
  int currentOctave = 3;
  int visibleWhiteKeysCount = 14;
  bool showNoteNames = true;
  String statusMessage = "";

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    final preset = ref.read(pianoSettingsProvider).soundPreset;
    AudioEngine().loadInstrument(preset);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    AudioEngine().stopAllNotes();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitUp,
    ]);
    _audioRecorder.dispose();
    super.dispose();
  }

  void _toggleRecording() async {
    try {
      if (isRecording) {
        final path = await _audioRecorder.stop();
        setState(() {
          isRecording = false;
          statusMessage = "Saved: ${path?.split('/').last ?? 'Record'}";
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Saved: $path")),
          );
        }
      } else {
        if (await _audioRecorder.hasPermission()) {
          final dir = await getApplicationDocumentsDirectory();
          final path =
              '${dir.path}/PianoRecord_${DateTime.now().millisecondsSinceEpoch}.m4a';

          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: path,
          );

          setState(() {
            isRecording = true;
            statusMessage = "🔴 Recording...";
          });
        }
      }
    } catch (e) {
      debugPrint("Recording error: $e");
    }
  }

  void _zoomIn() {
    setState(() {
      visibleWhiteKeysCount = (visibleWhiteKeysCount - 2).clamp(8, 24);
    });
  }

  void _zoomOut() {
    setState(() {
      visibleWhiteKeysCount = (visibleWhiteKeysCount + 2).clamp(8, 24);
    });
  }

  void _volumeUp() async {
    await AudioEngine().volumeUp();
    ref.read(pianoSettingsProvider.notifier).setVolume(AudioEngine().volume);
    int percent = (AudioEngine().volume * 100).round();
    setState(() {
      statusMessage = "🔊 Volume: $percent%";
    });
  }

  void _volumeDown() async {
    await AudioEngine().volumeDown();
    ref.read(pianoSettingsProvider.notifier).setVolume(AudioEngine().volume);
    int percent = (AudioEngine().volume * 100).round();
    setState(() {
      statusMessage = "🔉 Volume: $percent%";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF101014),
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
                            Container(color: const Color(0xFF181820)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  color: const Color(0xFF14141A),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Image.asset(
                          'assets/icons/ic_home.png',
                          width: 34,
                          height: 30,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.home, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 4),

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showNoteNames = !showNoteNames;
                            statusMessage = showNoteNames
                                ? "Notes: ON"
                                : "Notes: OFF";
                          });
                        },
                        child: Image.asset(
                          'assets/icons/ic_settings.png',
                          width: 34,
                          height: 30,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.settings, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 4),

                      GestureDetector(
                        onTap: _volumeDown,
                        child: Image.asset(
                          'assets/icons/ic_decrease_volume.png',
                          width: 32,
                          height: 30,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.volume_down,
                                  color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 4),

                      GestureDetector(
                        onTap: _volumeUp,
                        child: Image.asset(
                          'assets/icons/ic_increase_volume.png',
                          width: 32,
                          height: 30,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.volume_up,
                                  color: Colors.white, size: 20),
                        ),
                      ),
                      const SizedBox(width: 4),

                      GestureDetector(
                        onTap: () {
                          context.push(
                            '/lesson-play',
                            extra: LessonsItem(
                              id: 101,
                              titleName: "Kiss the Rain",
                              authorName: "Yiruma",
                              duration: "02:45",
                              lessonsData: "kiss_the_rain.json",
                              thumbnail: "",
                            ),
                          );
                        },
                        child: Container(
                          height: 30,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A38),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.music_note,
                                  color: Colors.amber, size: 16),
                              SizedBox(width: 4),
                              Text(
                                "Game",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      GestureDetector(
                        onTap: _zoomOut,
                        child: Image.asset(
                          'assets/icons/ic_key_minus_active.png',
                          width: 34,
                          height: 30,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A38),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Center(
                              child: Text("-",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: SizedBox(
                          width: 140,
                          child: MiniPianoOverview(
                            currentStartOctave: currentOctave,
                            visibleWhiteKeysCount: visibleWhiteKeysCount,
                            onScrollOctave: (octave) {
                              setState(() {
                                currentOctave = octave;
                              });
                            },
                          ),
                        ),
                      ),

                      GestureDetector(
                        onTap: _zoomIn,
                        child: Image.asset(
                          'assets/icons/ic_key_plus_active.png',
                          width: 34,
                          height: 30,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A38),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Center(
                              child: Text("+",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Recordings List")),
                          );
                        },
                        child: Image.asset(
                          'assets/icons/ic_list_records.png',
                          width: 34,
                          height: 30,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.playlist_play,
                                  color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 4),

                      RecordButton(
                        isRecording: isRecording,
                        onTap: _toggleRecording,
                      ),
                    ],
                  ),
                ),
              ),

                Expanded(
                  child: PianoView(
                    startOctave: currentOctave,
                    visibleWhiteKeysCount: visibleWhiteKeysCount,
                    showNoteNames: showNoteNames,
                    isLessonMode: false,
                    onNotePressed: (keyName, label) {
                      setState(() {
                        statusMessage = "Played: $label ($keyName)";
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
