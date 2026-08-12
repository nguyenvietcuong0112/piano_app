import 'dart:async';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'ads/const/ad_id_extension.dart';
import 'ads/const/ad_id_name.dart';
import 'ads/loading/ad_loading_page.dart';
import 'ads/manager/my_ad_id_manager.dart';
import 'app/my_app.dart';
import 'core/helper/firebase_helper.dart';
import 'core/router/app_router.dart';
import 'core/services/audio_engine.dart';
import 'core/theme/theme_service.dart';
import 'di/dependency_injection.dart';

const String env = Environment.prod;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (PlatformDispatcher.instance.views.isEmpty) {
    return;
  }

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );



  await configureDependencies();
  await ThemeService.init();
  await AudioEngine().ensureInitialized();

  await _initializeAds();

  runApp(
    const ProviderScope( 
      child: MyApp(),
    ),
  );
}

Future<void> _initializeAds() async {
  try {
    debugPrint('🚀 Starting ads initialization...');

    await EasyAds.instance.initFirebaseAnalytics(FirebaseHelper.analytics);
    EasyAds.adIdResolver = (adId) => adId.getId;

    // Encapsulated Consent Flow (ATT & UMP GDPR)
    await EasyAds.instance.initConsent();

    final IAdIdManager adIdManager = MyAdIdManager();

    await EasyAds.instance.initialize(
      adIdManager,
      navigatorKey: rootNavigatorKey,
      unityTestMode: true,
      adMobAdRequest: const AdRequest(httpTimeoutMillis: 60000),
      admobConfiguration: RequestConfiguration(testDeviceIds: ['']),
      loadingSplash: const AdLoadingPage(),
    );

    debugPrint('✅ EasyAds initialized');

    await EasyAds.instance.initAdmob(
      appOpenAdUnitId: MyAdIdName.appOpenResume.getId,
      appOpenAdIdName: MyAdIdName.appOpenResume,
    );

    EasyAds.instance.onEvent.listen((event) {
      debugPrint('🔥 EasyAds event: type=${event.type}, adUnitId=${event.adUnitId}, data=${event.data}');

      Ad? adObj;
      if (event.ad is Ad) {
        adObj = event.ad as Ad;
      } else if (event.data is Ad) {
        adObj = event.data as Ad;
      }

      final String? adIdName = event.data is String ? event.data as String : null;

      // Handle onAdImpression: logs custom placement event + standard Firebase ad_impression
      if (event.type == AdEventType.onAdImpression) {
        if (adObj != null) {
          FirebaseHelper.logAdmobAdImpression(
            ad: adObj,
            adIdName: adIdName,
            adUnitType: event.adUnitType,
          );
        }
      }
    });

    debugPrint('✅ AdMob initialized with App Open Ad');
    debugPrint('✅ All ads initialization completed successfully');

  } catch (e) {
    debugPrint('❌ Ads initialization error: $e');
  }
}
