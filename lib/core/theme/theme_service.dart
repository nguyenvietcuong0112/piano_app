import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ValueNotifier<String> currentThemeRes =
      ValueNotifier<String>("theme_jujutsu_kaisen");

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    currentThemeRes.value =
        prefs.getString("SELECTED_THEME_RES_NAME") ?? "theme_jujutsu_kaisen";
  }

  static Future<void> setTheme(String resName, int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("SELECTED_THEME_ID", id);
    await prefs.setString("SELECTED_THEME_RES_NAME", resName);
    currentThemeRes.value = resName;
  }
}
