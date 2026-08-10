import 'dart:io';

import 'package:get/get.dart';
import 'package:injectable/injectable.dart';

import '../../main.dart' as app_main;

class MyAdIdName {

  static String get appID {
    final isProd = app_main.env == Environment.prod;
    if (isProd) {
      if (Platform.isAndroid) {
        return "ca-app-pub-9900730300733887~4813290623";
      } else {
        return "";
      }
    } else {
      if (Platform.isAndroid) {
        return "ca-app-pub-3940256099942544~3347511713";
      } else {
        return "";
      }
    }
  }
  // static final appID = GetPlatform.isIOS
  //     ? ""
  //     : "ca-app-pub-3940256099942544~3347511713";

  //ca-app-pub-9900730300733887~4813290623
  //ca-app-pub-3940256099942544~3347511713

  static const appOpenResume = "appOpenResume";
  static const bannerSplash = "bannerSplash";
  static const interSplash = "interSplash";
  static const interSplashHigh = "interSplashHigh";
  static const nativeLanguage = "nativeLanguage";
  static const nativeLanguageHigh = "nativeLanguageHigh";
  static const nativeLanguageClick = "nativeLanguageClick";
  static const nativeLanguageClickHigh = "nativeLanguageClickHigh";
  static const nativeOnboard1Ad = "nativeOnboard1Ad";
  static const nativeOnboardFull1Ad = "nativeOnboardFull1Ad";
  static const nativeOnboardFull2Ad = "nativeOnboardFull2Ad";
  static const nativeOnboard4Ad = "nativeOnboard4Ad";
  static const interAll = "interAll";
  static const nativeFull = "nativeFull";
  static const rewardedAd = "rewardedAd";
  static const nativeBanner = "nativeBanner";
  static const interOnboard = "interOnboard";
  static const nativeHome = "nativeHome";
  static const nativeAll = "nativeAll";
}

enum AdType { nativeExpand, nativeCollapse }
