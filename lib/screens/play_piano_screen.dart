import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import '../audio/audio_engine.dart';
import '../widgets/piano_view.dart';
import '../widgets/mini_piano_overview.dart';
import '../services/theme_service.dart';
import 'lesson_play_screen.dart';
import '../models/lesson.dart';

class PlayPianoScreen extends StatefulWidget {
  const PlayPianoScreen({super.key});

  @override
  State<PlayPianoScreen> createState() => _PlayPianoScreenState();
}

class _PlayPianoScreenState extends State<PlayPianoScreen> {
  int currentOctave = 3;
  int visibleWhiteKeysCount = 14;
  bool showNoteNames = true;
  String statusMessage = "";

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
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
    int percent = (AudioEngine().volume * 100).round();
    setState(() {
      statusMessage = "🔊 Volume: $percent%";
    });
  }

  void _volumeDown() async {
    await AudioEngine().volumeDown();
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
            // Dynamic Reactive Theme Background Wallpaper
            ValueListenableBuilder<String>(
              valueListenable: ThemeService.currentThemeRes,
              builder: (context, themeRes, child) {
                return Positioned.fill(
                  child: Opacity(
                    opacity: 0.35,
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
                // Sleek Top Bar
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  color: const Color(0xFF14141A),
                  child: Row(
                    children: [
                      // Home Button
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
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

                      // Settings Button
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

                      // Volume Decrease Button
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

                      // Volume Increase Button
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

                      // Game Pill Button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LessonPlayScreen(
                                lesson: LessonsItem(
                                  id: 101,
                                  titleName: "Kiss the Rain",
                                  authorName: "Yiruma",
                                  duration: "02:45",
                                  lessonsData: "kiss_the_rain.json",
                                  thumbnail: "",
                                ),
                              ),
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

                      // Key Minus Zoom Button
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

                      // Mini Piano Overview Bar in Middle
                      Expanded(
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

                      // Key Plus Zoom Button
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

                      // Record List Button
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

                      // Record Mic Button
                      GestureDetector(
                        onTap: _toggleRecording,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.asset(
                              'assets/icons/ic_bg_record.png',
                              width: 76,
                              height: 30,
                              fit: BoxFit.fill,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 76,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/icons/ic_record.png',
                                  width: 14,
                                  height: 14,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, err, stack) => Icon(
                                    isRecording
                                        ? Icons.stop
                                        : Icons.fiber_manual_record,
                                    color: Colors.red,
                                    size: 14,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isRecording ? "Stop" : "REC",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Piano Keyboard View
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
