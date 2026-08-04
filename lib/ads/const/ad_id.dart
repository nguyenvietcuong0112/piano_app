import 'dart:io';
import 'package:injectable/injectable.dart';

import 'ad_id_name.dart';

Map<String, Map<String, String>> myAdsId = {
  Environment.dev: Platform.isIOS
      ? {}
      : {
          MyAdIdName.appOpenResume: 'ca-app-pub-3940256099942544/9257395921',
          MyAdIdName.interSplash: 'ca-app-pub-3940256099942544/1033173712',
          MyAdIdName.interSplashHigh: 'ca-app-pub-3940256099942544/1033173712',
          MyAdIdName.nativeLanguage: 'ca-app-pub-3940256099942544/1044960115',
          MyAdIdName.nativeLanguageHigh: 'ca-app-pub-3940256099942544/1044960115',
          MyAdIdName.nativeLanguageClick: 'ca-app-pub-3940256099942544/1044960115',
          MyAdIdName.nativeLanguageClickHigh: 'ca-app-pub-3940256099942544/1044960115',
          MyAdIdName.nativeOnboard1Ad: 'ca-app-pub-3940256099942544/1044960115',
          MyAdIdName.nativeOnboardFull1Ad: 'ca-app-pub-3940256099942544/1044960115',
          MyAdIdName.nativeOnboardFull2Ad: 'ca-app-pub-3940256099942544/1044960115',
          MyAdIdName.nativeOnboard3Ad: 'ca-app-pub-3940256099942544/1044960115',
          MyAdIdName.interClick: 'ca-app-pub-3940256099942544/1033173712',
          MyAdIdName.rewardedAd: 'ca-app-pub-3940256099942544/5224354917',
          MyAdIdName.bannerAll: 'ca-app-pub-3940256099942544/6300978111',
          MyAdIdName.interstitialOnboard: 'ca-app-pub-3940256099942544/1033173712',
          MyAdIdName.nativeHome: 'ca-app-pub-3940256099942544/2521693316',
          MyAdIdName.nativeFull: 'ca-app-pub-3940256099942544/2521693316',
        },
  Environment.prod: Platform.isIOS
      ? {}
      : {
          MyAdIdName.appOpenResume: 'ca-app-pub-1190669921094353/3659713444',
          MyAdIdName.interSplash: 'ca-app-pub-1190669921094353/1223440182',
          MyAdIdName.interSplashHigh: 'ca-app-pub-1190669921094353/6968403063',
          MyAdIdName.nativeLanguage: 'ca-app-pub-1190669921094353/7541436520',
          MyAdIdName.nativeLanguageHigh: 'ca-app-pub-1190669921094353/8854518191',
          MyAdIdName.nativeLanguageClick: 'ca-app-pub-1190669921094353/1033550101',
          MyAdIdName.nativeLanguageClickHigh: 'ca-app-pub-1190669921094353/4342239728',
          MyAdIdName.nativeOnboard1Ad: 'ca-app-pub-1190669921094353/1716076389',
          MyAdIdName.nativeOnboardFull1Ad: 'ca-app-pub-1190669921094353/1115628970',
          MyAdIdName.nativeOnboardFull2Ad: 'ca-app-pub-1190669921094353/6284195177',
          MyAdIdName.nativeOnboard3Ad: 'ca-app-pub-1190669921094353/4915273182',
          MyAdIdName.interClick: 'ca-app-pub-1190669921094353/8089913043',
          MyAdIdName.rewardedAd: 'ca-app-pub-1190669921094353/6776831378',
          MyAdIdName.bannerAll: 'ca-app-pub-1190669921094353/8445136263',
          MyAdIdName.interstitialOnboard: 'ca-app-pub-1190669921094353/8219529693',
          MyAdIdName.nativeHome: 'ca-app-pub-1190669921094353/5463749705',
          MyAdIdName.nativeFull: 'ca-app-pub-1190669921094353/5818972920',
        },
};
