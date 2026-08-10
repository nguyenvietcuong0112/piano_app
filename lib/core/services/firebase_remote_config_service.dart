import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseRemoteConfigService {
  static FirebaseRemoteConfig get remoteConfig => FirebaseRemoteConfig.instance;

  static const String android_app_version = "android_app_version";

  //ads
  static const String banner_splash = "banner_splash";
  static const String native_banner = "native_banner";
  static const String inter_splash_high = "inter_splash_high";
  static const String inter_splash = "inter_splash";
  static const String native_language = "native_language";
  static const String native_language_click = "native_language_click";
  static const String native_onboarding_1 = "native_onboarding_1";
  static const String native_onboarding_full_1 = "native_onboarding_full_1";
  static const String native_onboarding_full_2 = "native_onboarding_full_2";
  static const String native_onboarding_4 = "native_onboarding_4";

  static const String inter_all = "inter_all";
  static const String inter_onboard = "inter_onboard";
  static const String interval_inter_ad = "interval_inter_ad";
  static const String native_all = "native_all";
  static const String native_themes = "native_themes";
  static const String native_piano = "native_piano";
  static const String native_home = "native_home";

  static const String reward_all = "reward_all";

  static const String time_delay_close_premium = "time_delay_close_premium";
  static const String show_activity_iap = "show_activity_iap";



  static Future<void> initFirebaseRemoteConfig() async {
    try {
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(minutes: 2),
          minimumFetchInterval: const Duration(seconds: 60),
        ),
      );
      await remoteConfig.setDefaults({
        "show_activity_iap": true,
        "banner_splash": true,
        "native_banner": true,
        "inter_splash_high": true,
        "inter_splash": true,
        "native_language": true,
        "native_language_click": true,
        "native_onboarding_1": true,
        "native_onboarding_full_1": true,
        "native_onboarding_full_2": true,
        "native_onboarding_4": true,
        "native_permission": true,
        "inter_onboard": true,
        "inter_all": true,
        "native_all": true,
        "native_themes": true,
        "native_piano": true,
        "interval_inter_ad": 30,
        "time_delay_close_premium": 0,
      });
      await remoteConfig.fetchAndActivate();
    } catch (e) {}
  }

  static String getStringConfigByKey(String key) {
    return remoteConfig.getString(key);
  }

  static bool getBoolConfigByKey(String key, {bool defaultValue = true}) {
    try {
      final value = remoteConfig.getValue(key);
      if (value.source == ValueSource.valueStatic) {
        return defaultValue;
      }
      return remoteConfig.getBool(key);
    } catch (e) {
      return defaultValue;
    }
  }

  static int getIntConfigByKey(String key, {int defaultValue = 0}) {
    try {
      final value = remoteConfig.getValue(key);
      if (value.source == ValueSource.valueStatic) {
        return defaultValue;
      }
      return remoteConfig.getInt(key);
    } catch (e) {
      return defaultValue;
    }
  }
}

typedef FirebaseService = FirebaseRemoteConfigService;
