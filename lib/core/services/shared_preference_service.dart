import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  static SharedPreferences? _prefs;

  // Key definitions
  static const String keyIsNoFirstOpenApp = 'is_no_first_open_app';
  static const String keySelectedThemeId = 'SELECTED_THEME_ID';
  static const String keySelectedThemeResName = 'SELECTED_THEME_RES_NAME';
  static const String keySelectedInstrument = 'SELECTED_INSTRUMENT';
  static const String keyAudioVolume = 'AUDIO_VOLUME';

  /// Ensures SharedPreferences instance is initialized and cached.
  static Future<SharedPreferences> getInstance() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // --- First Open App ---
  static Future<bool> getIsNoFirstOpenApp() async {
    try {
      return (await getInstance()).getBool(keyIsNoFirstOpenApp) ?? false;
    } catch (e) {
      debugPrint('SharedPreferenceService getIsNoFirstOpenApp error: $e');
      return false;
    }
  }

  static Future<bool> setIsNoFirstOpenApp(bool value) async {
    try {
      return await (await getInstance()).setBool(keyIsNoFirstOpenApp, value);
    } catch (e) {
      debugPrint('SharedPreferenceService setIsNoFirstOpenApp error: $e');
      return false;
    }
  }

  // --- Selected Theme ---
  static Future<String> getSelectedThemeResName() async {
    try {
      return (await getInstance()).getString(keySelectedThemeResName) ?? 'theme_jujutsu_kaisen';
    } catch (e) {
      debugPrint('SharedPreferenceService getSelectedThemeResName error: $e');
      return 'theme_jujutsu_kaisen';
    }
  }

  static Future<int?> getSelectedThemeId() async {
    try {
      return (await getInstance()).getInt(keySelectedThemeId);
    } catch (e) {
      debugPrint('SharedPreferenceService getSelectedThemeId error: $e');
      return null;
    }
  }

  static Future<bool> setSelectedTheme(String resName, int id) async {
    try {
      final prefs = await getInstance();
      await prefs.setInt(keySelectedThemeId, id);
      return await prefs.setString(keySelectedThemeResName, resName);
    } catch (e) {
      debugPrint('SharedPreferenceService setSelectedTheme error: $e');
      return false;
    }
  }

  // --- Audio / Instrument ---
  static Future<String> getSelectedInstrument() async {
    try {
      return (await getInstance()).getString(keySelectedInstrument) ?? 'bright';
    } catch (e) {
      debugPrint('SharedPreferenceService getSelectedInstrument error: $e');
      return 'bright';
    }
  }

  static Future<bool> setSelectedInstrument(String instrumentFolder) async {
    try {
      return await (await getInstance()).setString(keySelectedInstrument, instrumentFolder);
    } catch (e) {
      debugPrint('SharedPreferenceService setSelectedInstrument error: $e');
      return false;
    }
  }

  static Future<double> getAudioVolume() async {
    try {
      return (await getInstance()).getDouble(keyAudioVolume) ?? 0.8;
    } catch (e) {
      debugPrint('SharedPreferenceService getAudioVolume error: $e');
      return 0.8;
    }
  }

  static Future<bool> setAudioVolume(double volume) async {
    try {
      return await (await getInstance()).setDouble(keyAudioVolume, volume);
    } catch (e) {
      debugPrint('SharedPreferenceService setAudioVolume error: $e');
      return false;
    }
  }

  // --- Generic Helpers ---
  static Future<bool> setString(String key, String value) async {
    return (await getInstance()).setString(key, value);
  }

  static Future<String?> getString(String key) async {
    return (await getInstance()).getString(key);
  }

  static Future<bool> setBool(String key, bool value) async {
    return (await getInstance()).setBool(key, value);
  }

  static Future<bool?> getBool(String key) async {
    return (await getInstance()).getBool(key);
  }

  static Future<bool> setInt(String key, int value) async {
    return (await getInstance()).setInt(key, value);
  }

  static Future<int?> getInt(String key) async {
    return (await getInstance()).getInt(key);
  }

  static Future<bool> setDouble(String key, double value) async {
    return (await getInstance()).setDouble(key, value);
  }

  static Future<double?> getDouble(String key) async {
    return (await getInstance()).getDouble(key);
  }

  static Future<bool> remove(String key) async {
    return (await getInstance()).remove(key);
  }

  static Future<bool> clear() async {
    return (await getInstance()).clear();
  }
}

typedef SharedPreferenceUtils = SharedPreferenceService;
typedef ShapreferenceUtils = SharedPreferenceService;
