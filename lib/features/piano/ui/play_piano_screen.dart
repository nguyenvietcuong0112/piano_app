import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../ads/dimens/ad_dimen.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/services/audio_engine.dart';
import '../../../core/services/audio_recorder_service.dart';
import '../../../core/services/recording_storage_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_service.dart';
import '../../../core/widgets/exit_confirmation_dialog.dart';
import '../../../core/widgets/gradient_border_card.dart';
import '../../../core/widgets/theme_image.dart';
import '../../../core/widgets/mini_piano_overview.dart';
import '../../../core/widgets/record_button.dart';
import '../../../core/widgets/recording_dialogs.dart';
import '../../../ads/const/ad_id_name.dart';
import '../../../ads/const/ad_id_extension.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_remote_config_service.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../controller/piano_play_controller.dart';
import 'piano_view.dart';

class PlayPianoScreen extends ConsumerStatefulWidget {
  final String instrumentId;

  const PlayPianoScreen({
    super.key,
    this.instrumentId = 'bright',
  });

  @override
  ConsumerState<PlayPianoScreen> createState() => _PlayPianoScreenState();
}

class _PlayPianoScreenState extends ConsumerState<PlayPianoScreen> {
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    AudioEngine().loadInstrument(widget.instrumentId);
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
    if (_isExiting) return;
    _isExiting = true;

    final shouldExit = await ExitConfirmationDialog.show(
      context,
      title: context.tr('quit_lesson_title'),
      message: context.tr('quit_lesson_msg'),
      confirmText: context.tr('quit'),
      cancelText: context.tr('stay'),
    );

    _isExiting = false;

    if (shouldExit && mounted) {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      if (!mounted) return;

      final bool canShowAd = !AppConstants.isPremiumUser.value &&
          FirebaseRemoteConfigService.getBoolConfigByKey(
            FirebaseRemoteConfigService.inter_all,
          );

      if (canShowAd) {
        EasyAds.instance.showInterstitialAd(
          context, 
          adId: MyAdIdName.interAll.getId,
          adIdName: MyAdIdName.interAll,
          adDissmissed: () {
            if (mounted) context.pop();
          },
          onFailed: () {
            if (mounted) context.pop();
          },
        );
      } else {
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
          mode: recorder.currentMode == RecordingMode.internal ? 'internal' : 'mic',
        );

        await RecordingStorageService.addRecording(newItem);

        // if (mounted) {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     backgroundColor: const Color(0xFF7E48F0),
          //     content: Text("✅ ${context.tr('saved_recording')} $savedTitle"),
          //   ),
          // );
        // }
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
            SnackBar(content: Text("⚠️ ${context.tr('mic_permission_required')}")),
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
        final isCurrentRoute = ModalRoute.of(context)?.isCurrent ?? true;
        if (isCurrentRoute && !_isExiting) {
          _exitScreen();
        }
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
                  if (!AppConstants.isPremiumUser.value &&
                      FirebaseRemoteConfigService.getBoolConfigByKey(
                        FirebaseRemoteConfigService.native_banner,
                      ))
                    SizedBox(
                      width: double.infinity,
                      child: EasyNativeAd(
                        factoryId: MyAdIdName.nativeBanner,
                        adId: MyAdIdName.nativeBanner.getId,
                        adIdName: MyAdIdName.nativeBanner,
                        height: AdDimen.nativeBannerHeight,
                      ),
                    ),
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
                            onTap: () async {
                              final newIsDual = await context.push<bool>(
                                '/player-mode',
                                extra: playState.isDualMode,
                              );
                              if (mounted) {
                                SystemChrome.setPreferredOrientations([
                                  DeviceOrientation.landscapeLeft,
                                  DeviceOrientation.landscapeRight,
                                ]);
                                SystemChrome.setEnabledSystemUIMode(
                                  SystemUiMode.immersiveSticky,
                                );
                              }
                              if (newIsDual != null) {
                                controller.setDualMode(newIsDual);
                              }
                            },
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
                                     Text(
                                       "Game",
                                       style: AppTextStyles.textWhite12.copyWith(
                                         fontWeight: FontWeight.bold,
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
                    child: !playState.isDualMode
                        ? PianoView(
                            startOctave: playState.currentOctave,
                            visibleWhiteKeysCount:
                                playState.visibleWhiteKeysCount,
                            showNoteNames: playState.showNoteNames,
                            isLessonMode: false,
                            onNotePressed: controller.setPlayedKeyStatus,
                          )
                        : Column(
                            children: [
                              // Top Keyboard Row (Row 1)
                              Expanded(
                                child: PianoView(
                                  startOctave: playState.currentOctave,
                                  visibleWhiteKeysCount:
                                      playState.visibleWhiteKeysCount,
                                  showNoteNames: playState.showNoteNames,
                                  isLessonMode: false,
                                  onNotePressed: controller.setPlayedKeyStatus,
                                ),
                              ),

                              // Middle Control Divider for Bottom Keyboard Row
                              Container(
                                height: 32.h,
                                width: double.infinity,
                                color: const Color(0xFF14141A),
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Shift -2 (Fast Left)
                                    GestureDetector(
                                      onTap: () =>
                                          controller.shiftBottomOctave(-2),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Icon(
                                            Icons
                                                .keyboard_double_arrow_left_rounded,
                                            color: Colors.white,
                                            size: 18),
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Shift -1 (Left)
                                    GestureDetector(
                                      onTap: () =>
                                          controller.shiftBottomOctave(-1),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Icon(
                                            Icons.keyboard_arrow_left_rounded,
                                            color: Colors.white,
                                            size: 18),
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Mini Overview for Row 2
                                    SizedBox(
                                      width: 160.w,
                                      child: MiniPianoOverview(
                                        currentStartOctave:
                                            playState.bottomOctave,
                                        visibleWhiteKeysCount:
                                            playState.visibleWhiteKeysCount,
                                        onScrollOctave:
                                            controller.setBottomOctave,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    // Shift +1 (Right)
                                    GestureDetector(
                                      onTap: () =>
                                          controller.shiftBottomOctave(1),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Icon(
                                            Icons.keyboard_arrow_right_rounded,
                                            color: Colors.white,
                                            size: 18),
                                      ),
                                    ),
                                    const SizedBox(width: 8),

                                    // Shift +2 (Fast Right)
                                    GestureDetector(
                                      onTap: () =>
                                          controller.shiftBottomOctave(2),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Icon(
                                            Icons
                                                .keyboard_double_arrow_right_rounded,
                                            color: Colors.white,
                                            size: 18),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Bottom Keyboard Row (Row 2)
                              Expanded(
                                child: PianoView(
                                  startOctave: playState.bottomOctave,
                                  visibleWhiteKeysCount:
                                      playState.visibleWhiteKeysCount,
                                  showNoteNames: playState.showNoteNames,
                                  isLessonMode: false,
                                  onNotePressed: controller.setPlayedKeyStatus,
                                ),
                              ),
                            ],
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
