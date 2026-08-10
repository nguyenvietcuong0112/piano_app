import 'dart:async';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../ads/const/ad_id_extension.dart';
import '../../ads/const/ad_id_factory.dart';
import '../../ads/const/ad_id_name.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/services/firebase_remote_config_service.dart';
import '../../core/services/shared_preference_service.dart';

/// Data model representing a single onboarding page or full ad page.
class OnboardStep {
  final String titleKey;
  final String descKey;
  final String image;
  final String adId;
  final String? adIdName;
  final String factoryId;
  final EasyAdBase? fullAd;
  final BoxFit fit;

  const OnboardStep({
    this.titleKey = '',
    this.descKey = '',
    this.image = '',
    this.adId = '',
    this.adIdName,
    this.factoryId = '',
    this.fullAd,
    this.fit = BoxFit.cover,
  });

  bool get isFullAd => fullAd != null;
  bool get hasAd => adId.isNotEmpty && !AppConstants.isPremiumUser.value;
}

class OnboardController extends ChangeNotifier {
  final PageController pageController = PageController();

  int currentIndex = 0;
  int currentTabOnboard = 0;
  final int totalPage = 4;
  bool _isDisposed = false;

  // --- Ads State ---
  EasyAdBase? nativeOnboardFull1;
  EasyAdBase? nativeOnboardFull2;
  bool shouldShowAdsFull1 = false;
  bool shouldShowAdsFull2 = false;

  bool isIntro1AdLoading = false;
  bool isIntro4AdLoading = false;
  bool isIntro4AdReady = false;
  bool isFullAdNextButtonVisible = false;

  // --- Subscriptions & Timers ---
  StreamSubscription? _adEventSubscription;
  Timer? _fullAdTimer;
  Timer? _intro1TimeoutTimer;
  Timer? _intro4TimeoutTimer;
  Timer? _intro1SuccessTimer;
  Timer? _intro4SuccessTimer;

  void init() {
    reloadAds();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _cancelTimers();
    _adEventSubscription?.cancel();
    nativeOnboardFull1?.dispose();
    nativeOnboardFull2?.dispose();
    pageController.dispose();
    super.dispose();
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  void _cancelTimers() {
    _fullAdTimer?.cancel();
    _intro1TimeoutTimer?.cancel();
    _intro4TimeoutTimer?.cancel();
    _intro1SuccessTimer?.cancel();
    _intro4SuccessTimer?.cancel();
  }

  // --- Ad Management ---
  void reloadAds() {
    if (AppConstants.isPremiumUser.value) {
      isIntro1AdLoading = false;
      isIntro4AdLoading = false;
      isIntro4AdReady = false;
      _notify();
      return;
    }

    isIntro4AdReady = false;
    _initIntro1AdState();
    _initFullAds();
    _listenAdEvents();
  }

  void _initIntro1AdState() {
    final showAdOnboard1 = FirebaseRemoteConfigService.getBoolConfigByKey(
      FirebaseRemoteConfigService.native_onboarding_1,
    );

    if (showAdOnboard1) {
      final ad = EasyAds.instance.getCachedNativeAd(MyAdIdName.nativeOnboard1Ad);
      final isLoaded = ad != null && ad.isAdLoaded;

      isIntro1AdLoading = true;
      if (isLoaded) {
        _intro1SuccessTimer?.cancel();
        _intro1SuccessTimer = Timer(const Duration(milliseconds: 500), () {
          isIntro1AdLoading = false;
          _notify();
        });
      } else {
        _intro1TimeoutTimer?.cancel();
        _intro1TimeoutTimer = Timer(const Duration(seconds: 4), () {
          if (isIntro1AdLoading) {
            isIntro1AdLoading = false;
            _notify();
          }
        });
      }
    } else {
      isIntro1AdLoading = false;
    }
    isIntro4AdLoading = false;
    _notify();
  }

  void _initFullAds() {
    final showFull1 = FirebaseRemoteConfigService.getBoolConfigByKey(
      FirebaseRemoteConfigService.native_onboarding_full_1,
    );
    final showFull2 = FirebaseRemoteConfigService.getBoolConfigByKey(
      FirebaseRemoteConfigService.native_onboarding_full_2,
    );

    if (showFull1) {
      nativeOnboardFull1 = EasyAds.instance.createNative(
        adNetwork: AdNetwork.admob,
        factoryId: NativeFactoryId.nativeFull,
        adId: MyAdIdName.nativeOnboardFull1Ad.getId,
        adIdName: MyAdIdName.nativeOnboardFull1Ad,
        height: 1.sh,
      );
      final originalLoaded = nativeOnboardFull1?.onAdLoaded;
      nativeOnboardFull1?.onAdLoaded = (adNetwork, adUnitType, data) {
        originalLoaded?.call(adNetwork, adUnitType, data);
        shouldShowAdsFull1 = true;
        _notify();
      };
      nativeOnboardFull1?.load();
    }

    if (showFull2) {
      nativeOnboardFull2 = EasyAds.instance.createNative(
        adNetwork: AdNetwork.admob,
        factoryId: NativeFactoryId.nativeFull,
        adId: MyAdIdName.nativeOnboardFull2Ad.getId,
        adIdName: MyAdIdName.nativeOnboardFull2Ad,
        height: 1.sh,
      );
      final originalLoaded = nativeOnboardFull2?.onAdLoaded;
      nativeOnboardFull2?.onAdLoaded = (adNetwork, adUnitType, data) {
        originalLoaded?.call(adNetwork, adUnitType, data);
        shouldShowAdsFull2 = true;
        _notify();
      };
      nativeOnboardFull2?.load();
    }
  }

  void _listenAdEvents() {
    _adEventSubscription?.cancel();
    _adEventSubscription = EasyAds.instance.onEvent.listen((event) {
      if (event.adUnitId == MyAdIdName.nativeOnboard1Ad.getId) {
        if (event.type == AdEventType.adLoaded || event.type == AdEventType.adFailedToLoad) {
          _intro1SuccessTimer?.cancel();
          _intro1SuccessTimer = Timer(const Duration(milliseconds: 500), () {
            isIntro1AdLoading = false;
            _intro1TimeoutTimer?.cancel();
            _notify();
          });
        }
      } else if (event.adUnitId == MyAdIdName.nativeOnboard4Ad.getId) {
        if (event.type == AdEventType.adLoaded || event.type == AdEventType.adFailedToLoad) {
          isIntro4AdReady = true;
          _intro4SuccessTimer?.cancel();
          _intro4SuccessTimer = Timer(const Duration(milliseconds: 500), () {
            isIntro4AdLoading = false;
            _intro4TimeoutTimer?.cancel();
            _notify();
          });
        }
      } else if (event.adUnitId == MyAdIdName.nativeOnboardFull1Ad.getId) {
        if (event.type == AdEventType.adLoaded) {
          shouldShowAdsFull1 = true;
          _notify();
        }
      } else if (event.adUnitId == MyAdIdName.nativeOnboardFull2Ad.getId) {
        if (event.type == AdEventType.adLoaded) {
          shouldShowAdsFull2 = true;
          _notify();
        }
      }
    });
  }

  List<OnboardStep> getSteps() {
    final showAdOnboard1 = FirebaseRemoteConfigService.getBoolConfigByKey(
      FirebaseRemoteConfigService.native_onboarding_1,
    );
    final showAdOnboard4 = FirebaseRemoteConfigService.getBoolConfigByKey(
      FirebaseRemoteConfigService.native_onboarding_4,
    );
    final isPremium = AppConstants.isPremiumUser.value;

    final steps = <OnboardStep>[
      OnboardStep(
        titleKey: "onboard_title_1",
        descKey: "onboard_desc_1",
        image: "assets/images/onboard1.png",
        adId: showAdOnboard1 ? MyAdIdName.nativeOnboard1Ad.getId : "",
        adIdName: showAdOnboard1 ? MyAdIdName.nativeOnboard1Ad : null,
        factoryId: showAdOnboard1 ? NativeFactoryId.nativeMedia : "",
      ),
      const OnboardStep(
        titleKey: "onboard_title_2",
        descKey: "onboard_desc_2",
        image: "assets/images/onboard2.png",
      ),
    ];

    if (!isPremium && shouldShowAdsFull1 && nativeOnboardFull1 != null) {
      steps.add(OnboardStep(fullAd: nativeOnboardFull1));
    }

    steps.add(const OnboardStep(
      titleKey: "onboard_title_3",
      descKey: "onboard_desc_3",
      image: "assets/images/onboard3.png",
    ));

    if (!isPremium && shouldShowAdsFull2 && nativeOnboardFull2 != null) {
      steps.add(OnboardStep(fullAd: nativeOnboardFull2));
    }

    // Page 4
    steps.add(OnboardStep(
      titleKey: "onboard_title_4",
      descKey: "onboard_desc_4",
      image: "assets/images/onboard4.png",
      adId: showAdOnboard4 ? MyAdIdName.nativeOnboard4Ad.getId : "",
      adIdName: showAdOnboard4 ? MyAdIdName.nativeOnboard4Ad : null,
      factoryId: showAdOnboard4 ? NativeFactoryId.nativeMedia : "",
    ));

    return steps;
  }

  // --- Page Navigation ---
  void onChangePage(int value) {
    currentIndex = value;
    final steps = getSteps();

    if (value >= 0 && value < steps.length) {
      final step = steps[value];

      if (step.isFullAd) {
        isFullAdNextButtonVisible = false;
        _fullAdTimer?.cancel();
        _fullAdTimer = Timer(const Duration(seconds: 2), () {
          isFullAdNextButtonVisible = true;
          _notify();
        });
      } else {
        isFullAdNextButtonVisible = false;
      }

      if (step.titleKey == "onboard_title_4") {
        _checkintro4AdLoadingState();
      }
    }

    int introCount = 0;
    for (int i = 0; i <= value && i < steps.length; i++) {
      if (!steps[i].isFullAd) {
        introCount++;
      }
    }
    currentTabOnboard = (introCount - 1).clamp(0, 3);
    _notify();
  }

  void _checkintro4AdLoadingState() {
    final showAdOnboard4 = FirebaseRemoteConfigService.getBoolConfigByKey(
      FirebaseRemoteConfigService.native_onboarding_4,
    );

    if (showAdOnboard4 && !AppConstants.isPremiumUser.value) {
      final ad = EasyAds.instance.getCachedNativeAd(MyAdIdName.nativeOnboard4Ad);
      final isLoaded = isIntro4AdReady || (ad != null && ad.isAdLoaded);

      if (isLoaded) {
        isIntro4AdLoading = true;
        _intro4TimeoutTimer?.cancel();
        _intro4SuccessTimer?.cancel();
        _intro4SuccessTimer = Timer(const Duration(milliseconds: 500), () {
          isIntro4AdLoading = false;
          _notify();
        });
      } else {
        isIntro4AdLoading = true;
        _intro4TimeoutTimer?.cancel();
        _intro4TimeoutTimer = Timer(const Duration(seconds: 4), () {
          if (isIntro4AdLoading) {
            isIntro4AdLoading = false;
            _notify();
          }
        });
      }
    } else {
      isIntro4AdLoading = false;
    }
  }

  void onSelectNext(BuildContext context, List<OnboardStep> steps) {
    if (currentIndex < steps.length - 1) {
      currentIndex++;
      pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding(context);
    }
    _notify();
  }

  Future<void> _finishOnboarding(BuildContext context) async {
    await SharedPreferenceUtils.setIsNoFirstOpenApp(true);
    if (!AppConstants.isPremiumUser.value) {
      if (!context.mounted) return;
      EasyAds.instance.showInterstitialAd(
        context,
        adId: MyAdIdName.interOnboard.getId,
        adIdName: MyAdIdName.interOnboard,
        adDissmissed: () {
          if (context.mounted) context.go('/home');
        },
        onFailed: () {
          if (context.mounted) context.go('/home');
        },
      );
    } else {
      if (context.mounted) context.go('/home');
    }
  }

  String getTitleButton(int introIndex, BuildContext context) {
    return introIndex == 3 ? context.tr('get_started') : context.tr('next');
  }
}

final onboardControllerProvider =
    ChangeNotifierProvider.autoDispose<OnboardController>((ref) {
  return OnboardController();
});
