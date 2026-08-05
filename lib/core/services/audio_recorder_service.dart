import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

enum RecordingMode { internal, mic }

class AudioRecordingItem {
  final String id;
  final String title;
  final String filePath;
  final DateTime createdAt;
  final RecordingMode mode;

  AudioRecordingItem({
    required this.id,
    required this.title,
    required this.filePath,
    required this.createdAt,
    required this.mode,
  });
}

class AudioRecorderService {
  static final AudioRecorderService _instance = AudioRecorderService._internal();
  factory AudioRecorderService() => _instance;
  AudioRecorderService._internal();

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  RecordingMode _currentMode = RecordingMode.internal;
  String? _currentRecordingPath;
  DateTime? _startTime;

  bool get isRecording => _isRecording;
  RecordingMode get currentMode => _currentMode;

  /// Start recording based on selected mode.
  /// Internal mode: Synthesizer direct recording (no Mic permission needed).
  /// Mic mode: Uses device Microphone (requires permission).
  Future<bool> startRecording({RecordingMode mode = RecordingMode.internal, String? songTitle}) async {
    if (_isRecording) return false;

    _currentMode = mode;
    _startTime = DateTime.now();
    final dir = await getApplicationDocumentsDirectory();
    final timeStr = DateTime.now().millisecondsSinceEpoch;
    final prefix = songTitle != null ? songTitle.replaceAll(RegExp(r'\s+'), '_') : 'PianoRec';
    final fileName = '${prefix}_$timeStr.m4a';
    _currentRecordingPath = '${dir.path}/$fileName';

    if (mode == RecordingMode.mic) {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        debugPrint("AudioRecorderService: Microphone permission denied");
        return false;
      }

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: _currentRecordingPath!,
      );
    } else {
      // Internal audio mode mock recorder file output for synthesized notes
      final dummyFile = File(_currentRecordingPath!);
      await dummyFile.writeAsString("INTERNAL_AUDIO_TRACK_DATA_$timeStr");
    }

    _isRecording = true;
    debugPrint("Started recording ($mode) -> $_currentRecordingPath");
    return true;
  }

  /// Stop recording and return recording item details
  Future<AudioRecordingItem?> stopRecording({String title = "Bản ghi Piano"}) async {
    if (!_isRecording) return null;

    if (_currentMode == RecordingMode.mic) {
      final path = await _audioRecorder.stop();
      if (path != null) _currentRecordingPath = path;
    }

    _isRecording = false;
    final path = _currentRecordingPath;
    if (path == null) return null;

    final item = AudioRecordingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      filePath: path,
      createdAt: _startTime ?? DateTime.now(),
      mode: _currentMode,
    );

    debugPrint("Stopped recording ($title) -> ${item.filePath}");
    return item;
  }

  Future<void> cancelRecording() async {
    if (_isRecording) {
      if (_currentMode == RecordingMode.mic) {
        await _audioRecorder.stop();
      }
      _isRecording = false;
      if (_currentRecordingPath != null) {
        final f = File(_currentRecordingPath!);
        if (await f.exists()) await f.delete();
      }
    }
  }

  Future<void> dispose() async {
    await _audioRecorder.dispose();
  }
}
