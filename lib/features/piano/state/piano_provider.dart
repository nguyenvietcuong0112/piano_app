import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'piano_settings.dart';

class PianoSettingsNotifier extends StateNotifier<PianoSettings> {
  PianoSettingsNotifier() : super(const PianoSettings());

  void setSoundPreset(String preset) {
    state = state.copyWith(soundPreset: preset);
  }

  void setOctave(int octave) {
    state = state.copyWith(octave: octave);
  }

  void setVolume(double volume) {
    state = state.copyWith(volume: volume.clamp(0.0, 1.0));
  }

  void toggleKeyLabels() {
    state = state.copyWith(showKeyLabels: !state.showKeyLabels);
  }

  void toggleSustainPedal() {
    state = state.copyWith(sustainPedal: !state.sustainPedal);
  }

  void setMetronomeBpm(int bpm) {
    state = state.copyWith(metronomeBpm: bpm.clamp(30, 240));
  }

  void toggleMetronome() {
    state = state.copyWith(isMetronomePlaying: !state.isMetronomePlaying);
  }
}

final pianoSettingsProvider =
    StateNotifierProvider<PianoSettingsNotifier, PianoSettings>((ref) {
  return PianoSettingsNotifier();
});
