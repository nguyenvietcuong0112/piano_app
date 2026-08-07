import 'dart:io';
import 'package:injectable/injectable.dart';

import 'ad_id_name.dart';

Map<String, Map<String, String>> myAdsId = {
  Environment.dev: Platform.isIOS
      ? {}
      : {
          MyAdIdName.appOpenResume: 'ca-app-pub-3940256099942544/9257395921',
          MyAdIdName.bannerSplash: 'ca-app-pub-3940256099942544/6300978111',
          MyAdIdName.interSplash: 'ca-app-pub-3940256099942544/1033173712',
          MyAdIdName.interSplashHigh: 'ca-app-pub-3940256099942544/1033173712',
          MyAdIdName.nativeLanguage: 'ca-app-pub-3940256099942544/1044960115',
          MyAdIdName.nativeLanguageHigh: 'ca-app-pub-3940256099942544/1044960115',
          MyAdIdName.nativeLanguageClick: 'ca-app-pub-3940256099942544/1044960115',
          MyAdIdName.nativeLanguageClickHigh: 'ca-app-pub-3940256099942544/1044960115',
          MyAdIdName.nativeOnboard1Ad: 'ca-app-pub-3940256099942544/1044960115',
          MyAdIdName.nativeOnboardFull1Ad: 'ca-app-pub-3940256099942544/1044960115',
          MyAdIdName.nativeOnboardFull2Ad: 'ca-app-pub-3940256099942544/1044960115',
          MyAdIdName.nativeOnboard4Ad: 'ca-app-pub-3940256099942544/1044960115',
          MyAdIdName.interAll: 'ca-app-pub-3940256099942544/1033173712',
          MyAdIdName.rewardedAd: 'ca-app-pub-3940256099942544/5224354917',
          MyAdIdName.nativeBanner: 'ca-app-pub-3940256099942544/2247696110',
          MyAdIdName.interstitialOnboard: 'ca-app-pub-3940256099942544/1033173712',
          MyAdIdName.nativeHome: 'ca-app-pub-3940256099942544/2521693316',
          MyAdIdName.nativeFull: 'ca-app-pub-3940256099942544/2521693316',
        },
  Environment.prod: Platform.isIOS
      ? {}
      : {
          MyAdIdName.appOpenResume: 'ca-app-pub-9900730300733887/6823155103',
          MyAdIdName.bannerSplash: 'ca-app-pub-9900730300733887/2152182278',
          MyAdIdName.interSplash: 'ca-app-pub-9900730300733887/7561521703',
          MyAdIdName.interSplashHigh: 'ca-app-pub-9900730300733887/8774531026',
          MyAdIdName.nativeLanguage: 'ca-app-pub-9900730300733887/9591688591',
          MyAdIdName.nativeLanguageHigh: 'ca-app-pub-9900730300733887/7348668639',
          MyAdIdName.nativeLanguageClick: 'ca-app-pub-9900730300733887/3026280241',
          MyAdIdName.nativeLanguageClickHigh: 'ca-app-pub-9900730300733887/2834708552',
          MyAdIdName.nativeOnboard1Ad: 'ca-app-pub-9900730300733887/1330055192',
          MyAdIdName.nativeOnboardFull1Ad: 'ca-app-pub-9900730300733887/5934800600',
          MyAdIdName.nativeOnboardFull2Ad: 'ca-app-pub-9900730300733887/2259993485',
          MyAdIdName.nativeOnboard4Ad: 'ca-app-pub-9900730300733887/9755340123',
          MyAdIdName.interAll: 'ca-app-pub-9900730300733887/7675971695',
          MyAdIdName.rewardedAd: 'ca-app-pub-9900730300733887/2423645012',
          MyAdIdName.nativeBanner: '',
          MyAdIdName.interstitialOnboard: 'ca-app-pub-9900730300733887/5624523428',
          MyAdIdName.nativeHome: 'ca-app-pub-9900730300733887/6096396798',
          MyAdIdName.nativeAll: 'ca-app-pub-9900730300733887/4119870063',
        },
};
