import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_localizations.dart';

class LanguageProvider extends ChangeNotifier {
  static LanguageProvider of(BuildContext context, {bool listen = true}) =>
      Provider.of<LanguageProvider>(context, listen: listen);

  AppLanguage _currentLanguage = AppLanguage.hindi;

  AppLanguage get currentLanguage => _currentLanguage;

  AppLocalizations get localizations => AppLocalizations(_currentLanguage);

  void setLanguage(AppLanguage language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      notifyListeners();
    }
  }

  String tr(String key, {Map<String, String>? params}) =>
      localizations.tr(key, params: params);
}
