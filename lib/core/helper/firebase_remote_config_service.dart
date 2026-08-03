import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseRemoteConfigService {
  static FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;

  static final String android_app_version = "android_app_version";
  static final String banner_splash = "banner_splash";
  static final String inter_splash_high = "inter_splash_high";
  static final String inter_splash = "inter_splash";
  static final String native_language = "native_language";
  static final String native_language_alt = "native_language_alt";
  static final String native_onboarding_1 = "native_onboarding_1";
  static final String native_onboarding_full_2 = "native_onboarding_full_2";
  static final String native_onboarding_full_1 = "native_onboarding_full_1";
  static final String native_onboarding_3 = "native_onboarding_3";
  static final String native_permission = "native_permission";
  static final String native_banner = "native_banner";
  static final String inter_all = "inter_all";
  static final String interval_inter_ad = "interval_inter_ad";
  static final String native_all = "native_all";
  static final String time_delay_close_premium = "time_delay_close_premium";
  static final String show_activity_iap = "show_activity_iap";

  static final String limit_free_enhance = "limit_free_enhance";
  static final String limit_free_restore = "limit_free_restore";
  static final String limit_free_ai_photo = "limit_free_ai_photo";
  static final String limit_free_ai_filter = "limit_free_ai_filter";

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
        "inter_splash_high": true,
        "inter_splash": true,
        "native_language": true,
        "native_language_alt": true,
        "native_onboarding_1": true,
        "native_onboarding_full_1": true,
        "native_onboarding_full_2": true,
        "native_onboarding_3": true,
        "native_permission": true,
        "native_banner": true,
        "inter_all": true,
        "native_all": true,
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
