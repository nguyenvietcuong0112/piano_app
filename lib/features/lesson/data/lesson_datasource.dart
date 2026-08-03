import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../domain/lesson_model.dart';

class LessonDataSource {
  Future<LessonsResponse?> getAllLessons() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/json/lessons.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      return LessonsResponse.fromJson(jsonMap);
    } catch (e) {
      debugPrint("Error loading lessons.json: $e");
      return null;
    }
  }

  Future<List<LessonNote>> getLessonNotes(String fileName) async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/json/lesson/$fileName');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final container = LessonNoteContainer.fromJson(jsonMap);
      if (container.data != null && container.data!.isNotEmpty) {
        return container.data!;
      }
    } catch (e) {
      debugPrint("Error loading lesson assets/json/lesson/$fileName: $e");
    }

    try {
      final jsonString =
          await rootBundle.loadString('assets/json/$fileName');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final container = LessonNoteContainer.fromJson(jsonMap);
      if (container.data != null && container.data!.isNotEmpty) {
        return container.data!;
      }
    } catch (_) {}

    try {
      final jsonString =
          await rootBundle.loadString('assets/json/lesson/kiss_the_rain.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      final container = LessonNoteContainer.fromJson(jsonMap);
      if (container.data != null && container.data!.isNotEmpty) {
        return container.data!;
      }
    } catch (e) {
      debugPrint("Fallback kiss_the_rain.json failed: $e");
    }

    return [
      LessonNote(type: 0, group: 4, position: 0, breakTime: 400),
      LessonNote(type: 0, group: 4, position: 2, breakTime: 400),
      LessonNote(type: 0, group: 4, position: 4, breakTime: 400),
      LessonNote(type: 0, group: 5, position: 0, breakTime: 800),
    ];
  }
}
