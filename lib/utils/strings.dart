import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// A language the app is translated into.
class AppLanguage {
  /// Asset / preference code, e.g. "pt" or "zh_TW".
  final String code;

  /// Name written in the language itself.
  final String nativeName;
  final String englishName;
  final bool rtl;

  const AppLanguage(
    this.code,
    this.nativeName,
    this.englishName, {
    this.rtl = false,
  });

  Locale get locale {
    final parts = code.split('_');
    return parts.length == 2 ? Locale(parts[0], parts[1]) : Locale(code);
  }
}

/// Runtime translations. Strings are keyed by their English text and loaded
/// from assets/i18n/<code>.json, so any missing key falls back to English.
class AppStrings {
  AppStrings._();

  /// Preference value meaning "follow the phone's language".
  static const system = 'system';

  static const languages = [
    AppLanguage('en', 'English', 'English'),
    AppLanguage('ar', 'العربية', 'Arabic', rtl: true),
    AppLanguage('bn', 'বাংলা', 'Bengali'),
    AppLanguage('zh', '简体中文', 'Chinese (Simplified)'),
    AppLanguage('zh_TW', '繁體中文', 'Chinese (Traditional)'),
    AppLanguage('nl', 'Nederlands', 'Dutch'),
    AppLanguage('fil', 'Filipino', 'Filipino'),
    AppLanguage('fr', 'Français', 'French'),
    AppLanguage('de', 'Deutsch', 'German'),
    AppLanguage('el', 'Ελληνικά', 'Greek'),
    AppLanguage('hi', 'हिन्दी', 'Hindi'),
    AppLanguage('id', 'Bahasa Indonesia', 'Indonesian'),
    AppLanguage('it', 'Italiano', 'Italian'),
    AppLanguage('ja', '日本語', 'Japanese'),
    AppLanguage('ko', '한국어', 'Korean'),
    AppLanguage('ms', 'Bahasa Melayu', 'Malay'),
    AppLanguage('mr', 'मराठी', 'Marathi'),
    AppLanguage('ne', 'नेपाली', 'Nepali'),
    AppLanguage('fa', 'فارسی', 'Persian', rtl: true),
    AppLanguage('pl', 'Polski', 'Polish'),
    AppLanguage('pt', 'Português', 'Portuguese'),
    AppLanguage('ro', 'Română', 'Romanian'),
    AppLanguage('ru', 'Русский', 'Russian'),
    AppLanguage('es', 'Español', 'Spanish'),
    AppLanguage('sw', 'Kiswahili', 'Swahili'),
    AppLanguage('ta', 'தமிழ்', 'Tamil'),
    AppLanguage('te', 'తెలుగు', 'Telugu'),
    AppLanguage('th', 'ไทย', 'Thai'),
    AppLanguage('tr', 'Türkçe', 'Turkish'),
    AppLanguage('uk', 'Українська', 'Ukrainian'),
    AppLanguage('ur', 'اردو', 'Urdu', rtl: true),
    AppLanguage('vi', 'Tiếng Việt', 'Vietnamese'),
  ];

  /// The user's choice: a language code or [system].
  static String languageCode = system;

  static AppLanguage _active = languages.first;
  static Map<String, String> _strings = const {};

  /// The language actually shown (resolved from [system] when needed).
  static AppLanguage get active => _active;

  static Locale get locale => _active.locale;

  static bool get isRtl => _active.rtl;

  static Future<void> load(String code) async {
    languageCode = code;
    _active = _resolve(code);
    if (_active.code == 'en') {
      _strings = const {};
      return;
    }
    try {
      final raw = await rootBundle.loadString(
        'assets/i18n/${_active.code}.json',
      );
      _strings = Map<String, String>.from(jsonDecode(raw) as Map);
    } catch (e) {
      debugPrint('Loading ${_active.code} translations failed: $e');
      _strings = const {};
    }
  }

  static AppLanguage _resolve(String code) {
    if (code != system) {
      return languages.firstWhere(
        (l) => l.code == code,
        orElse: () => languages.first,
      );
    }
    final device = PlatformDispatcher.instance.locale;
    if (device.languageCode == 'zh') {
      final traditional =
          device.scriptCode == 'Hant' ||
          const ['TW', 'HK', 'MO'].contains(device.countryCode);
      return languages.firstWhere(
        (l) => l.code == (traditional ? 'zh_TW' : 'zh'),
      );
    }
    // Android reports Filipino as "tl" on some devices.
    final lang = device.languageCode == 'tl' ? 'fil' : device.languageCode;
    return languages.firstWhere(
      (l) => l.code == lang,
      orElse: () => languages.first,
    );
  }

  static String tr(String key) => _strings[key] ?? key;
}

/// Shorthand for [AppStrings.tr].
String tr(String key) => AppStrings.tr(key);
