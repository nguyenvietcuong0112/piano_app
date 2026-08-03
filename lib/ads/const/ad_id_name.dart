import 'package:get/get.dart';

class MyAdIdName {
  static final appID = GetPlatform.isIOS
      ? ""
      : "ca-app-pub-3940256099942544~3347511713";

  static const appOpenResume = "appOpenResume";
  static const interSplash = "interSplash";
  static const interSplashHigh = "interSplashHigh";
  static const nativeLanguage = "nativeLanguage";
  static const nativeLanguageHigh = "nativeLanguageHigh";
  static const nativeLanguageClick = "nativeLanguageClick";
  static const nativeLanguageClickHigh = "nativeLanguageClickHigh";
  static const nativeOnboard1Ad = "nativeOnboard1Ad";
  static const nativeOnboardFull1Ad = "nativeOnboardFull1Ad";
  static const nativeOnboardFull2Ad = "nativeOnboardFull2Ad";
  static const nativeOnboard3Ad = "nativeOnboard3Ad";
  static const interAllAd = "interAllAd";
  static const nativeFull = "nativeFull";
  static const rewardedAd = "rewardedAd";
  static const bannerAll = "bannerAll";
  static const interstitialOnboard = "interstitialOnboard";
  static const nativeHome = "nativeHome";
}

enum AdType { nativeExpand, nativeCollapse }
