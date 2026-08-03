import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageModel {
  final String pngAsset;
  final String title;
  final String languageCode;

  LanguageModel({
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
  bool isShowAltAds = false;
  bool isShouldShowNext = false;
  bool isShouldShowAds = true;
  bool isLoading = false;

  void init({bool firstLaunch = false}) {
    isFirstLaunch = firstLaunch;
    itemsList.clear();
    itemsList.addAll([
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

    isLoading = true;
    notifyListeners();

    Future.delayed(const Duration(seconds: 1), () {
      isLoading = false;
      notifyListeners();
    });
  }

  void onSelectItem(int index) {
    selectedIndex = index;
    isShowAltAds = true;
    isShouldShowNext = true;
    notifyListeners();
  }

  void onSelectBack(BuildContext context) {
    Navigator.pop(context);
  }

  void onClickNext(BuildContext context, {required VoidCallback onNavigateNext}) {
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
