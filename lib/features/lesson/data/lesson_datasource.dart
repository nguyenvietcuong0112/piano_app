import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/lesson_model.dart';

@lazySingleton
class LessonDataSource {
  Future<LessonsResponse?> getAllLessons() async {
    // 1. Attempt API fetch from Server
    try {
      final apiUrl = Uri.parse('${AppConstants.baseApiUrl}/lessons');
      final response =
          await http.get(apiUrl).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        final lessonsResponse = LessonsResponse.fromJson(jsonMap);
        if (lessonsResponse.categories.isNotEmpty) {
          debugPrint("Successfully loaded lessons from API: $apiUrl");
          return lessonsResponse;
        }
      }
    } catch (e) {
      debugPrint("API fetch failed, falling back to local asset: $e");
    }

    // 2. Fallback to local lessons.json asset
    try {
      final jsonString =
          await rootBundle.loadString('assets/json/lessons.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      return LessonsResponse.fromJson(jsonMap);
    } catch (e) {
      debugPrint("Error loading local lessons.json: $e");
      return null;
    }
  }

  Future<LessonNoteContainer?> getLessonContainer(String fileNameOrUrl) async {
    final isWebUrl = fileNameOrUrl.startsWith('http://') ||
        fileNameOrUrl.startsWith('https://');

    if (!isWebUrl) {
      // 1. Try local assets first for local json filenames (instant load)
      try {
        final jsonString =
            await rootBundle.loadString('assets/json/lesson/$fileNameOrUrl');
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        final container = LessonNoteContainer.fromJson(jsonMap);
        if (container.data != null && container.data!.isNotEmpty) {
          return container;
        }
      } catch (_) {}

      try {
        final jsonString =
            await rootBundle.loadString('assets/json/$fileNameOrUrl');
        final Map<String, dynamic> jsonMap = json.decode(jsonString);
        final container = LessonNoteContainer.fromJson(jsonMap);
        if (container.data != null && container.data!.isNotEmpty) {
          return container;
        }
      } catch (_) {}
    }

    // 2. Fetch from network API if web URL or fallback
    try {
      final String targetUrl = isWebUrl
          ? fileNameOrUrl
          : '${AppConstants.baseApiUrl}/lessons/$fileNameOrUrl';

      final response = await http
          .get(Uri.parse(targetUrl))
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = json.decode(response.body);
        final container = LessonNoteContainer.fromJson(jsonMap);
        if (container.data != null && container.data!.isNotEmpty) {
          debugPrint("Successfully loaded lesson notes from API: $targetUrl");
          return container;
        }
      }
    } catch (e) {
      debugPrint("API lesson notes fetch failed: $e");
    }

    return null;
  }

  Future<List<LessonNote>> getLessonNotes(String fileNameOrUrl) async {
    final container = await getLessonContainer(fileNameOrUrl);
    if (container?.data != null && container!.data!.isNotEmpty) {
      return container.data!;
    }


    try {
      final jsonString =
          await rootBundle.loadString('assets/json/$fileNameOrUrl');
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
