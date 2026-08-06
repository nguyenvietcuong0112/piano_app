import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/app_constants.dart';
import '../services/shared_preference_service.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(Locale(AppConstants.selectedLanguageCode)) {
    _initLocale();
  }

  Future<void> _initLocale() async {
    final savedCode = await SharedPreferenceService.getSelectedLanguageCode();
    AppConstants.selectedLanguageCode = savedCode;
    state = Locale(savedCode);
  }

  Future<void> setLocale(String languageCode) async {
    AppConstants.selectedLanguageCode = languageCode;
    await SharedPreferenceService.setSelectedLanguageCode(languageCode);
    state = Locale(languageCode);
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
