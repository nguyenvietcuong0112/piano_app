import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/recording_storage_service.dart';

class LessonPlayState {
  final bool isPlaying;
  final bool isPaused;
  final bool isRecording;
  final double noteSpeedMultiplier;
  final int score;
  final int currentNoteIndex;
  final int perfectCount;
  final int goodCount;
  final int missCount;
  final int currentCombo;
  final int maxCombo;
  final int totalNotesInSong;
  final int octaveShift; // -2 to +2
  final String noteLabelMode; // 'scientific', 'solfege', 'off'

  const LessonPlayState({
    this.isPlaying = false,
    this.isPaused = false,
    this.isRecording = false,
    this.noteSpeedMultiplier = 1.0,
    this.score = 0,
    this.currentNoteIndex = 0,
    this.perfectCount = 0,
    this.goodCount = 0,
    this.missCount = 0,
    this.currentCombo = 0,
    this.maxCombo = 0,
    this.totalNotesInSong = 0,
    this.octaveShift = 0,
    this.noteLabelMode = 'scientific',
  });

  double get accuracy {
    if (totalNotesInSong == 0) return 0.0;
    final weightedHit = perfectCount + (0.7 * goodCount);
    final calc = (weightedHit / totalNotesInSong) * 100.0;
    return calc.clamp(0.0, 100.0);
  }

  int get stars {
    final acc = accuracy;
    if (currentNoteIndex == 0 || acc < 20.0) return 0;
    if (acc < 50.0) return 1;
    if (acc < 70.0) return 2;
    if (acc < 85.0) return 3;
    if (acc < 95.0) return 4;
    return 5;
  }

  LessonPlayState copyWith({
    bool? isPlaying,
    bool? isPaused,
    bool? isRecording,
    double? noteSpeedMultiplier,
    int? score,
    int? currentNoteIndex,
    int? perfectCount,
    int? goodCount,
    int? missCount,
    int? currentCombo,
    int? maxCombo,
    int? totalNotesInSong,
    int? octaveShift,
    String? noteLabelMode,
  }) {
    return LessonPlayState(
      isPlaying: isPlaying ?? this.isPlaying,
      isPaused: isPaused ?? this.isPaused,
      isRecording: isRecording ?? this.isRecording,
      noteSpeedMultiplier: noteSpeedMultiplier ?? this.noteSpeedMultiplier,
      score: score ?? this.score,
      currentNoteIndex: currentNoteIndex ?? this.currentNoteIndex,
      perfectCount: perfectCount ?? this.perfectCount,
      goodCount: goodCount ?? this.goodCount,
      missCount: missCount ?? this.missCount,
      currentCombo: currentCombo ?? this.currentCombo,
      maxCombo: maxCombo ?? this.maxCombo,
      totalNotesInSong: totalNotesInSong ?? this.totalNotesInSong,
      octaveShift: octaveShift ?? this.octaveShift,
      noteLabelMode: noteLabelMode ?? this.noteLabelMode,
    );
  }
}

class LessonPlayController extends StateNotifier<LessonPlayState> {
  LessonPlayController() : super(const LessonPlayState());

  final List<RecordedNoteEvent> _recordedNoteEvents = [];
  DateTime? _recordingStartTime;

  void initSong(int totalNotes) {
    state = state.copyWith(
      totalNotesInSong: totalNotes,
    );
  }

  void togglePlayback() {
    state = state.copyWith(isPlaying: !state.isPlaying, isPaused: false);
  }

  void setPlayback(bool playing) {
    state = state.copyWith(isPlaying: playing);
  }

  void setPaused(bool paused) {
    state = state.copyWith(isPaused: paused, isPlaying: !paused);
  }

  void setSpeedMultiplier(double speed) {
    state = state.copyWith(noteSpeedMultiplier: speed);
  }

  void recordHit({required bool isPerfect}) {
    final newCombo = state.currentCombo + 1;
    final newMaxCombo = newCombo > state.maxCombo ? newCombo : state.maxCombo;
    final newPerfect = isPerfect ? state.perfectCount + 1 : state.perfectCount;
    final newGood = !isPerfect ? state.goodCount + 1 : state.goodCount;

    int calculatedScore = state.score;
    if (state.totalNotesInSong > 0) {
      final weightedHit = newPerfect + (0.7 * newGood);
      calculatedScore = ((weightedHit / state.totalNotesInSong) * 100.0)
          .round()
          .clamp(0, 100);
    }

    state = state.copyWith(
      perfectCount: newPerfect,
      goodCount: newGood,
      currentCombo: newCombo,
      maxCombo: newMaxCombo,
      score: calculatedScore,
    );
  }

  void recordMiss() {
    state = state.copyWith(
      missCount: state.missCount + 1,
      currentCombo: 0,
    );
  }

  void incrementNoteIndex() {
    state = state.copyWith(currentNoteIndex: state.currentNoteIndex + 1);
  }

  void resetNoteIndex() {
    state = state.copyWith(
      currentNoteIndex: 0,
      score: 0,
      perfectCount: 0,
      goodCount: 0,
      missCount: 0,
      currentCombo: 0,
      maxCombo: 0,
      isPaused: false,
    );
  }

  void setOctaveShift(int shift) {
    int clamped = shift.clamp(-2, 2);
    state = state.copyWith(octaveShift: clamped);
  }

  void setNoteLabelMode(String mode) {
    state = state.copyWith(noteLabelMode: mode);
  }

  void toggleRecording() {
    if (!state.isRecording) {
      // Starting record
      _recordedNoteEvents.clear();
      _recordingStartTime = DateTime.now();
      state = state.copyWith(isRecording: true);
    } else {
      // Just toggle state; actual stopping is handled by stopRecordingNotes
      state = state.copyWith(isRecording: false);
    }
  }

  void setPlayedKeyStatus(String keyName, String label) {
    if (state.isRecording && _recordingStartTime != null) {
      final elapsedMs =
          DateTime.now().difference(_recordingStartTime!).inMilliseconds;
      _recordedNoteEvents.add(RecordedNoteEvent(
        keyName: keyName,
        label: label,
        timestampMs: elapsedMs,
      ));
    }
  }

  List<RecordedNoteEvent>? stopRecordingNotes() {
    final resultEvents = List<RecordedNoteEvent>.from(_recordedNoteEvents);
    _recordedNoteEvents.clear();
    _recordingStartTime = null;
    state = state.copyWith(isRecording: false);
    return resultEvents.isNotEmpty ? resultEvents : null;
  }
}

final lessonPlayControllerProvider =
    StateNotifierProvider.autoDispose<LessonPlayController, LessonPlayState>(
        (ref) {
  return LessonPlayController();
});

