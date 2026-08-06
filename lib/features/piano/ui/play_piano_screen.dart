import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/audio_engine.dart';
import '../../../core/services/audio_recorder_service.dart';
import '../../../core/services/recording_storage_service.dart';
import '../../../core/theme/theme_service.dart';
import '../../../core/widgets/exit_confirmation_dialog.dart';
import '../../../core/widgets/gradient_border_card.dart';
import '../../../core/widgets/theme_image.dart';
import '../../../core/widgets/mini_piano_overview.dart';
import '../../../core/widgets/record_button.dart';
import '../../../core/widgets/recording_dialogs.dart';
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    AudioEngine().stopAllNotes();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  Future<void> _exitScreen() async {
    final shouldExit = await ExitConfirmationDialog.show(
      context,
      title: "Exit Piano",
      message: "Are you sure you want to leave the piano free play mode?",
      confirmText: "Leave",
      cancelText: "Continue",
    );
    if (shouldExit && mounted) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      if (mounted) {
        context.pop();
      }
    }
  }

  void _handleToggleRecording() async {
    final controller = ref.read(pianoPlayControllerProvider.notifier);
    final playState = ref.read(pianoPlayControllerProvider);
    final recorder = AudioRecorderService();

    if (playState.isRecording) {
      final savedPath = await controller.toggleRecording();
      await recorder.stopRecording(title: "Free Play");

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

      if (savedTitle != null && savedTitle.isNotEmpty && savedPath != null) {
        final newItem = RecordingItemModel(
          id: now.millisecondsSinceEpoch.toString(),
          title: savedTitle,
          date: dateStr,
          duration: "00:07",
          filePath: savedPath,
        );

        await RecordingStorageService.addRecording(newItem);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color(0xFF7E48F0),
              content: Text("✅ Saved recording: $savedTitle"),
            ),
          );
        }
      } else {
        if (savedPath != null) {
          final f = File(savedPath);
          if (await f.exists()) await f.delete();
        }
      }
    } else {
      final selectedMode = await RecordSelectionDialog.show(context);
      if (selectedMode != null) {
        bool success = await recorder.startRecording(
          mode: selectedMode,
          songTitle: "Free Play",
        );
        if (success) {
          controller.toggleRecording();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("⚠️ Microphone permission required")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final playState = ref.watch(pianoPlayControllerProvider);
    final controller = ref.read(pianoPlayControllerProvider.notifier);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _exitScreen();
      },
      child: Scaffold(
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
                      child: ThemeImage(resName: themeRes),
                    ),
                  );
                },
              ),

              Column(
                children: [
                  Container(
                    width: double.infinity,
                    height: 100.r,
                    color: const Color(0xFF14141A),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
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
                          const SizedBox(width: 16),

                          GestureDetector(
                            onTap: controller.toggleNoteNames,
                            child: SvgPicture.asset(
                              'assets/icons/ic_setting_piano.svg',
                              width: 48.w,
                              height: 36.h,
                            ),
                          ),
                          const SizedBox(width: 16),

                          GestureDetector(
                            onTap: () {
                              context.push('/songs-landscape');
                            },
                            child: GradientBorderCard(
                              height: 36.h,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
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
                                  const Color(
                                    0xFFFFFFFF,
                                  ).withValues(alpha: 0.1),
                                  const Color(
                                    0xFFFFFFFF,
                                  ).withValues(alpha: 0.1),
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
                                    const Text(
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
                          ),
                          const SizedBox(width: 16),

                          GestureDetector(
                            onTap: controller.zoomOut,
                            child: SvgPicture.asset(
                              'assets/icons/ic_key_minus_active.svg',
                              width: 48.h,
                              height: 36.h,
                            ),
                          ),
                          const SizedBox(width: 16),

                          SizedBox(
                            width: 150.w,
                            child: MiniPianoOverview(
                              currentStartOctave: playState.currentOctave,
                              visibleWhiteKeysCount:
                                  playState.visibleWhiteKeysCount,
                              onScrollOctave: controller.setOctave,
                            ),
                          ),
                          const SizedBox(width: 16),

                          GestureDetector(
                            onTap: controller.zoomIn,
                            child: SvgPicture.asset(
                              'assets/icons/ic_key_plus_active.svg',
                              width: 48.h,
                              height: 36.h,
                            ),
                          ),
                          const SizedBox(width: 16),

                          GestureDetector(
                            onTap: () => context.push('/recordings'),
                            child: SvgPicture.asset(
                              'assets/icons/ic_list_records.svg',
                              width: 48.h,
                              height: 36.h,
                            ),
                          ),
                          const SizedBox(width: 16),

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
      ),
    );
  }
}
