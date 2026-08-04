import 'dart:async';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:injectable/injectable.dart';

import '../core/helper/iap_helper.dart';
import '../core/helper/notification_helper.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/app_setting.dart';
import '../main.dart' as app_main;

class AppInitializer {
  static StreamSubscription<FGBGType>? _fgbgSubscription;

  static void init() {
    configLoading();
    _initCommonSDK();

    Future.delayed(const Duration(seconds: 5), () {
      IAPHelper.initIAP();
      NotificationHelper.initializeNotifications();
    });
  }

  static void dispose() {
    _fgbgSubscription?.cancel();
  }

  static void _initCommonSDK() {
    _initPlatformState();
    _fgbgSubscription = FGBGEvents.instance.stream.listen((event) {
      debugPrint('MyApp FGBGEvents: $event');
      if (event == FGBGType.foreground) {
        AppSetting.appInBackground = false;
      } else if (event == FGBGType.background) {
        AppSetting.appInBackground = true;
      }
    });

    Future.delayed(const Duration(seconds: 5), () {
      loginGSM();
    });
  }

  static Future<void> loginGSM() async {
    final isProd = app_main.env == Environment.prod;
    final token = await EasyAds.instance.loginGSM(
      gsmAppId: '69d63797e75be4583154138a',
      isProd: isProd,
    );
    if (token != null) {
      AppSetting.GSMAccessToken = token;
    }
  }

  static Future<void> _initPlatformState() async {
    final isProd = app_main.env == Environment.prod;
    AdjustHelper.init(
      token: "",
      iapToken: "",
      isProd: isProd,
    );

    AdjustConfig config = AdjustConfig(
      AdjustHelper.adjustToken,
      !isProd ? AdjustEnvironment.sandbox : AdjustEnvironment.production,
    );

    await EasyAds.instance.initAdjust(config);
  }

  static void handleStateApp(FGBGType event) {
    if (event == FGBGType.foreground) {
      debugPrint('App entered foreground');
    } else if (event == FGBGType.background) {
      debugPrint('App entered background');
    }
  }

  static void configLoading() {
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.ring
      ..loadingStyle = EasyLoadingStyle.light
      ..radius = 10.0
      ..backgroundColor = AppColors.surface
      ..indicatorColor = AppColors.primary
      ..textColor = AppColors.primary
      ..userInteractions = true
      ..dismissOnTap = true
      ..maskType = EasyLoadingMaskType.none
      ..animationStyle = EasyLoadingAnimationStyle.scale;
  }
}
