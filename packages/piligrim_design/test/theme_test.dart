import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piligrim_design/piligrim_design.dart';

double _channel(double c) =>
    c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();

double _luminance(Color c) =>
    0.2126 * _channel(c.r) + 0.7152 * _channel(c.g) + 0.0722 * _channel(c.b);

/// WCAG 2 contrast ratio.
double contrast(Color a, Color b) {
  final la = _luminance(a), lb = _luminance(b);
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

void main() {
  group('contrast', () {
    void checkScheme(String name, ColorScheme s, PgPalette p) {
      final textPairs = <String, (Color, Color)>{
        'onPrimary/primary': (s.onPrimary, s.primary),
        'onPrimaryContainer/primaryContainer': (
          s.onPrimaryContainer,
          s.primaryContainer,
        ),
        'onSecondary/secondary': (s.onSecondary, s.secondary),
        'onSecondaryContainer/secondaryContainer': (
          s.onSecondaryContainer,
          s.secondaryContainer,
        ),
        'onTertiary/tertiary': (s.onTertiary, s.tertiary),
        'onTertiaryContainer/tertiaryContainer': (
          s.onTertiaryContainer,
          s.tertiaryContainer,
        ),
        'onError/error': (s.onError, s.error),
        'onErrorContainer/errorContainer': (
          s.onErrorContainer,
          s.errorContainer,
        ),
        'onSurface/surface': (s.onSurface, s.surface),
        'onSurface/card': (s.onSurface, p.card),
        'onSurfaceVariant/surface': (s.onSurfaceVariant, s.surface),
        'onSurfaceVariant/card': (s.onSurfaceVariant, p.card),
        'onSurfaceVariant/surfaceContainer': (
          s.onSurfaceVariant,
          s.surfaceContainer,
        ),
        'primary/surface': (s.primary, s.surface),
        'primary/card': (s.primary, p.card),
        'primary/primaryContainer (nav label)': (s.primary, s.primaryContainer),
        'error/surface': (s.error, s.surface),
        'accentText/surface': (p.accentText, s.surface),
        'accentText/card': (p.accentText, p.card),
        'onDayKept/dayKept': (p.onDayKept, p.dayKept),
        'onDayPartial/dayPartial': (p.onDayPartial, p.dayPartial),
        'onBanner/banner': (p.onBanner, p.banner),
        'onInverseSurface/inverseSurface': (
          s.onInverseSurface,
          s.inverseSurface,
        ),
      };
      textPairs.forEach((label, pair) {
        test('$name $label is at least 4.5:1', () {
          expect(contrast(pair.$1, pair.$2), greaterThanOrEqualTo(4.5));
        });
      });

      final shapePairs = <String, (Color, Color)>{
        'outline/surface': (s.outline, s.surface),
        'outline/card': (s.outline, p.card),
        'dayToday/surface': (p.dayToday, s.surface),
        'dayKept/card': (p.dayKept, p.card),
      };
      shapePairs.forEach((label, pair) {
        test('$name $label is at least 3:1', () {
          expect(contrast(pair.$1, pair.$2), greaterThanOrEqualTo(3.0));
        });
      });
    }

    checkScheme('light', PgColorSchemes.light, PgPalette.light);
    checkScheme('dark', PgColorSchemes.dark, PgPalette.dark);
  });

  group('typography', () {
    test('every supported locale maps to its own script', () {
      expect(PgScript.fromLocale(const Locale('te')), PgScript.telugu);
      expect(PgScript.fromLocale(const Locale('ta')), PgScript.tamil);
      expect(PgScript.fromLocale(const Locale('kn')), PgScript.kannada);
      expect(PgScript.fromLocale(const Locale('ml')), PgScript.malayalam);
      expect(PgScript.fromLocale(const Locale('en')), PgScript.latin);
      expect(PgScript.fromLocale(const Locale('hi')), PgScript.latin);
    });

    test('Indic text is never smaller than 13 and never letter-spaced', () {
      for (final script in PgScript.values.where((s) => s.isIndic)) {
        final theme = pgTextTheme(script, PgColorSchemes.light);
        for (final style in [
          theme.headlineLarge,
          theme.headlineMedium,
          theme.titleLarge,
          theme.titleMedium,
          theme.titleSmall,
          theme.bodyLarge,
          theme.bodyMedium,
          theme.bodySmall,
          theme.labelLarge,
          theme.labelMedium,
          theme.labelSmall,
        ]) {
          expect(style!.fontSize, greaterThanOrEqualTo(13));
          expect(style.letterSpacing, 0);
          expect(style.height, greaterThanOrEqualTo(1.4));
        }
      }
    });

    test('headings use Anek and body uses Noto Sans, per script', () {
      final theme = pgTextTheme(PgScript.telugu, PgColorSchemes.light);
      expect(theme.titleLarge!.fontFamily, 'Anek Telugu');
      expect(theme.bodyLarge!.fontFamily, 'Noto Sans Telugu');
      expect(theme.bodyLarge!.fontFamilyFallback, contains('Noto Sans'));
    });

    test('text size setting multiplies the system scale', () {
      final scaler = PgTextSize.extraLarge.scalerOver(
        const TextScaler.linear(1.5),
      );
      expect(scaler.scale(10), closeTo(19.5, 0.001));
    });
  });

  group('theme', () {
    for (final locale in pgSupportedLocales) {
      testWidgets('builds and renders for ${locale.languageCode}', (
        tester,
      ) async {
        for (final theme in [
          PiligrimTheme.light(locale),
          PiligrimTheme.dark(locale),
        ]) {
          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Builder(
                builder: (context) => Scaffold(
                  appBar: AppBar(
                    title: Text(pgLanguageNames[locale.languageCode]!),
                  ),
                  body: Column(
                    children: [
                      FilledButton(
                        onPressed: () {},
                        child: const Text('Check in'),
                      ),
                      FilledButton(
                        style: PiligrimTheme.accentButton(context),
                        onPressed: () {},
                        child: const Text('Keeper'),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('All kept'),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Not now'),
                      ),
                      Card(
                        child: CheckboxListTile(
                          value: true,
                          onChanged: (_) {},
                          title: const Text('Vow'),
                        ),
                      ),
                      const TextField(),
                    ],
                  ),
                  bottomNavigationBar: NavigationBar(
                    destinations: const [
                      NavigationDestination(
                        icon: Icon(Icons.wb_sunny_outlined),
                        label: 'Today',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.menu_book_outlined),
                        label: 'Journey',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.groups_outlined),
                        label: 'Group',
                      ),
                      NavigationDestination(
                        icon: Icon(Icons.explore_outlined),
                        label: 'Guide',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);

          final button = tester.getSize(find.byType(FilledButton).first);
          expect(button.height, greaterThanOrEqualTo(PgSizes.button));
          expect(
            PgPalette.of(tester.element(find.byType(Scaffold))),
            isNotNull,
          );
        }
      });
    }
  });
}
