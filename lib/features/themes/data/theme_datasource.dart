import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import '../domain/theme_model.dart';

@lazySingleton
class ThemeDataSource {
  Future<ThemeResponse?> getThemes() async {
    try {
      final jsonString = await rootBundle.loadString('assets/json/themes.json');
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      return ThemeResponse.fromJson(jsonMap);
    } catch (e) {
      debugPrint("Error loading themes.json: $e");
      return null;
    }
  }
}
