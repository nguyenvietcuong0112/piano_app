import 'dart:io' show Platform;
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/foundation.dart';

import 'package:package_info_plus/package_info_plus.dart';

class AppConstants {
  static const String baseApiHost = 'https://api.1teps.com';
  static String get baseApiUrl => '$baseApiHost/piano/api';

  static String packageName = '';
  static String version = '';
  static String buildNumber = '';

  /// Trả về Headers chứa param1 (Package Name) và param2 (Version Code)
  static Future<Map<String, String>> getApiHeaders() async {
    if (packageName.isEmpty || buildNumber.isEmpty) {
      try {
        final info = await PackageInfo.fromPlatform();
        // packageName = info.packageName.isNotEmpty
        //     ? info.packageName
        //     : 'com.pianokeyboard.virtualpiano.learnpiano';
        packageName = '1';
        version = info.version;
        buildNumber = info.buildNumber.isNotEmpty
            ? info.buildNumber
            : (info.version.isNotEmpty ? info.version : '1');
      } catch (e) {
        debugPrint("Error fetching PackageInfo: $e");
        if (packageName.isEmpty) {
          packageName = 'com.pianokeyboard.virtualpiano.learnpiano';
        }
        if (buildNumber.isEmpty) buildNumber = '1';
      }
    }

    final headers = {
      'param1': packageName,
      'param2': buildNumber,
    };
    debugPrint("API Headers => param1 (Package Name): $packageName, param2 (Version Code): $buildNumber");
    return headers;
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

  /// Cấu hình luồng mở app từ lần thứ 2 trở đi:
  /// - `true`: Từ lần 2 mở app -> Splash vào thẳng Main
  /// - `false`: Lần nào mở app cũng qua Splash -> Language -> Onboard -> Main
  static bool skipLangOnboardOnReopen = true;
}
