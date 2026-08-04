import 'package:flutter/material.dart';

class AppSetting {
  static ValueNotifier<bool> isPremiumUser = ValueNotifier<bool>(false);
  static bool appInBackground = false;
  static ValueNotifier<bool> isInitRemoteConfig = ValueNotifier<bool>(false);
  static int interval_inter_ad = 35;
  static int adImpressionCount = 0;
  static String selectedLanguageCode = 'en';
  static String GSMAccessToken = '';
}
