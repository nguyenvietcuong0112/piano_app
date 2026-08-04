import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';

class AppConstants {
  static const String appIdIOS = '';

  // GSM & Adjust Constants
  static const String gsmAppId = '69d63797e75be4583154138a';
  static const String adjustToken = '';
  static const String adjustIapToken = '';

  static final ValueNotifier<bool> isPremiumUser = ValueNotifier<bool>(false)
    ..addListener(() {
      EasyAds.instance.setPremiumUser(isPremiumUser.value);
    });

  static bool appInBackground = false;
  static int interval_inter_ad = 35;
  static int adImpressionCount = 0;
  static String selectedLanguageCode = 'en';
  static String GSMAccessToken = '';
}
