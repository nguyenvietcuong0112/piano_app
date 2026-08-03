import 'package:flutter_riverpod/flutter_riverpod.dart';

class LessonPlayState {
  final bool isPlaying;
  final bool isRecording;
  final double noteSpeedMultiplier;
  final int score;
  final int currentNoteIndex;

  const LessonPlayState({
    this.isPlaying = false,
    this.isRecording = false,
    this.noteSpeedMultiplier = 1.0,
    this.score = 0,
    this.currentNoteIndex = 0,
  });

  LessonPlayState copyWith({
    bool? isPlaying,
    bool? isRecording,
    double? noteSpeedMultiplier,
    int? score,
    int? currentNoteIndex,
  }) {
    return LessonPlayState(
      isPlaying: isPlaying ?? this.isPlaying,
      isRecording: isRecording ?? this.isRecording,
      noteSpeedMultiplier: noteSpeedMultiplier ?? this.noteSpeedMultiplier,
      score: score ?? this.score,
      currentNoteIndex: currentNoteIndex ?? this.currentNoteIndex,
    );
  }
}

class LessonPlayController extends StateNotifier<LessonPlayState> {
  LessonPlayController() : super(const LessonPlayState());

  void togglePlayback() {
    state = state.copyWith(isPlaying: !state.isPlaying);
  }

  void setPlayback(bool playing) {
    state = state.copyWith(isPlaying: playing);
  }

  void setSpeedMultiplier(double speed) {
    state = state.copyWith(noteSpeedMultiplier: speed);
  }

  void addScore(int points) {
    state = state.copyWith(score: state.score + points);
  }

  void incrementNoteIndex() {
    state = state.copyWith(currentNoteIndex: state.currentNoteIndex + 1);
  }

  void resetNoteIndex() {
    state = state.copyWith(currentNoteIndex: 0);
  }

  void toggleRecording() {
    state = state.copyWith(isRecording: !state.isRecording);
  }
}

final lessonPlayControllerProvider =
    StateNotifierProvider.autoDispose<LessonPlayController, LessonPlayState>(
        (ref) {
  return LessonPlayController();
});
