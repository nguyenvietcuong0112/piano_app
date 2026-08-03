import 'dart:async';
import 'dart:ui';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import 'ads/const/ad_id_extension.dart';
import 'ads/const/ad_id_name.dart';
import 'ads/loading/ad_loading_page.dart';
import 'ads/manager/my_ad_id_manager.dart';
import 'app/my_app.dart';
import 'core/helper/firebase_helper.dart';
import 'core/services/audio_engine.dart';
import 'core/theme/theme_service.dart';
import 'di/dependency_injection.dart';

const String env = Environment.dev;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  await initPlugin();
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

    final params = ConsentRequestParameters(
      consentDebugSettings: ConsentDebugSettings(
        debugGeography: DebugGeography.debugGeographyEea,
      ),
    );

    final consentCompleter = Completer<void>();

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () async {
        try {
          if (await ConsentInformation.instance.isConsentFormAvailable()) {
            await _loadConsentForm();
          }
          debugPrint('✅ Consent completed');
        } catch (e) {
          debugPrint('⚠️ Consent form error: $e');
        }
        consentCompleter.complete();
      },
      (error) {
        debugPrint('⚠️ Consent error: ${error.message}');
        consentCompleter.complete();
      },
    );

    await consentCompleter.future;

    final IAdIdManager adIdManager = MyAdIdManager();

    await EasyAds.instance.initialize(
      adIdManager,
      unityTestMode: true,
      adMobAdRequest: const AdRequest(httpTimeoutMillis: 60000),
      admobConfiguration: RequestConfiguration(testDeviceIds: ['']),
      loadingSplash: const AdLoadingPage(),
    );

    debugPrint('✅ EasyAds initialized');

    await EasyAds.instance.initAdmob(
      appOpenAdUnitId: MyAdIdName.appOpenResume.getId,
    );

    debugPrint('✅ AdMob initialized with App Open Ad');
    debugPrint('✅ All ads initialization completed successfully');

  } catch (e) {
    debugPrint('❌ Ads initialization error: $e');
  }
}

Future<void> _loadConsentForm() async {
  final completer = Completer<void>();

  ConsentForm.loadConsentForm(
    (consentForm) async {
      final status = await ConsentInformation.instance.getConsentStatus();

      if (status == ConsentStatus.required) {
        consentForm.show((formError) async {
          if (formError != null) {
            debugPrint('⚠️ Consent form show error: ${formError.message}');
            completer.complete();
            return;
          }
          await _loadConsentForm();
          completer.complete();
        });
      } else {
        completer.complete();
      }
    },
    (formError) {
      debugPrint('⚠️ Consent form load error: ${formError.message}');
      completer.complete();
    },
  );

  await completer.future;
}

Future<void> initPlugin() async {
  try {
    final TrackingStatus status =
        await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status == TrackingStatus.notDetermined) {
      await Future.delayed(const Duration(milliseconds: 200));
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  } catch (e) {
    debugPrint('Tracking transparency status error: $e');
  }
}
