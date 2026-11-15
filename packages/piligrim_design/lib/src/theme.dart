// Piligrim ThemeData. Use:
//
//   MaterialApp(
//     theme: PiligrimTheme.light(locale),
//     darkTheme: PiligrimTheme.dark(locale),
//     supportedLocales: pgSupportedLocales,
//   )
//
// Rebuild the theme when the locale changes, because fonts and line
// heights depend on the script.

import 'package:material_ui/material_ui.dart';

import 'tokens.dart';
import 'typography.dart';

abstract final class PiligrimTheme {
  static ThemeData light(Locale locale) => _build(
    PgColorSchemes.light,
    PgPalette.light,
    PgScript.fromLocale(locale),
  );

  static ThemeData dark(Locale locale) =>
      _build(PgColorSchemes.dark, PgPalette.dark, PgScript.fromLocale(locale));

  static ThemeData _build(
    ColorScheme scheme,
    PgPalette palette,
    PgScript script,
  ) {
    final text = pgTextTheme(script, scheme);
    const buttonShape = RoundedRectangleBorder(borderRadius: PgRadius.lgAll);
    // Height is a minimum, so a two-line Tamil or Malayalam label fits.
    const buttonSize = Size(PgSizes.minTouch, PgSizes.button);
    const buttonPadding = EdgeInsets.symmetric(
      horizontal: PgSpacing.lg,
      vertical: PgSpacing.xs,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      textTheme: text,
      fontFamily: script.body,
      fontFamilyFallback: script.fallback,
      extensions: [palette],
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: PgElevation.flat,
        scrolledUnderElevation: PgElevation.flat,
        centerTitle: false,
        titleTextStyle: text.titleLarge?.copyWith(color: scheme.primary),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          textStyle: text.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: buttonSize,
          padding: buttonPadding,
          shape: buttonShape,
          foregroundColor: scheme.primary,
          side: BorderSide(
            color: scheme.primary,
            width: PgSizes.emphasisOutlineWidth,
          ),
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(PgSizes.minTouch, PgSizes.minTouch),
          padding: const EdgeInsets.symmetric(horizontal: PgSpacing.sm),
          shape: buttonShape,
          textStyle: text.labelLarge,
        ),
      ),
      cardTheme: CardThemeData(
        color: palette.card,
        elevation: PgElevation.flat,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: PgRadius.lgAll,
          side: BorderSide(
            color: scheme.outlineVariant,
            width: PgSizes.outlineWidth,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        minTileHeight: PgSizes.tile,
        contentPadding: const EdgeInsets.symmetric(horizontal: PgSpacing.md),
        shape: const RoundedRectangleBorder(borderRadius: PgRadius.mdAll),
        titleTextStyle: text.bodyLarge,
        subtitleTextStyle: text.bodyMedium,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        side: BorderSide(color: scheme.outline, width: 2),
        // A kept vow is forest green, not the primary indigo.
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? palette.dayKept
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(palette.onDayKept),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.card,
        selectedColor: scheme.primaryContainer,
        side: BorderSide(
          color: scheme.outline,
          width: PgSizes.emphasisOutlineWidth,
        ),
        shape: const StadiumBorder(),
        labelStyle: text.bodyMedium?.copyWith(color: scheme.onSurface),
        padding: const EdgeInsets.symmetric(
          horizontal: PgSpacing.sm,
          vertical: PgSpacing.xs,
        ),
        showCheckmark: false,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.card,
        contentPadding: const EdgeInsets.all(PgSpacing.md),
        hintStyle: text.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: PgRadius.smAll,
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: PgRadius.smAll,
          borderSide: BorderSide(
            color: scheme.outline,
            width: PgSizes.emphasisOutlineWidth,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: PgRadius.smAll,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: PgSizes.navBar,
        backgroundColor: palette.card,
        elevation: PgElevation.navBar,
        indicatorColor: scheme.primaryContainer,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => text.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? scheme.primary
                : scheme.onSurfaceVariant,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: PgSizes.icon,
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: palette.card,
        elevation: PgElevation.sheet,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: PgRadius.sheetTop),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: palette.card,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(PgRadius.xl)),
        ),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyLarge,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: scheme.onInverseSurface,
        ),
        shape: const RoundedRectangleBorder(borderRadius: PgRadius.mdAll),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: PgSizes.outlineWidth,
        space: PgSizes.outlineWidth,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        circularTrackColor: scheme.primaryContainer,
        linearTrackColor: scheme.primaryContainer,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
    );
  }

  /// The gold "accent" button style, for celebration and the Keeper plan.
  /// Use as `FilledButton(style: PiligrimTheme.accentButton(context), ...)`.
  static ButtonStyle accentButton(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilledButton.styleFrom(
      backgroundColor: scheme.secondary,
      foregroundColor: scheme.onSecondary,
    );
  }

  /// The destructive button style. Only for "Delete my account".
  static ButtonStyle destructiveButton(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return FilledButton.styleFrom(
      backgroundColor: scheme.error,
      foregroundColor: scheme.onError,
    );
  }
}
