class PianoSettings {
  final String soundPreset;
  final int octave;
  final double volume;
  final bool showKeyLabels;
  final bool sustainPedal;
  final int metronomeBpm;
  final bool isMetronomePlaying;

  const PianoSettings({
    this.soundPreset = 'bright',
    this.octave = 4,
    this.volume = 0.8,
    this.showKeyLabels = true,
    this.sustainPedal = false,
    this.metronomeBpm = 120,
    this.isMetronomePlaying = false,
  });

  PianoSettings copyWith({
    String? soundPreset,
    int? octave,
    double? volume,
    bool? showKeyLabels,
    bool? sustainPedal,
    int? metronomeBpm,
    bool? isMetronomePlaying,
  }) {
    return PianoSettings(
      soundPreset: soundPreset ?? this.soundPreset,
      octave: octave ?? this.octave,
      volume: volume ?? this.volume,
      showKeyLabels: showKeyLabels ?? this.showKeyLabels,
      sustainPedal: sustainPedal ?? this.sustainPedal,
      metronomeBpm: metronomeBpm ?? this.metronomeBpm,
      isMetronomePlaying: isMetronomePlaying ?? this.isMetronomePlaying,
    );
  }
}
