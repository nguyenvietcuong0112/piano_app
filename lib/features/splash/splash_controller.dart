import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';

import '../../ads/const/ad_id_name.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../core/helper/firebase_helper.dart';
import '../../core/helper/firebase_remote_config_service.dart';
import '../../core/utils/app_setting.dart';
import '../language/language_page.dart';

class SplashController extends ChangeNotifier {
  double percentLoading = 0.0;
  Timer? _timer;
  int _value = 0;
  bool _isDisposed = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool isNoFirstOpenApp = false;

  void init(BuildContext context, {required VoidCallback onFinished}) {
    EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(true);
    FirebaseHelper.setTrackingScreenName("SplashScreen");
    _checkInternetAndStart(context, onFinished: onFinished);
  }

  @override
  void dispose() {
    _isDisposed = true;
    _connectivitySubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkInternetAndStart(BuildContext context, {required VoidCallback onFinished}) async {
    startFakeDuration(context, onFinished: onFinished);
  }

  void startFakeDuration(BuildContext context, {required VoidCallback onFinished}) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      _value++;
      percentLoading = (_value / 100).clamp(0.0, 1.0);
      if (!_isDisposed) notifyListeners();

      if (_value >= 100) {
        _timer?.cancel();
        goToHome(context, onFinished: onFinished);
      }
    });
  }

  void goToHome(BuildContext context, {required VoidCallback onFinished}) {
    bool showInterSplash = (FirebaseRemoteConfigService.getBoolConfigByKey(
            FirebaseRemoteConfigService.inter_splash) ||
        FirebaseRemoteConfigService.getBoolConfigByKey(
            FirebaseRemoteConfigService.inter_splash_high))
        && !AppSetting.isPremiumUser.value;

    if (showInterSplash) {
      EasyAds.instance.showInterstitialAdSplashWith2Id(
        context,
        interSplashHigh: MyAdIdName.interSplashHigh.getId,
        interSplashAll: MyAdIdName.interSplash.getId,
        onShowed: () {
        },
        adDissmissed: () {
          goNextScreen(context, onFinished: onFinished);
        },
        onFailed: () {
          goNextScreen(context, onFinished: onFinished);
        },
      );
    } else {
      goNextScreen(context, onFinished: onFinished);
    }
  }

  void goNextScreen(BuildContext context, {required VoidCallback onFinished}) {
    EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
    if (isNoFirstOpenApp) {
      onFinished();
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LanguagePage(isFirstLaunch: true),
        ),
      );
    }
  }
}

final splashControllerProvider =
    ChangeNotifierProvider.autoDispose<SplashController>((ref) {
  return SplashController();
});
