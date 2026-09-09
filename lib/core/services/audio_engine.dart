import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'shared_preference_service.dart';

class AudioEngine {
  static final AudioEngine _instance = AudioEngine._internal();
  factory AudioEngine() => _instance;

  AudioEngine._internal();

  final Map<String, AudioSource> _noteSources = {};
  final Map<String, Future<AudioSource?>> _pendingLoads = {};

  String currentInstrument = 'bright';
  double volume = 0.8;
  bool _isInitialized = false;
  bool _isLoading = false;

  static const List<String> _allWhiteKeys = [
    "w00", "w01", "w10", "w11", "w12", "w13", "w14", "w15", "w16",
    "w20", "w21", "w22", "w23", "w24", "w25", "w26", "w30", "w31",
    "w32", "w33", "w34", "w35", "w36", "w40", "w41", "w42", "w43",
    "w44", "w45", "w46", "w50", "w51", "w52", "w53", "w54", "w55",
    "w56", "w60", "w61", "w62", "w63", "w64", "w65", "w66", "w70",
    "w71", "w72", "w73", "w74", "w75", "w76", "w80"
  ];

  static const List<String> _allBlackKeys = [
    "b00", "b10", "b11", "b12", "b13", "b14", "b20", "b21", "b22",
    "b23", "b24", "b30", "b31", "b32", "b33", "b34", "b40", "b41",
    "b42", "b43", "b44", "b50", "b51", "b52", "b53", "b54", "b60",
    "b61", "b62", "b63", "b64", "b70", "b71", "b72", "b73", "b74"
  ];

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

  Future<AudioSource?> _loadSingleKey(String keyName, String instrumentFolder) async {
    if (_noteSources.containsKey(keyName)) {
      return _noteSources[keyName];
    }
    if (_pendingLoads.containsKey(keyName)) {
      return await _pendingLoads[keyName];
    }

    final future = () async {
      final String ext = (instrumentFolder == 'organ_v2') ? 'opus' : 'ogg';
      try {
        final source = await SoLoud.instance
            .loadAsset('assets/sounds/$instrumentFolder/$keyName.$ext');
        _noteSources[keyName] = source;
        return source;
      } catch (_) {
        try {
          final source = await SoLoud.instance
              .loadAsset('assets/sounds/$instrumentFolder/$keyName.ogg');
          _noteSources[keyName] = source;
          return source;
        } catch (e) {
          debugPrint("Failed to load note $keyName: $e");
          return null;
        }
      }
    }();

    _pendingLoads[keyName] = future;
    final result = await future;
    _pendingLoads.remove(keyName);
    return result;
  }

  Future<void> _loadBatchKeys(List<String> keys, String instrumentFolder) async {
    final String ext = (instrumentFolder == 'organ_v2') ? 'opus' : 'ogg';
    List<Future<void>> batch = [];

    for (var key in keys) {
      if (_noteSources.containsKey(key)) continue;

      batch.add(() async {
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

      if (batch.length >= 8) {
        await Future.wait(batch);
        batch.clear();
      }
    }
    if (batch.isNotEmpty) {
      await Future.wait(batch);
    }
  }

  Future<void> _preloadInstrument(String instrumentFolder) async {
    try {
      for (var source in _noteSources.values) {
        await SoLoud.instance.disposeSource(source);
      }
      _noteSources.clear();
      _pendingLoads.clear();

      // Preload the most commonly played Octaves 3, 4, 5 (C3 to B5) first
      final List<String> coreKeys = [
        "w30", "w31", "w32", "w33", "w34", "w35", "w36",
        "w40", "w41", "w42", "w43", "w44", "w45", "w46",
        "w50", "w51", "w52", "w53", "w54", "w55", "w56",
        "b30", "b31", "b32", "b33", "b34",
        "b40", "b41", "b42", "b43", "b44",
        "b50", "b51", "b52", "b53", "b54"
      ];

      // Rapidly load core 36 keys
      await _loadBatchKeys(coreKeys, instrumentFolder);
      debugPrint("SoLoud core preloaded ${_noteSources.length} notes for $instrumentFolder");

      // Asynchronously load the remaining keys in background (non-blocking)
      final allKeys = [..._allWhiteKeys, ..._allBlackKeys];
      final remainingKeys = allKeys.where((k) => !coreKeys.contains(k)).toList();
      _loadBatchKeys(remainingKeys, instrumentFolder).then((_) {
        debugPrint("SoLoud completed background loading all 88 keys for $instrumentFolder");
      }).catchError((e) {
        debugPrint("SoLoud background preload error: $e");
      });
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

    var source = _noteSources[keyName];
    if (source == null) {
      source = await _loadSingleKey(keyName, currentInstrument);
    }

    if (source != null) {
      try {
        final handle = SoLoud.instance.play(source, volume: volume);
        _activeHandles[keyName] = handle;
      } catch (e) {
        debugPrint("SoLoud play error for $keyName: $e");
      }
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
  }

  void release() {
    for (var source in _noteSources.values) {
      SoLoud.instance.disposeSource(source);
    }
    _noteSources.clear();
    _pendingLoads.clear();
    _isInitialized = false;
  }
}
