import 'dart:async';
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'shared_preference_service.dart';

class AudioEngine {
  static final AudioEngine _instance = AudioEngine._internal();
  factory AudioEngine() => _instance;

  AudioEngine._internal() {
    ensureInitialized();
  }

  final Map<String, AudioSource> _noteSources = {};
  // Polyphonic Sound Pool set to Low Latency mode to prevent JNI MediaPlayer log spam
  final List<ap.AudioPlayer> _playerPool = List.generate(8, (_) {
    final p = ap.AudioPlayer();
    p.setPlayerMode(ap.PlayerMode.lowLatency);
    return p;
  });
  int _nextPlayerIndex = 0;

  String currentInstrument = 'bright';
  double volume = 0.8;
  bool _isInitialized = false;
  bool _isLoading = false;

  Future<void> ensureInitialized() async {
    if (_isInitialized && _noteSources.isNotEmpty) return;
    if (_isLoading) return;
    _isLoading = true;

    try {
      currentInstrument = await SharedPreferenceUtils.getSelectedInstrument();
      volume = await SharedPreferenceUtils.getAudioVolume();

      if (!SoLoud.instance.isInitialized) {
        await SoLoud.instance.init();
      }
      await _preloadInstrument(currentInstrument);
      _isInitialized = true;
    } catch (e) {
      debugPrint("SoLoud init error: $e");
    } finally {
      _isLoading = false;
    }
  }

  Future<void> _preloadInstrument(String instrumentFolder) async {
    try {
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
      final String ext = (instrumentFolder == 'organ_v2') ? 'opus' : 'ogg';

      // Parallel batch loading for instant preloading
      List<Future<void>> loadTasks = [];
      for (var key in allKeys) {
        loadTasks.add(() async {
          try {
            final source = await SoLoud.instance
                .loadAsset('assets/sounds/$instrumentFolder/$key.$ext');
            _noteSources[key] = source;
          } catch (_) {
            try {
              final source = await SoLoud.instance
                  .loadAsset('assets/sounds/$instrumentFolder/$key.ogg');
              _noteSources[key] = source;
            } catch (_) {}
          }
        }());

        if (loadTasks.length >= 12) {
          await Future.wait(loadTasks);
          loadTasks.clear();
        }
      }
      if (loadTasks.isNotEmpty) {
        await Future.wait(loadTasks);
      }

      debugPrint(
          "SoLoud loaded ${_noteSources.length} C++ note audio handles for $instrumentFolder ($ext)");
    } catch (e) {
      debugPrint("SoLoud load instrument error: $e");
    }
  }

  Future<void> setVolume(double newVolume) async {
    volume = newVolume.clamp(0.0, 1.0);
    await SharedPreferenceUtils.setAudioVolume(volume);
  }

  Future<void> volumeUp() async {
    await setVolume(volume + 0.1);
  }

  Future<void> volumeDown() async {
    await setVolume(volume - 0.1);
  }

  final Map<String, SoundHandle> _activeHandles = {};

  Future<void> loadInstrument(String instrumentFolder) async {
    currentInstrument = instrumentFolder;
    await SharedPreferenceUtils.setSelectedInstrument(instrumentFolder);
    await _preloadInstrument(instrumentFolder);
  }

  void playNote(String keyName) async {
    if (!_isInitialized && !_isLoading) {
      ensureInitialized();
    }

    // Stop previous sound for this key if still playing
    stopNote(keyName);

    final source = _noteSources[keyName];
    if (source != null) {
      try {
        final handle = SoLoud.instance.play(source, volume: volume);
        _activeHandles[keyName] = handle;
        return;
      } catch (e) {
        debugPrint("SoLoud play error for $keyName: $e");
      }
    }

    // 16-Voice Polyphonic Sound Pool Fallback for rapid note presses
    try {
      final String ext = (currentInstrument == 'organ_v2') ? 'opus' : 'ogg';
      final player = _playerPool[_nextPlayerIndex];
      _nextPlayerIndex = (_nextPlayerIndex + 1) % _playerPool.length;

      player.stop();
      player.play(
        ap.AssetSource('sounds/$currentInstrument/$keyName.$ext'),
        volume: volume,
      );
    } catch (e) {
      debugPrint("Fallback audio play error for $keyName: $e");
    }
  }

  void stopNote(String keyName) {
    final handle = _activeHandles.remove(keyName);
    if (handle != null) {
      try {
        // Piano acoustic decay: 1600ms fade for warm, rich lingering tail!
        // Organ decay: 350ms fade for authentic pipe organ response.
        final int fadeMs = (currentInstrument == 'organ_v2') ? 350 : 1600;
        SoLoud.instance.fadeVolume(handle, 0.0, Duration(milliseconds: fadeMs));
        Future.delayed(Duration(milliseconds: fadeMs + 50), () {
          try {
            SoLoud.instance.stop(handle);
          } catch (_) {}
        });
      } catch (_) {}
    }
  }

  void stopAllNotes() {
    for (var handle in _activeHandles.values) {
      try {
        SoLoud.instance.stop(handle);
      } catch (_) {}
    }
    _activeHandles.clear();

    for (var player in _playerPool) {
      try {
        player.stop();
      } catch (_) {}
    }
  }

  void release() {
    for (var source in _noteSources.values) {
      SoLoud.instance.disposeSource(source);
    }
    _noteSources.clear();
    for (var p in _playerPool) {
      p.dispose();
    }
    _isInitialized = false;
  }
}
