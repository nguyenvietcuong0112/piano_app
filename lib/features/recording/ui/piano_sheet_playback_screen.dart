import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';

import '../../../ads/dimens/ad_dimen.dart';
import '../../../core/services/audio_engine.dart';
import '../../../core/services/recording_storage_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_service.dart';
import '../../../core/widgets/gradient_border_card.dart';
import '../../../core/widgets/theme_image.dart';
import '../../../core/widgets/mini_piano_overview.dart';
import '../../../ads/const/ad_id_name.dart';
import '../../../ads/const/ad_id_extension.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_remote_config_service.dart';
import '../../piano/controller/piano_play_controller.dart';
import '../../piano/ui/piano_view.dart';

class PianoSheetPlaybackScreen extends ConsumerStatefulWidget {
  final RecordingItemModel item;

  const PianoSheetPlaybackScreen({
    super.key,
    required this.item,
  });

  @override
  ConsumerState<PianoSheetPlaybackScreen> createState() =>
      _PianoSheetPlaybackScreenState();
}

class _PianoSheetPlaybackScreenState extends ConsumerState<PianoSheetPlaybackScreen> {
  Timer? _playbackTimer;
  int _currentMs = 0;
  int _totalMs = 10000;
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
    
    // Optional: auto-adjust starting octave based on the first recorded note
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.item.noteEvents != null && widget.item.noteEvents!.isNotEmpty) {
        final firstNote = widget.item.noteEvents!.first;
        if (firstNote.keyName.length >= 2) {
          final octStr = firstNote.keyName.substring(1, 2);
          final startOct = int.tryParse(octStr);
          if (startOct != null && startOct >= 1) {
            // Usually we want the playing octave to be somewhat centered or at least visible
            // If they play C4, maybe set startOctave to 3 or 4.
            ref.read(pianoPlayControllerProvider.notifier).setOctave(startOct > 1 ? startOct - 1 : startOct);
          }
        }
      }
    });
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
    _clearActiveKeys();
  }

  void _stopPlaybackTimer() {
    _playbackTimer?.cancel();
    _playbackTimer = null;
  }

  void _restartPlayback() {
    _pausePlayback();
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

  @override
  Widget build(BuildContext context) {
    final playState = ref.watch(pianoPlayControllerProvider);
    final controller = ref.read(pianoPlayControllerProvider.notifier);
    double progress = (_totalMs > 0) ? (_currentMs / _totalMs).clamp(0.0, 1.0) : 0.0;

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
                          onTap: () => context.pop(),
                          child: SvgPicture.asset(
                            'assets/icons/ic_back_home.svg',
                            width: 48.w,
                            height: 36.h,
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
                        const SizedBox(width: 16),

                        GestureDetector(
                          onTap: () {
                            controller.setDualMode(!playState.isDualMode);
                          },
                          child: SvgPicture.asset(
                            'assets/icons/ic_setting_piano.svg',
                            width: 48.w,
                            height: 36.h,
                          ),
                        ),
                        const SizedBox(width: 16),

                        GradientBorderCard(
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
                                  widget.item.title.isNotEmpty ? widget.item.title : "Recorded Sheet",
                                  style: AppTextStyles.textWhite12.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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
                        
                        // Playback Controls
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                if (_isPlaying) {
                                  _pausePlayback();
                                } else {
                                  _startPlayback();
                                }
                              },
                              child: Container(
                                width: 44.h,
                                height: 44.h,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFCF6BEE),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 26.r,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            GestureDetector(
                              onTap: _restartPlayback,
                              child: Container(
                                width: 44.h,
                                height: 44.h,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.replay_rounded,
                                  color: Colors.white,
                                  size: 24.r,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Progress Bar
                Container(
                  height: 4.h,
                  width: double.infinity,
                  color: Colors.white.withValues(alpha: 0.1),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      height: 4.h,
                      width: MediaQuery.of(context).size.width * progress,
                      color: const Color(0xFFCF6BEE),
                    ),
                  ),
                ),

                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          if (playState.isDualMode) ...[
                            Expanded(
                              child: Stack(
                                children: [
                                  PianoView(
                                    startOctave: playState.currentOctave,
                                    visibleWhiteKeysCount:
                                        playState.visibleWhiteKeysCount,
                                    showNoteNames: playState.showNoteNames,
                                    noteLabelMode: 'scientific',
                                    isLessonMode: false,
                                    externalActiveKeys: _activeKeys.toSet(),
                                    onNotePressed: (k, l) {},
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 32.h,
                              width: double.infinity,
                              color: const Color(0xFF14141A),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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
                          ],
                          Expanded(
                            child: Stack(
                              children: [
                                PianoView(
                                  startOctave: playState.isDualMode
                                      ? playState.bottomOctave
                                      : playState.currentOctave,
                                  visibleWhiteKeysCount:
                                      playState.visibleWhiteKeysCount,
                                  showNoteNames: playState.showNoteNames,
                                  noteLabelMode: 'scientific',
                                  isLessonMode: false,
                                  externalActiveKeys: _activeKeys.toSet(),
                                  onNotePressed: (k, l) {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
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
