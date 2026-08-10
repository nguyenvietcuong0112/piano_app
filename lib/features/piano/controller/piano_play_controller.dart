import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../../core/services/audio_engine.dart';

class PianoPlayState {
  final int currentOctave;
  final int bottomOctave;
  final int visibleWhiteKeysCount;
  final bool showNoteNames;
  final String statusMessage;
  final bool isRecording;
  final bool isDualMode;

  const PianoPlayState({
    this.currentOctave = 3,
    this.bottomOctave = 5,
    this.visibleWhiteKeysCount = 14,
    this.showNoteNames = true,
    this.statusMessage = "",
    this.isRecording = false,
    this.isDualMode = false,
  });

  PianoPlayState copyWith({
    int? currentOctave,
    int? bottomOctave,
    int? visibleWhiteKeysCount,
    bool? showNoteNames,
    String? statusMessage,
    bool? isRecording,
    bool? isDualMode,
  }) {
    return PianoPlayState(
      currentOctave: currentOctave ?? this.currentOctave,
      bottomOctave: bottomOctave ?? this.bottomOctave,
      visibleWhiteKeysCount:
          visibleWhiteKeysCount ?? this.visibleWhiteKeysCount,
      showNoteNames: showNoteNames ?? this.showNoteNames,
      statusMessage: statusMessage ?? this.statusMessage,
      isRecording: isRecording ?? this.isRecording,
      isDualMode: isDualMode ?? this.isDualMode,
    );
  }
}

class PianoPlayController extends StateNotifier<PianoPlayState> {
  final AudioRecorder _audioRecorder = AudioRecorder();

  PianoPlayController() : super(const PianoPlayState());

  void setDualMode(bool isDual) {
    state = state.copyWith(isDualMode: isDual);
  }

  void setOctave(int octave) {
    state = state.copyWith(currentOctave: octave);
  }

  void setBottomOctave(int octave) {
    state = state.copyWith(bottomOctave: octave.clamp(1, 7));
  }

  void shiftBottomOctave(int delta) {
    int newOctave = (state.bottomOctave + delta).clamp(1, 7);
    state = state.copyWith(bottomOctave: newOctave);
  }

  void zoomIn() {
    int newCount = (state.visibleWhiteKeysCount - 2).clamp(8, 24);
    state = state.copyWith(visibleWhiteKeysCount: newCount);
  }

  void zoomOut() {
    int newCount = (state.visibleWhiteKeysCount + 2).clamp(8, 24);
    state = state.copyWith(visibleWhiteKeysCount: newCount);
  }

  void toggleNoteNames() {
    bool newShow = !state.showNoteNames;
    state = state.copyWith(
      showNoteNames: newShow,
      statusMessage: newShow ? "Notes: ON" : "Notes: OFF",
    );
  }

  void setPlayedKeyStatus(String keyName, String label) {
    state = state.copyWith(statusMessage: "Played: $label ($keyName)");
  }

  Future<void> volumeUp() async {
    await AudioEngine().volumeUp();
    int percent = (AudioEngine().volume * 100).round();
    state = state.copyWith(statusMessage: "🔊 Volume: $percent%");
  }

  Future<void> volumeDown() async {
    await AudioEngine().volumeDown();
    int percent = (AudioEngine().volume * 100).round();
    state = state.copyWith(statusMessage: "🔉 Volume: $percent%");
  }

  Future<String?> toggleRecording() async {
    try {
      if (state.isRecording) {
        final path = await _audioRecorder.stop();
        state = state.copyWith(
          isRecording: false,
          statusMessage: "Saved: ${path?.split('/').last ?? 'Record'}",
        );
        return path;
      } else {
        if (await _audioRecorder.hasPermission()) {
          final dir = await getApplicationDocumentsDirectory();
          final path =
              '${dir.path}/PianoRecord_${DateTime.now().millisecondsSinceEpoch}.m4a';

          await _audioRecorder.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: path,
          );

          state = state.copyWith(
            isRecording: true,
            statusMessage: "🔴 Recording...",
          );
        }
      }
    } catch (e) {
      debugPrint("Recording error: $e");
    }
    return null;
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }
}

final pianoPlayControllerProvider =
    StateNotifierProvider.autoDispose<PianoPlayController, PianoPlayState>(
        (ref) {
  return PianoPlayController();
});
