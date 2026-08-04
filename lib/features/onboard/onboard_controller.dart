import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ads/const/ad_id_extension.dart';
import '../../ads/const/ad_id_name.dart';
import '../../ads/nativefull/native_full_screen.dart';
import '../../core/services/firebase_remote_config_service.dart';
import '../../core/utils/app_setting.dart';

import '../../core/services/shared_preference_service.dart';

class OnboardStep {
  final String title;
  final String desc;
  final String image;
  final BoxFit fit;

  OnboardStep({
    this.title = '',
    this.desc = '',
    this.image = '',
    this.fit = BoxFit.cover,
  });
}

class OnboardController extends ChangeNotifier {
  final PageController pageController = PageController();
  int currentIndex = 0;
  int totalPage = 4;
  int currentTabOnboard = 0;
  bool _isDisposed = false;

  void init() {}

  @override
  void dispose() {
    _isDisposed = true;
    pageController.dispose();
    super.dispose();
  }

  void onSelectBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  List<OnboardStep> getSteps() {
    return [
      OnboardStep(
        title: "Meet your AI Companion",
        desc: "Find your perfect match and stay connected anytime",
        image: "assets/png/onboard1.png",
      ),
      OnboardStep(
        title: "Dive into Deep Conversations",
        desc: "Enjoy unlimited, private chats with someone who understands you",
        image: "assets/png/onboard2.png",
      ),
      OnboardStep(
        title: "Create Personalized AI Friend",
        desc: "Shape personality, style and vibe into a companion made for you",
        image: "assets/png/onboard3.png",
      ),
      OnboardStep(
        title: "Your AI Companion Awaits",
        desc: "Start now and feel the connection instantly",
        image: "assets/png/onboard4.png",
      ),
    ];
  }

  void onChangePage(int value) {
    currentIndex = value;
    currentTabOnboard = value.clamp(0, 3);
    if (!_isDisposed) notifyListeners();
  }

  void onSelectNext(BuildContext context, List<OnboardStep> steps) {
    if (currentIndex == 0) {
      bool showNativeFull1 = FirebaseRemoteConfigService.getBoolConfigByKey(
              FirebaseRemoteConfigService.native_onboarding_full_1) &&
          !AppSetting.isPremiumUser.value;

      if (showNativeFull1) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NativeFullScreen(
              nativeFullId: MyAdIdName.nativeOnboardFull1Ad.getId,
              handleNavigate: () {
                Navigator.pop(context);
                _goToNextPage(steps);
              },
            ),
          ),
        );
      } else {
        _goToNextPage(steps);
      }
    } else if (currentIndex == 1) {
      _goToNextPage(steps);
    } else if (currentIndex == 2) {
      bool showNativeFull2 = FirebaseRemoteConfigService.getBoolConfigByKey(
              FirebaseRemoteConfigService.native_onboarding_full_2) &&
          !AppSetting.isPremiumUser.value;

      if (showNativeFull2) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NativeFullScreen(
              nativeFullId: MyAdIdName.nativeOnboardFull2Ad.getId,
              handleNavigate: () {
                Navigator.pop(context);
                _goToNextPage(steps);
              },
            ),
          ),
        );
      } else {
        _goToNextPage(steps);
      }
    } else {
      _markAppOpened();
      context.go('/home');
    }
  }

  Future<void> _markAppOpened() async {
    await SharedPreferenceUtils.setIsNoFirstOpenApp(true);
  }

  void _goToNextPage(List<OnboardStep> steps) {
    if (currentIndex < steps.length - 1) {
      currentIndex++;
      pageController.animateToPage(
        currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    if (!_isDisposed) notifyListeners();
  }

  String getTitleButton(int introIndex) {
    if (introIndex == 3) {
      return "Get started";
    } else {
      return "Next";
    }
  }
}

final onboardControllerProvider =
    ChangeNotifierProvider.autoDispose<OnboardController>((ref) {
  return OnboardController();
});
