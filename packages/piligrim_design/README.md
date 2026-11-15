# piligrim_design

Theme tokens and `ThemeData` for the Piligrim Flutter app. Visual reference: the
"Piligrim UX and design system" canvas (https://claude.ai/artifact/RGPZdZ5CstyqBYmbz51VXn).
Screen-by-screen behaviour: `../ux-spec.md`.

## Use

Copy this folder into the app repo (suggested path `packages/piligrim_design`) and add
it as a path dependency.

```dart
import 'package:piligrim_design/piligrim_design.dart';

MaterialApp(
  theme: PiligrimTheme.light(locale),
  darkTheme: PiligrimTheme.dark(locale),
  supportedLocales: pgSupportedLocales,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: textSizeSetting.scalerOver(MediaQuery.textScalerOf(context)),
    ),
    child: child!,
  ),
);
```

Rebuild the theme when the locale changes: fonts and line heights depend on the script.

| Need | Read it from |
| --- | --- |
| Colors with a Material slot | `Theme.of(context).colorScheme` |
| Day states, card ground, banner, gold text | `PgPalette.of(context)` |
| Text styles | `Theme.of(context).textTheme` (slot mapping in `typography.dart`) |
| Spacing, radius, sizes, elevation, motion | `PgSpacing`, `PgRadius`, `PgSizes`, `PgElevation`, `PgMotion` |
| Gold and destructive buttons | `PiligrimTheme.accentButton(context)`, `PiligrimTheme.destructiveButton(context)` |
| Rive input names | `PgCompanionInputs` (the character thread owns the final contract) |

Note: `colorScheme.surface` is the page ground (ash white). Cards and tiles sit on
`PgPalette.card` (white in light mode).

## Rules the tokens encode

- Primary actions are 56 high and every target is at least 48. Button height is a
  minimum, so a two-line Tamil or Malayalam label fits. Never set a fixed button width.
- A missed day is a dashed outline (`dayOpen`), never red. `colorScheme.error` is for
  errors and "Delete my account" only.
- Deepam gold (`secondary`) is a fill with dark text. It fails contrast as text or a thin
  icon on a light ground. For gold text use `PgPalette.accentText`.
- Indic text: no letter spacing, no all-caps, no italics, nothing under 13, weights 400
  and 600 only.
- Design every screen to hold at a combined text scale of 2.0 (phone setting times the
  in-app `PgTextSize`).

## Fonts

Not bundled yet. Download the variable fonts from Google Fonts (all SIL Open Font
License), put them in `assets/fonts/`, and declare them. Bundle them as assets so text
renders offline; do not fetch fonts at runtime.

```yaml
flutter:
  fonts:
    - family: Anek Latin
      fonts: [{asset: assets/fonts/AnekLatin-VariableFont_wdth,wght.ttf}]
    - family: Anek Telugu
      fonts: [{asset: assets/fonts/AnekTelugu-VariableFont_wdth,wght.ttf}]
    - family: Anek Tamil
      fonts: [{asset: assets/fonts/AnekTamil-VariableFont_wdth,wght.ttf}]
    - family: Anek Kannada
      fonts: [{asset: assets/fonts/AnekKannada-VariableFont_wdth,wght.ttf}]
    - family: Anek Malayalam
      fonts: [{asset: assets/fonts/AnekMalayalam-VariableFont_wdth,wght.ttf}]
    - family: Noto Sans
      fonts: [{asset: assets/fonts/NotoSans-VariableFont_wdth,wght.ttf}]
    - family: Noto Sans Telugu
      fonts: [{asset: assets/fonts/NotoSansTelugu-VariableFont_wdth,wght.ttf}]
    - family: Noto Sans Tamil
      fonts: [{asset: assets/fonts/NotoSansTamil-VariableFont_wdth,wght.ttf}]
    - family: Noto Sans Kannada
      fonts: [{asset: assets/fonts/NotoSansKannada-VariableFont_wdth,wght.ttf}]
    - family: Noto Sans Malayalam
      fonts: [{asset: assets/fonts/NotoSansMalayalam-VariableFont_wdth,wght.ttf}]
```

File names above are the usual Google Fonts download names; confirm them when you
download. Not yet measured: the total size of the ten files against the 40 MB base
download budget. If it is too large, keep Latin plus the chosen language in the base
and deliver the rest with the language packs (Play Asset Delivery).

## Checked

`flutter analyze` and `flutter test` on Flutter 3.50.0 stable (Dart 3.14.0): 63 tests
pass, no errors or warnings. The tests cover contrast for every text pair in both
schemes, the Indic type rules, and a render of the themed core widgets in all five
locales. They do not render real glyphs, since the fonts are not bundled, so line
heights and label fit still need a check on a device with the fonts in place.

The analyzer reports one info, once per file: on Flutter 3.50, `package:flutter/material.dart` is
deprecated in favour of `package:material_ui/material_ui.dart`. The import is left as
is so the package works on older SDKs. The tech lead should switch it once the app's
Flutter version is pinned.
