import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/lesson_model.dart';

@lazySingleton
class LessonDataSource {
  Future<LessonsResponse?> getAllLessons({
    int skip = 0,
    int limit = 100,
    String difficulty = 'All',
    String? search,
  }) async {
    // 1. Attempt API fetch from Server
    try {
      final headers = await AppConstants.getApiHeaders();

      final Map<String, String> queryParams = {
        'skip': skip.toString(),
        'limit': limit.toString(),
        'difficulty': difficulty,
      };
      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (headers.containsKey('param1')) queryParams['param1'] = headers['param1']!;
      if (headers.containsKey('param2')) queryParams['param2'] = headers['param2']!;

      final apiUrl = Uri.parse('${AppConstants.baseApiUrl}/songs/').replace(queryParameters: queryParams);
      debugPrint("🚀 [API Request] GET All Songs: $apiUrl");
      debugPrint("🚀 [API Headers] Headers: $headers");

      final response = await http.get(
        apiUrl,
        headers: headers,
      ).timeout(const Duration(seconds: 10));

      debugPrint("📥 [API Response Code] ${response.statusCode}");
      final String rawBody = utf8.decode(response.bodyBytes);
      log("📥 [API Response Body] $rawBody", name: 'LessonAPI');

      if (response.statusCode == 200) {
        final decoded = json.decode(rawBody);
        if (decoded is Map<String, dynamic>) {
          final lessonsResponse = LessonsResponse.fromJson(decoded);
          if (lessonsResponse.categories.isNotEmpty && lessonsResponse.categories.first.items.isNotEmpty) {
            debugPrint("✅ [API Success] Loaded ${lessonsResponse.total} songs from API");
            return lessonsResponse;
          }
        } else {
          debugPrint("❌ [API Decode Error] Expected JSON Map but got ${decoded.runtimeType}: $decoded");
        }
      } else {
        debugPrint("❌ [API Error] Status code ${response.statusCode}: $rawBody");
      }
    } catch (e) {
      debugPrint("❌ [API Exception] Fetch failed, falling back to local asset: $e");
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

  /// GET song detail by ID and difficulty mode (Easy, Medium, Hard)
  /// GET https://api.1teps.com/piano/api/songs/{id}?difficulty={difficulty}
  Future<LessonsItem?> getSongDetail(int songId, {String difficulty = 'Easy'}) async {
    try {
      final headers = await AppConstants.getApiHeaders();

      final Map<String, String> queryParams = {
        'difficulty': difficulty,
      };
      if (headers.containsKey('param1')) queryParams['param1'] = headers['param1']!;
      if (headers.containsKey('param2')) queryParams['param2'] = headers['param2']!;

      final apiUrl = Uri.parse('${AppConstants.baseApiUrl}/songs/$songId').replace(
        queryParameters: queryParams,
      );
      debugPrint("🚀 [API Detail Request] GET Song Detail: $apiUrl");
      debugPrint("🚀 [API Detail Headers] Headers: $headers");

      final response = await http.get(
        apiUrl,
        headers: headers,
      ).timeout(const Duration(seconds: 8));

      debugPrint("📥 [API Detail Response Code] ${response.statusCode}");
      final String rawBody = utf8.decode(response.bodyBytes);
      debugPrint("📥 [API Detail Response Body] $rawBody");

      if (response.statusCode == 200) {
        final decoded = json.decode(rawBody);
        if (decoded is Map<String, dynamic>) {
          final item = LessonsItem.fromJson(decoded);
          debugPrint("✅ [API Detail Success] Loaded detail for songId=$songId");
          return item;
        } else {
          debugPrint("❌ [API Detail Decode Error] Expected JSON Map but got ${decoded.runtimeType}: $decoded");
        }
      } else {
        debugPrint("❌ [API Detail Error] Status code ${response.statusCode}: $rawBody");
      }
    } catch (e) {
      debugPrint("❌ [API Detail Exception] getSongDetail error for songId=$songId: $e");
    }
    return null;
  }

  Future<LessonNoteContainer?> getLessonContainer(String fileNameOrUrl) async {
    if (fileNameOrUrl.isEmpty) return null;

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
          : (fileNameOrUrl.startsWith('/')
              ? '${AppConstants.baseApiHost}$fileNameOrUrl'
              : '${AppConstants.baseApiUrl}/songs/$fileNameOrUrl');

      final response = await http
          .get(Uri.parse(targetUrl))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final bodyStr = utf8.decode(response.bodyBytes);
        debugPrint("📥 [API Note Download] Success! First 100 chars: ${bodyStr.length > 100 ? bodyStr.substring(0, 100) : bodyStr}");
        try {
          final Map<String, dynamic> jsonMap = json.decode(bodyStr);
          final container = LessonNoteContainer.fromJson(jsonMap);
          if (container.data != null && container.data!.isNotEmpty) {
            debugPrint("✅ Successfully loaded lesson notes from API: $targetUrl");
            return container;
          }
        } catch (e) {
          debugPrint("❌ [API Note Decode Error] Could not parse JSON from $targetUrl: $e");
          debugPrint("❌ [API Note Raw Content]: $bodyStr");
        }
      } else {
        debugPrint("Lesson notes API returned status code ${response.statusCode}: $targetUrl");
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

