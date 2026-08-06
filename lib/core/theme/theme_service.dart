import 'package:flutter/material.dart';
import '../services/shared_preference_service.dart';

class ThemeService {
  static final ValueNotifier<String> currentThemeRes =
      ValueNotifier<String>("theme_1");

  static Future<void> init() async {
    currentThemeRes.value = await SharedPreferenceService.getSelectedThemeResName();
  }

  static Future<void> setTheme(String resName, int id) async {
    await SharedPreferenceService.setSelectedTheme(resName, id);
    currentThemeRes.value = resName;
  }
}
