import 'dart:io';
import 'dart:ui';

import 'package:get/get.dart';
import 'package:ottapp/Localization/AppTranslations.dart';
import 'package:ottapp/SharedPreferences/PrefKeys.dart';
import 'package:ottapp/SharedPreferences/shared_preferences.dart';

/// Which language the app speaks, and remembering the viewer's choice.
///
/// Their own choice wins. Failing that the device's language decides, so a
/// Spanish speaker opens the app in Spanish without having to find a setting
/// first — the people this is for are the ones who would never go looking.
class LanguageService {
  static const supported = [AppTranslations.english, AppTranslations.spanish];

  static const _locales = {
    AppTranslations.english: Locale('en', 'US'),
    AppTranslations.spanish: Locale('es', '419'),
  };

  /// Shown in the language picker, each written in its own language.
  static const names = {
    AppTranslations.english: 'English',
    AppTranslations.spanish: 'Español',
  };

  /// The code the app should start in.
  ///
  /// Preferences are loaded before the first frame, so this is safe to read
  /// while building the app.
  static String currentCode() {
    final stored = UserPreference.getValue(key: PrefKeys.language) as String?;

    if (stored != null && supported.contains(stored)) {
      return stored;
    }

    return _fromDevice();
  }

  static Locale currentLocale() => localeFor(currentCode());

  static Locale localeFor(String code) =>
      _locales[code] ?? _locales[AppTranslations.english]!;

  static Locale get fallbackLocale => _locales[AppTranslations.english]!;

  static List<Locale> get supportedLocales => _locales.values.toList();

  /// Apply a choice and remember it.
  static Future<void> change(String code) async {
    if (!supported.contains(code)) return;

    await UserPreference.setValue(key: PrefKeys.language, value: code);
    await Get.updateLocale(localeFor(code));
  }

  /// The header the server reads to translate titles and descriptions.
  static String get header => currentCode();

  /// 'es_419' and 'es_MX' are both Spanish as far as this app is concerned,
  /// so only the base tag is compared.
  static String _fromDevice() {
    final tag = Platform.localeName.toLowerCase().replaceAll('_', '-');
    final base = tag.split('-').first;

    return supported.contains(base) ? base : AppTranslations.english;
  }
}
