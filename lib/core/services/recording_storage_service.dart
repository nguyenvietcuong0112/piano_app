import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'shared_preference_service.dart';

class RecordedNoteEvent {
  final String keyName;
  final String label;
  final int timestampMs;
  final int durationMs;

  RecordedNoteEvent({
    required this.keyName,
    required this.label,
    required this.timestampMs,
    this.durationMs = 400,
  });

  Map<String, dynamic> toJson() => {
        'keyName': keyName,
        'label': label,
        'timestampMs': timestampMs,
        'durationMs': durationMs,
      };

  factory RecordedNoteEvent.fromJson(Map<String, dynamic> json) =>
      RecordedNoteEvent(
        keyName: json['keyName'] ?? '',
        label: json['label'] ?? '',
        timestampMs: json['timestampMs'] ?? 0,
        durationMs: json['durationMs'] ?? 400,
      );
}

class RecordingItemModel {
  final String id;
  final String title;
  final String date;
  final String duration;
  final String filePath;
  final String mode; // 'mic' or 'internal'
  final List<RecordedNoteEvent>? noteEvents;

  RecordingItemModel({
    required this.id,
    required this.title,
    required this.date,
    required this.duration,
    required this.filePath,
    this.mode = 'mic',
    this.noteEvents,
  });

  String get formattedDuration {
    if (duration.isEmpty) return "00:00";
    final parts = duration.split(':');
    if (parts.length == 2) {
      final m = int.tryParse(parts[0].split('.')[0]) ?? 0;
      final secDouble = double.tryParse(parts[1]) ?? 0.0;
      final s = secDouble.toInt();
      return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    }
    return duration;
  }

  RecordingItemModel copyWith({
    String? id,
    String? title,
    String? date,
    String? duration,
    String? filePath,
    String? mode,
    List<RecordedNoteEvent>? noteEvents,
  }) {
    return RecordingItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      filePath: filePath ?? this.filePath,
      mode: mode ?? this.mode,
      noteEvents: noteEvents ?? this.noteEvents,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date,
        'duration': duration,
        'filePath': filePath,
        'mode': mode,
        if (noteEvents != null)
          'noteEvents': noteEvents!.map((e) => e.toJson()).toList(),
      };

  factory RecordingItemModel.fromJson(Map<String, dynamic> json) =>
      RecordingItemModel(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        date: json['date'] ?? '',
        duration: json['duration'] ?? '',
        filePath: json['filePath'] ?? '',
        mode: json['mode'] ?? 'mic',
        noteEvents: json['noteEvents'] != null
            ? (json['noteEvents'] as List<dynamic>)
                .map((e) => RecordedNoteEvent.fromJson(e as Map<String, dynamic>))
                .toList()
            : null,
      );
}

class RecordingStorageService {
  static const String _keyRecordings = 'SAVED_RECORDINGS_LIST';

  static Future<List<RecordingItemModel>> getRecordings() async {
    try {
      final prefs = await SharedPreferenceService.getInstance();
      final jsonStr = prefs.getString(_keyRecordings);
      if (jsonStr == null || jsonStr.isEmpty) {
        return [];
      }
      final List<dynamic> jsonList = json.decode(jsonStr);
      return jsonList.map((e) => RecordingItemModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint('RecordingStorageService getRecordings error: $e');
      return [];
    }
  }

  static Future<bool> addRecording(RecordingItemModel item) async {
    try {
      final currentList = await getRecordings();
      currentList.insert(0, item);
      return await _saveList(currentList);
    } catch (e) {
      debugPrint('RecordingStorageService addRecording error: $e');
      return false;
    }
  }

  static Future<bool> updateRecording(RecordingItemModel updatedItem) async {
    try {
      final currentList = await getRecordings();
      final index = currentList.indexWhere((e) => e.id == updatedItem.id);
      if (index != -1) {
        currentList[index] = updatedItem;
        return await _saveList(currentList);
      }
      return false;
    } catch (e) {
      debugPrint('RecordingStorageService updateRecording error: $e');
      return false;
    }
  }

  static Future<bool> deleteRecording(String id) async {
    try {
      final currentList = await getRecordings();
      currentList.removeWhere((e) => e.id == id);
      return await _saveList(currentList);
    } catch (e) {
      debugPrint('RecordingStorageService deleteRecording error: $e');
      return false;
    }
  }

  static Future<bool> _saveList(List<RecordingItemModel> list) async {
    final prefs = await SharedPreferenceService.getInstance();
    final jsonStr = json.encode(list.map((e) => e.toJson()).toList());
    return await prefs.setString(_keyRecordings, jsonStr);
  }
}
