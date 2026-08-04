import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';

class LanguageModel {
  final String pngAsset;
  final String title;
  final String languageCode;

  const LanguageModel({
    required this.pngAsset,
    required this.title,
    required this.languageCode,
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
  bool _isDisposed = false;

  Timer? _nextDelayTimer;
  Timer? _loadingTimer;

  void init({bool firstLaunch = false}) {
    isFirstLaunch = firstLaunch;
    itemsList.clear();
    itemsList.addAll(const [
      LanguageModel(pngAsset: 'assets/flag/flag_hindi.png', title: 'Hindi', languageCode: 'hi'),
      LanguageModel(pngAsset: 'assets/flag/flag_bengali.png', title: 'Bengali', languageCode: 'bn'),
      LanguageModel(pngAsset: 'assets/flag/flag_indonesia.png', title: 'Indonesian', languageCode: 'id'),
      LanguageModel(pngAsset: 'assets/flag/flag_english.png', title: 'English', languageCode: 'en'),
      LanguageModel(pngAsset: 'assets/flag/flag_philippine.png', title: 'Filipino', languageCode: 'fil'),
      LanguageModel(pngAsset: 'assets/flag/flag_spain.png', title: 'Spanish', languageCode: 'es'),
      LanguageModel(pngAsset: 'assets/flag/flag_turkish.png', title: 'Turkish', languageCode: 'tr'),
      LanguageModel(pngAsset: 'assets/flag/flag_portuguese.png', title: 'Portuguese', languageCode: 'pt'),
      LanguageModel(pngAsset: 'assets/flag/flag_arabic.png', title: 'Arabic', languageCode: 'ar'),
      LanguageModel(pngAsset: 'assets/flag/flag_russia.png', title: 'Russian', languageCode: 'ru'),
      LanguageModel(pngAsset: 'assets/flag/flag_france.png', title: 'French', languageCode: 'fr'),
      LanguageModel(pngAsset: 'assets/flag/flag_vietnam.png', title: 'Vietnamese', languageCode: 'vi'),
    ]);

    if (!isFirstLaunch) {
      getPreviousSelectedLanguage();
    }

    isLoading = true;
    _notify();

    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: 3), () {
      isLoading = false;
      _notify();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _nextDelayTimer?.cancel();
    _loadingTimer?.cancel();
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
    selectedIndex = index;
    isShowClickAds = true;
    isShouldShowNext = false;
    _notify();

    _nextDelayTimer?.cancel();
    _nextDelayTimer = Timer(const Duration(milliseconds: 3500), () {
      isShouldShowNext = true;
      _notify();
    });
  }

  void onSelectBack(BuildContext context) {
    Navigator.pop(context);
  }

  void onClickNext(BuildContext context, {required VoidCallback onNavigateNext}) {
    if (selectedIndex >= 0 && selectedIndex < itemsList.length) {
      AppConstants.selectedLanguageCode = itemsList[selectedIndex].languageCode;
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
