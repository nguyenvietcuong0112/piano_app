import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import '../../../core/constants/app_constants.dart';
import '../domain/theme_model.dart';

@lazySingleton
class ThemeDataSource {
  Future<ThemeResponse?> getThemes() async {
    try {
      final apiUrl = AppConstants.wallApiThemesUrl;
      debugPrint("ThemeDataSource: Fetching themes from API: $apiUrl");
      final response = await http
          .get(Uri.parse(apiUrl))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final rawBody = utf8.decode(response.bodyBytes);
        log("📥 [API Response Body] $rawBody", name: 'ThemeAPI');
        final jsonMap = json.decode(rawBody);
        final themeResp = ThemeResponse.fromJson(jsonMap);

        if (themeResp.themeCategories.isNotEmpty) {
          debugPrint(
              "ThemeDataSource: Successfully fetched ${themeResp.themeCategories.length} categories from API.");
          return themeResp;
        }
      }
      debugPrint(
          "ThemeDataSource API returned status ${response.statusCode}, falling back to local themes.");
    } catch (e) {
      debugPrint("ThemeDataSource API fetch error ($e), falling back to local assets.");
    }

    // Fallback: Load 10 local fallback themes from assets/json/themes.json
    return _loadFallbackThemes();
  }

  Future<ThemeResponse?> _loadFallbackThemes() async {
    try {
      final jsonString =
          await rootBundle.loadString('assets/json/themes.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      return ThemeResponse.fromJson(jsonMap);
    } catch (e) {
      debugPrint("Error loading fallback themes.json: $e");
      return null;
    }
  }
}
