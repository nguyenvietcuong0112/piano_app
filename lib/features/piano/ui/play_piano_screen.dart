import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/audio_engine.dart';
import '../../../core/theme/theme_service.dart';
import '../../../core/widgets/mini_piano_overview.dart';
import '../../../core/widgets/record_button.dart';
import '../../lesson/domain/lesson_model.dart';
import '../state/piano_provider.dart';
import '../controller/piano_play_controller.dart';
import 'piano_view.dart';

class PlayPianoScreen extends ConsumerStatefulWidget {
  const PlayPianoScreen({super.key});

  @override
  ConsumerState<PlayPianoScreen> createState() => _PlayPianoScreenState();
}

class _PlayPianoScreenState extends ConsumerState<PlayPianoScreen> {
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
    super.dispose();
  }

  void _handleToggleRecording() async {
    final controller = ref.read(pianoPlayControllerProvider.notifier);
    final savedPath = await controller.toggleRecording();
    if (savedPath != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Saved: $savedPath")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final playState = ref.watch(pianoPlayControllerProvider);
    final controller = ref.read(pianoPlayControllerProvider.notifier);

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
                          onTap: controller.toggleNoteNames,
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
                          onTap: controller.volumeDown,
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
                          onTap: controller.volumeUp,
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
                          onTap: controller.zoomOut,
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
                              currentStartOctave: playState.currentOctave,
                              visibleWhiteKeysCount: playState.visibleWhiteKeysCount,
                              onScrollOctave: controller.setOctave,
                            ),
                          ),
                        ),

                        GestureDetector(
                          onTap: controller.zoomIn,
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
                          isRecording: playState.isRecording,
                          onTap: _handleToggleRecording,
                        ),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: PianoView(
                    startOctave: playState.currentOctave,
                    visibleWhiteKeysCount: playState.visibleWhiteKeysCount,
                    showNoteNames: playState.showNoteNames,
                    isLessonMode: false,
                    onNotePressed: controller.setPlayedKeyStatus,
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
