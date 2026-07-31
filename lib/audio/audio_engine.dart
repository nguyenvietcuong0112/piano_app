import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioEngine {
  static final AudioEngine _instance = AudioEngine._internal();
  factory AudioEngine() => _instance;

  AudioEngine._internal() {
    _initEngine();
  }

  final Map<String, AudioSource> _noteSources = {};
  String currentInstrument = 'bright';
  double volume = 0.8;
  bool _isInitialized = false;

  Future<void> _initEngine() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      currentInstrument =
          prefs.getString("SELECTED_INSTRUMENT") ?? "bright";
      volume = prefs.getDouble("AUDIO_VOLUME") ?? 0.8;

      if (!SoLoud.instance.isInitialized) {
        await SoLoud.instance.init();
      }
      _isInitialized = true;
      await _preloadInstrument(currentInstrument);
    } catch (e) {
      debugPrint("SoLoud init error: $e");
    }
  }

  Future<void> _preloadInstrument(String instrumentFolder) async {
    try {
      // Dispose old sources
      for (var source in _noteSources.values) {
        await SoLoud.instance.disposeSource(source);
      }
      _noteSources.clear();

      final List<String> whiteKeys = [
        "w00", "w01", "w10", "w11", "w12", "w13", "w14", "w15", "w16",
        "w20", "w21", "w22", "w23", "w24", "w25", "w26", "w30", "w31",
        "w32", "w33", "w34", "w35", "w36", "w40", "w41", "w42", "w43",
        "w44", "w45", "w46", "w50", "w51", "w52", "w53", "w54", "w55",
        "w56", "w60", "w61", "w62", "w63", "w64", "w65", "w66", "w70",
        "w71", "w72", "w73", "w74", "w75", "w76", "w80"
      ];
      final List<String> blackKeys = [
        "b00", "b10", "b11", "b12", "b13", "b14", "b20", "b21", "b22",
        "b23", "b24", "b30", "b31", "b32", "b33", "b34", "b40", "b41",
        "b42", "b43", "b44", "b50", "b51", "b52", "b53", "b54", "b60",
        "b61", "b62", "b63", "b64", "b70", "b71", "b72", "b73", "b74"
      ];
      final allKeys = [...whiteKeys, ...blackKeys];

      for (var key in allKeys) {
        try {
          final source = await SoLoud.instance
              .loadAsset('assets/sounds/$instrumentFolder/$key.ogg');
          _noteSources[key] = source;
        } catch (_) {}
      }
      debugPrint("SoLoud loaded ${_noteSources.length} C++ note audio handles");
    } catch (e) {
      debugPrint("SoLoud load instrument error: $e");
    }
  }

  Future<void> setVolume(double newVolume) async {
    volume = newVolume.clamp(0.0, 1.0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble("AUDIO_VOLUME", volume);
  }

  Future<void> volumeUp() async {
    await setVolume(volume + 0.1);
  }

  Future<void> volumeDown() async {
    await setVolume(volume - 0.1);
  }

  Future<void> loadInstrument(String instrumentFolder) async {
    if (currentInstrument == instrumentFolder && _noteSources.isNotEmpty) {
      return;
    }
    currentInstrument = instrumentFolder;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("SELECTED_INSTRUMENT", instrumentFolder);
    await _preloadInstrument(instrumentFolder);
  }

  void playNote(String keyName) {
    if (!_isInitialized) {
      _initEngine();
    }
    final source = _noteSources[keyName];
    if (source != null) {
      // High-performance C++ FFI instant playback (< 2ms response)
      SoLoud.instance.play(source, volume: volume);
    } else {
      // Fallback octave 4 key if specific note source missing
      int posDigit = int.tryParse(keyName.substring(keyName.length - 1)) ?? 0;
      String keyType = keyName.startsWith('w') ? 'w' : 'b';
      String fallbackKey = "${keyType}4$posDigit";
      final fallbackSource = _noteSources[fallbackKey];
      if (fallbackSource != null) {
        SoLoud.instance.play(fallbackSource, volume: volume);
      }
    }
  }

  void release() {
    for (var source in _noteSources.values) {
      SoLoud.instance.disposeSource(source);
    }
    _noteSources.clear();
    _isInitialized = false;
  }
}
