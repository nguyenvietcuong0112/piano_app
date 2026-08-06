import 'package:flutter/material.dart';

import 'translations/ar.dart';
import 'translations/bn.dart';
import 'translations/en.dart';
import 'translations/es.dart';
import 'translations/fil.dart';
import 'translations/fr.dart';
import 'translations/hi.dart';
import 'translations/id.dart';
import 'translations/pt.dart';
import 'translations/ru.dart';
import 'translations/tr.dart';
import 'translations/vi.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('vi'),
    Locale('hi'),
    Locale('bn'),
    Locale('id'),
    Locale('fil'),
    Locale('es'),
    Locale('tr'),
    Locale('pt'),
    Locale('ar'),
    Locale('ru'),
    Locale('fr'),
  ];

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': en,
    'vi': vi,
    'hi': hi,
    'bn': bn,
    'id': id,
    'fil': fil,
    'es': es,
    'tr': tr,
    'pt': pt,
    'ar': ar,
    'ru': ru,
    'fr': fr,
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((element) => element.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsX on BuildContext {
  String tr(String key) {
    return AppLocalizations.of(this)?.translate(key) ?? key;
  }
}
