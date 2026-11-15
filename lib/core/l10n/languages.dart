import 'dart:ui';

/// A language the app can be used in, shown in its own script.
class AppLanguage {
  const AppLanguage(this.code, this.nativeName);

  final String code;
  final String nativeName;

  Locale get locale => Locale(code);
}

/// Launch languages, in the order shown on the language screen.
const appLanguages = [
  AppLanguage('te', 'తెలుగు'),
  AppLanguage('ta', 'தமிழ்'),
  AppLanguage('kn', 'ಕನ್ನಡ'),
  AppLanguage('ml', 'മലയാളം'),
  AppLanguage('en', 'English'),
];

bool isSupportedLanguage(String code) =>
    appLanguages.any((language) => language.code == code);
