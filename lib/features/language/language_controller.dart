import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';

import '../../ads/const/ad_id_extension.dart';
import '../../ads/const/ad_id_name.dart';
import '../../core/constants/app_constants.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/services/shared_preference_service.dart';

class LanguageModel {
  final String title;
  final String languageCode;
  final String countryCode;

  const LanguageModel({
    required this.title,
    required this.languageCode,
    required this.countryCode,
  });
}

class LanguageController extends ChangeNotifier {
  final List<LanguageModel> itemsList = [];
  LanguageModel? selectedLanguage;

  bool isFirstLaunch = false;
  int selectedIndex = 100;
  bool isShowClickAds = false;
  bool isShouldShowNext = false;
  bool isShouldShowAds = true;
  bool isLoading = false;
  bool canClick = false;
  bool _isDisposed = false;

  Timer? _nextDelayTimer;
  Timer? _loadingTimer;
  StreamSubscription? _adEventSubscription;

  void init({bool firstLaunch = false}) {
    isFirstLaunch = firstLaunch;
    itemsList.clear();
    itemsList.addAll(const [
      LanguageModel(title: 'বাংলা', languageCode: 'bn', countryCode: 'bd'),
      LanguageModel(title: 'Bahasa Indonesia', languageCode: 'id', countryCode: 'id'),
      LanguageModel(title: 'Filipino', languageCode: 'fil', countryCode: 'ph'),
      LanguageModel(title: 'Español', languageCode: 'es', countryCode: 'es'),
      LanguageModel(title: 'Türkçe', languageCode: 'tr', countryCode: 'tr'),
      LanguageModel(title: 'Português', languageCode: 'pt', countryCode: 'pt'),
      LanguageModel(title: 'العربية', languageCode: 'ar', countryCode: 'sa'),
      LanguageModel(title: 'Русский', languageCode: 'ru', countryCode: 'ru'),
      LanguageModel(title: 'हिन्दी', languageCode: 'hi', countryCode: 'in'),
      LanguageModel(title: 'English', languageCode: 'en', countryCode: 'us'),
      LanguageModel(title: 'Français', languageCode: 'fr', countryCode: 'fr'),
      LanguageModel(title: 'Tiếng Việt', languageCode: 'vi', countryCode: 'vn'),
    ]);

    if (!isFirstLaunch) {
      getPreviousSelectedLanguage();
    }

    isLoading = true;
    canClick = false;
    _notify();

    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(milliseconds: 3000), () {
      isLoading = false;
      canClick = true;
      _notify();
    });

    _listenAdEvents();
  }

  void _listenAdEvents() {
    _adEventSubscription?.cancel();
    _adEventSubscription = EasyAds.instance.onEvent.listen((event) {
      if (event.adUnitId == MyAdIdName.nativeLanguageClick.getId) {
        if (event.type == AdEventType.adLoaded || event.type == AdEventType.adFailedToLoad) {
          _nextDelayTimer?.cancel();
          _nextDelayTimer = Timer(const Duration(milliseconds: 500), () {
            if (!isShouldShowNext) {
              isShouldShowNext = true;
              _notify();
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _nextDelayTimer?.cancel();
    _loadingTimer?.cancel();
    _adEventSubscription?.cancel();
    super.dispose();
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  void getPreviousSelectedLanguage() {
    final selected = AppConstants.selectedLanguageCode;
    var index = -1;
    for (var i = 0; i < itemsList.length; i++) {
      if (itemsList[i].languageCode == selected) {
        index = i;
        break;
      }
    }

    if (index >= 0) {
      selectedIndex = index;
    } else {
      selectedIndex = 0;
    }
    isShouldShowNext = true;
  }

  void onSelectItem(int index) {
    if (!canClick || isLoading) return;
    
    if (isShowClickAds) {
      // Đã click rồi, Ads hiện tại đã là native_language_click
      selectedIndex = index;
      isShouldShowNext = true;
      _notify();
      return;
    }

    // Lần click đầu tiên: Đổi Ads sang click ads, ẩn Next, đợi Ads load hoặc timeout
    selectedIndex = index;
    isShowClickAds = true;
    isShouldShowNext = false;
    _notify();

    _nextDelayTimer?.cancel();
    _nextDelayTimer = Timer(const Duration(seconds: 3), () {
      if (!isShouldShowNext) {
        isShouldShowNext = true;
        _notify();
      }
    });
  }

  void onAdImpression() {
    if (isShouldShowNext) return;
    
    _nextDelayTimer?.cancel();
    _nextDelayTimer = Timer(const Duration(milliseconds: 500), () {
      if (!isShouldShowNext) {
        isShouldShowNext = true;
        _notify();
      }
    });
  }

  void onSelectBack(BuildContext context) {
    if (!canClick || isLoading) return;
    Navigator.pop(context);
  }

  void onClickNext(
    BuildContext context, {
    required WidgetRef ref,
    required VoidCallback onNavigateNext,
  }) {
    if (!canClick || isLoading) return;
    if (selectedIndex >= 0 && selectedIndex < itemsList.length) {
      final code = itemsList[selectedIndex].languageCode;
      AppConstants.selectedLanguageCode = code;
      SharedPreferenceService.setSelectedLanguageCode(code);
      ref.read(localeProvider.notifier).setLocale(code);
    }

    if (!isFirstLaunch) {
      Navigator.pop(context);
    } else {
      onNavigateNext();
    }
  }
}

final languageControllerProvider =
    ChangeNotifierProvider.autoDispose<LanguageController>((ref) {
  return LanguageController();
});
