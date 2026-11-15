// Piligrim typography for five scripts: Telugu, Tamil, Kannada, Malayalam
// and Latin. Headings use Anek, reading text uses Noto Sans. Each script has
// its own font family in both, drawn to match.

import 'package:material_ui/material_ui.dart';

/// The script a locale is written in. Decides font families and line heights.
enum PgScript {
  latin(heading: 'Anek Latin', body: 'Noto Sans'),
  telugu(heading: 'Anek Telugu', body: 'Noto Sans Telugu'),
  tamil(heading: 'Anek Tamil', body: 'Noto Sans Tamil'),
  kannada(heading: 'Anek Kannada', body: 'Noto Sans Kannada'),
  malayalam(heading: 'Anek Malayalam', body: 'Noto Sans Malayalam');

  const PgScript({required this.heading, required this.body});

  /// Font family for display, headline and title styles.
  final String heading;

  /// Font family for body, label and caption styles.
  final String body;

  bool get isIndic => this != PgScript.latin;

  /// Families tried, in order, for characters the main family lacks: Latin
  /// digits and names inside Indic text, or an Indic name inside English.
  List<String> get fallback => [
    for (final s in PgScript.values)
      if (s != this) s.body,
  ];

  static PgScript fromLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'te':
        return PgScript.telugu;
      case 'ta':
        return PgScript.tamil;
      case 'kn':
        return PgScript.kannada;
      case 'ml':
        return PgScript.malayalam;
      default:
        return PgScript.latin;
    }
  }
}

/// The locales v1 ships, in the order the language picker lists them.
const List<Locale> pgSupportedLocales = [
  Locale('te'),
  Locale('ta'),
  Locale('kn'),
  Locale('ml'),
  Locale('en'),
];

/// Language names, each in its own script, for the language picker.
const Map<String, String> pgLanguageNames = {
  'te': 'తెలుగు',
  'ta': 'தமிழ்',
  'kn': 'ಕನ್ನಡ',
  'ml': 'മലയാളം',
  'en': 'English',
};

/// The in-app text size setting. It multiplies the phone's own font scale.
/// Layouts must hold up to a combined scale of 2.0.
enum PgTextSize {
  normal(1.0),
  large(1.15),
  extraLarge(1.3);

  const PgTextSize(this.factor);
  final double factor;

  /// Wrap the app in a MediaQuery with this scaler to apply the setting.
  TextScaler scalerOver(TextScaler system) =>
      TextScaler.linear(system.scale(100) / 100 * factor);
}

/// One step of the type scale.
@immutable
class PgTypeStep {
  const PgTypeStep({
    required this.size,
    required this.weight,
    required this.latinHeight,
    required this.indicHeight,
    this.heading = false,
    this.indicSize,
  });

  final double size;
  final FontWeight weight;

  /// Line height as a multiple of the font size.
  final double latinHeight;

  /// Taller, because vowel signs and stacked consonants reach above and
  /// below the line in Telugu, Kannada and Malayalam.
  final double indicHeight;

  /// True for styles set in the heading family (Anek).
  final bool heading;

  /// Size override for Indic scripts, where the smallest sizes get harder
  /// to read sooner than Latin does.
  final double? indicSize;

  TextStyle resolve(PgScript script, Color color) {
    final indic = script.isIndic;
    return TextStyle(
      fontFamily: heading ? script.heading : script.body,
      fontFamilyFallback: script.fallback,
      fontSize: indic ? (indicSize ?? size) : size,
      fontWeight: weight,
      height: indic ? indicHeight : latinHeight,
      // Never letter-space Indic text: it pulls conjuncts apart.
      letterSpacing: 0,
      color: color,
      leadingDistribution: TextLeadingDistribution.even,
    );
  }
}

/// The type scale. Only two weights are used: 400 and 600.
abstract final class PgType {
  static const display = PgTypeStep(
    size: 32,
    weight: FontWeight.w600,
    latinHeight: 1.25,
    indicHeight: 1.40,
    heading: true,
  );
  static const headline = PgTypeStep(
    size: 24,
    weight: FontWeight.w600,
    latinHeight: 1.30,
    indicHeight: 1.45,
    heading: true,
  );
  static const title = PgTypeStep(
    size: 20,
    weight: FontWeight.w600,
    latinHeight: 1.40,
    indicHeight: 1.50,
    heading: true,
  );
  static const titleSmall = PgTypeStep(
    size: 16,
    weight: FontWeight.w600,
    latinHeight: 1.50,
    indicHeight: 1.60,
  );
  static const body = PgTypeStep(
    size: 16,
    weight: FontWeight.w400,
    latinHeight: 1.50,
    indicHeight: 1.65,
  );
  static const bodySmall = PgTypeStep(
    size: 14,
    weight: FontWeight.w400,
    latinHeight: 1.45,
    indicHeight: 1.60,
  );
  static const label = PgTypeStep(
    size: 16,
    weight: FontWeight.w600,
    latinHeight: 1.50,
    indicHeight: 1.60,
  );
  static const labelSmall = PgTypeStep(
    size: 14,
    weight: FontWeight.w600,
    latinHeight: 1.45,
    indicHeight: 1.60,
  );
  static const caption = PgTypeStep(
    size: 12,
    indicSize: 13,
    weight: FontWeight.w400,
    latinHeight: 1.35,
    indicHeight: 1.55,
  );
  static const navLabel = PgTypeStep(
    size: 12,
    indicSize: 13,
    weight: FontWeight.w600,
    latinHeight: 1.35,
    indicHeight: 1.45,
  );

  /// Width axis for Anek, for tab labels that would otherwise wrap.
  /// Apply with `style.copyWith(fontVariations: PgType.condensed)` to
  /// heading-family text only; Noto Sans Indic fonts have no width axis
  /// in the builds we bundle.
  static const List<FontVariation> condensed = [FontVariation('wdth', 87.5)];
}

/// Builds the Material [TextTheme] for a script.
///
/// Slot mapping:
/// headlineLarge = display, headlineMedium = headline, titleLarge = title,
/// titleMedium = titleSmall, bodyLarge = body, bodyMedium = bodySmall,
/// labelLarge = label, labelMedium = labelSmall, bodySmall = caption,
/// labelSmall = navLabel.
TextTheme pgTextTheme(PgScript script, ColorScheme scheme) {
  final strong = scheme.onSurface;
  final muted = scheme.onSurfaceVariant;
  return TextTheme(
    displayLarge: PgType.display.resolve(script, strong),
    displayMedium: PgType.display.resolve(script, strong),
    displaySmall: PgType.display.resolve(script, strong),
    headlineLarge: PgType.display.resolve(script, strong),
    headlineMedium: PgType.headline.resolve(script, strong),
    headlineSmall: PgType.headline.resolve(script, strong),
    titleLarge: PgType.title.resolve(script, strong),
    titleMedium: PgType.titleSmall.resolve(script, strong),
    titleSmall: PgType.labelSmall.resolve(script, strong),
    bodyLarge: PgType.body.resolve(script, strong),
    bodyMedium: PgType.bodySmall.resolve(script, muted),
    bodySmall: PgType.caption.resolve(script, muted),
    labelLarge: PgType.label.resolve(script, strong),
    labelMedium: PgType.labelSmall.resolve(script, strong),
    labelSmall: PgType.navLabel.resolve(script, muted),
  );
}
