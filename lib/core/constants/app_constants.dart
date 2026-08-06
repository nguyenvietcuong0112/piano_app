import 'dart:io' show Platform;
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/foundation.dart';

class AppConstants {
  static String get baseApiUrl {
    if (kIsWeb) {
      return 'http://192.168.1.47:3000/api/v1';
    } else if (!kIsWeb && Platform.isAndroid) {
      return 'http://192.168.1.47:3000/api/v1';
    } else {
      // Windows Desktop, macOS, iOS Simulator
      return 'http://192.168.1.47:3000/api/v1';
    }
  }

  static const String wallApiThemesUrl =
      'https://api.1teps.com/wallapi/images?image_type=BG&category=all&pageNumber=1675';

  static const String appIdIOS = '';

  // GSM & Adjust Constants
  static const String gsmAppId = '';
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
