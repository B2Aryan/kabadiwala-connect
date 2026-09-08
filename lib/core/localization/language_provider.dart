import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';

/// Preference keys for language persistence
class LanguagePreferenceKeys {
  static const String languageSelected = 'language_selected';
  static const String selectedLanguage = 'selected_language';
}

class LanguageProvider extends ChangeNotifier {
  static LanguageProvider of(BuildContext context, {bool listen = true}) =>
      Provider.of<LanguageProvider>(context, listen: listen);

  AppLanguage _currentLanguage = AppLanguage.english;
  bool _hasSelectedLanguage = false;
  bool _isInitialized = false;
  Completer<void>? _initCompleter;

  AppLanguage get currentLanguage => _currentLanguage;
  bool get hasSelectedLanguage => _hasSelectedLanguage;
  bool get isInitialized => _isInitialized;

  AppLocalizations get localizations => AppLocalizations(_currentLanguage);

  /// Guarantees that saved preferences have finished loading before proceeding
  Future<void> ensureInitialized() async {
    if (_isInitialized) return;
    if (_initCompleter != null) {
      await _initCompleter!.future;
      return;
    }
    await loadSavedLanguage();
  }

  /// Loads saved language and onboarding state from persistent local storage
  Future<void> loadSavedLanguage() async {
    if (_initCompleter != null && !_initCompleter!.isCompleted) {
      return _initCompleter!.future;
    }
    _initCompleter = Completer<void>();

    try {
      final prefs = await SharedPreferences.getInstance();
      final isSelected =
          prefs.getBool(LanguagePreferenceKeys.languageSelected) ?? false;
      final savedCode = prefs.getString(
        LanguagePreferenceKeys.selectedLanguage,
      );

      if (isSelected && savedCode != null && savedCode.trim().isNotEmpty) {
        _hasSelectedLanguage = true;
        _currentLanguage = AppLanguage.fromCode(savedCode);
      } else {
        _hasSelectedLanguage = false;
        // Graceful default for fresh install before user chooses
        _currentLanguage = AppLanguage.english;
      }
    } catch (e) {
      // Safe fallback on unexpected storage read failure
      _hasSelectedLanguage = false;
      _currentLanguage = AppLanguage.english;
    } finally {
      _isInitialized = true;
      if (!_initCompleter!.isCompleted) {
        _initCompleter!.complete();
      }
      notifyListeners();
    }
  }

  /// Updates and immediately persists the chosen language
  Future<void> setLanguage(
    AppLanguage language, {
    bool markSelected = true,
  }) async {
    _currentLanguage = language;
    if (markSelected) {
      _hasSelectedLanguage = true;
    }
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(
        LanguagePreferenceKeys.languageSelected,
        _hasSelectedLanguage,
      );
      await prefs.setString(
        LanguagePreferenceKeys.selectedLanguage,
        language.code,
      );
    } catch (e) {
      debugPrint('Error persisting language preference: $e');
    }
  }

  /// Clears persisted language preferences (for testing or onboarding reset)
  Future<void> resetLanguageSelection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(LanguagePreferenceKeys.languageSelected);
      await prefs.remove(LanguagePreferenceKeys.selectedLanguage);
    } catch (e) {
      debugPrint('Error resetting language preference: $e');
    }
    _hasSelectedLanguage = false;
    _currentLanguage = AppLanguage.english;
    notifyListeners();
  }

  String tr(String key, {Map<String, String>? params}) =>
      localizations.tr(key, params: params);
}
