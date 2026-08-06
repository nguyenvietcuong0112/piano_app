import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'shared_preference_service.dart';

class RecordingItemModel {
  final String id;
  final String title;
  final String date;
  final String duration;
  final String filePath;

  RecordingItemModel({
    required this.id,
    required this.title,
    required this.date,
    required this.duration,
    required this.filePath,
  });

  RecordingItemModel copyWith({
    String? id,
    String? title,
    String? date,
    String? duration,
    String? filePath,
  }) {
    return RecordingItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      filePath: filePath ?? this.filePath,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'date': date,
        'duration': duration,
        'filePath': filePath,
      };

  factory RecordingItemModel.fromJson(Map<String, dynamic> json) =>
      RecordingItemModel(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        date: json['date'] ?? '',
        duration: json['duration'] ?? '',
        filePath: json['filePath'] ?? '',
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
