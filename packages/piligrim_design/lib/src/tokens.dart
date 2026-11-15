// Piligrim design tokens. Source of truth for color, spacing, shape, size
// and motion. The visual reference is the "Piligrim UX and design system"
// canvas; tokens.json mirrors these values for the web surfaces.
//
// Do not use raw hex values or magic numbers in feature code. Read colors
// from Theme.of(context).colorScheme or PgPalette.of(context), and everything
// else from the classes below.

import 'package:material_ui/material_ui.dart';

/// Raw brand colors. Feature code should prefer [ColorScheme] and [PgPalette].
abstract final class PgColors {
  // Indigo: the dark cloth of the deeksha. Primary actions and navigation.
  static const indigo = Color(0xFF2A2D64);
  static const indigoContainer = Color(0xFFE3E4F7);
  static const onIndigoContainer = Color(0xFF1A1C45);

  // Deepam: lamp gold. A fill for celebration and the Keeper plan.
  // Never use as text or as a thin icon on a light ground (1.9:1).
  static const deepam = Color(0xFFF0A30A);
  static const onDeepam = Color(0xFF2B1B00);
  static const deepamContainer = Color(0xFFFFE9BF);
  static const onDeepamContainer = Color(0xFF4A3000);
  static const deepamText = Color(0xFF8A5A00); // gold-toned text, 5.4:1

  // Forest: the path to Sabarimala. Kept vows and success.
  static const forest = Color(0xFF2C6A4C);
  static const forestContainer = Color(0xFFD5EBDD);
  static const onForestContainer = Color(0xFF0F3D27);

  // Kumkum: errors and the delete-account action only. Never a missed day.
  static const kumkum = Color(0xFFB3261E);
  static const kumkumContainer = Color(0xFFFBE0DD);
  static const onKumkumContainer = Color(0xFF5C1410);

  // Neutrals: vibhuti ash white and ink.
  static const vibhuti = Color(0xFFF6F5F1);
  static const white = Color(0xFFFFFFFF);
  static const surfaceContainer = Color(0xFFEFEDE7);
  static const ink = Color(0xFF1B1B22);
  static const inkMuted = Color(0xFF5A5964);
  static const outline = Color(0xFF8A877F);
  static const outlineVariant = Color(0xFFD8D5CC);

  // Dark scheme.
  static const nightBackground = Color(0xFF101124);
  static const nightSurface = Color(0xFF191A33);
  static const nightSurfaceContainer = Color(0xFF222444);
  static const nightInk = Color(0xFFECEBF4);
  static const nightInkMuted = Color(0xFFB9B8C9);
  static const nightOutline = Color(0xFF8E8DA0);
  static const nightOutlineVariant = Color(0xFF3A3B5C);
  static const nightIndigo = Color(0xFFBFC3FF);
  static const onNightIndigo = Color(0xFF1B1E55);
  static const nightIndigoContainer = Color(0xFF363A7A);
  static const onNightIndigoContainer = Color(0xFFE1E3FF);
  static const nightDeepam = Color(0xFFFFC456);
  static const onNightDeepam = Color(0xFF3E2A00);
  static const nightDeepamContainer = Color(0xFF5B4000);
  static const onNightDeepamContainer = Color(0xFFFFE2A6);
  static const nightForest = Color(0xFF8FD3AC);
  static const onNightForest = Color(0xFF053822);
  static const nightForestContainer = Color(0xFF1D5038);
  static const onNightForestContainer = Color(0xFFBCEFD0);
  static const nightKumkum = Color(0xFFFFB4AB);
  static const onNightKumkum = Color(0xFF690005);
  static const nightKumkumContainer = Color(0xFF8C1D18);
  static const onNightKumkumContainer = Color(0xFFFFDAD6);
}

/// Material 3 color schemes built from [PgColors].
abstract final class PgColorSchemes {
  static const light = ColorScheme(
    brightness: Brightness.light,
    primary: PgColors.indigo,
    onPrimary: PgColors.white,
    primaryContainer: PgColors.indigoContainer,
    onPrimaryContainer: PgColors.onIndigoContainer,
    secondary: PgColors.deepam,
    onSecondary: PgColors.onDeepam,
    secondaryContainer: PgColors.deepamContainer,
    onSecondaryContainer: PgColors.onDeepamContainer,
    tertiary: PgColors.forest,
    onTertiary: PgColors.white,
    tertiaryContainer: PgColors.forestContainer,
    onTertiaryContainer: PgColors.onForestContainer,
    error: PgColors.kumkum,
    onError: PgColors.white,
    errorContainer: PgColors.kumkumContainer,
    onErrorContainer: PgColors.onKumkumContainer,
    surface: PgColors.vibhuti,
    onSurface: PgColors.ink,
    onSurfaceVariant: PgColors.inkMuted,
    surfaceContainerLowest: PgColors.white,
    surfaceContainerLow: PgColors.white,
    surfaceContainer: PgColors.surfaceContainer,
    surfaceContainerHigh: PgColors.surfaceContainer,
    surfaceContainerHighest: PgColors.outlineVariant,
    outline: PgColors.outline,
    outlineVariant: PgColors.outlineVariant,
    inverseSurface: PgColors.nightSurface,
    onInverseSurface: PgColors.nightInk,
    inversePrimary: PgColors.nightIndigo,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Color(0x00000000),
  );

  static const dark = ColorScheme(
    brightness: Brightness.dark,
    primary: PgColors.nightIndigo,
    onPrimary: PgColors.onNightIndigo,
    primaryContainer: PgColors.nightIndigoContainer,
    onPrimaryContainer: PgColors.onNightIndigoContainer,
    secondary: PgColors.nightDeepam,
    onSecondary: PgColors.onNightDeepam,
    secondaryContainer: PgColors.nightDeepamContainer,
    onSecondaryContainer: PgColors.onNightDeepamContainer,
    tertiary: PgColors.nightForest,
    onTertiary: PgColors.onNightForest,
    tertiaryContainer: PgColors.nightForestContainer,
    onTertiaryContainer: PgColors.onNightForestContainer,
    error: PgColors.nightKumkum,
    onError: PgColors.onNightKumkum,
    errorContainer: PgColors.nightKumkumContainer,
    onErrorContainer: PgColors.onNightKumkumContainer,
    surface: PgColors.nightBackground,
    onSurface: PgColors.nightInk,
    onSurfaceVariant: PgColors.nightInkMuted,
    surfaceContainerLowest: PgColors.nightBackground,
    surfaceContainerLow: PgColors.nightSurface,
    surfaceContainer: PgColors.nightSurfaceContainer,
    surfaceContainerHigh: PgColors.nightSurfaceContainer,
    surfaceContainerHighest: PgColors.nightOutlineVariant,
    outline: PgColors.nightOutline,
    outlineVariant: PgColors.nightOutlineVariant,
    inverseSurface: PgColors.vibhuti,
    onInverseSurface: PgColors.ink,
    inversePrimary: PgColors.indigo,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    surfaceTint: Color(0x00000000),
  );
}

/// Piligrim-specific colors that Material's [ColorScheme] has no slot for.
/// Read with `PgPalette.of(context)`.
@immutable
class PgPalette extends ThemeExtension<PgPalette> {
  const PgPalette({
    required this.card,
    required this.dayKept,
    required this.onDayKept,
    required this.dayPartial,
    required this.onDayPartial,
    required this.dayOpen,
    required this.dayToday,
    required this.dayAhead,
    required this.accentText,
    required this.banner,
    required this.onBanner,
  });

  /// Card and tile background (white on the vibhuti ground in light mode).
  final Color card;

  /// Day dot: every vow kept. Solid fill.
  final Color dayKept;
  final Color onDayKept;

  /// Day dot: some vows kept. Solid fill.
  final Color dayPartial;
  final Color onDayPartial;

  /// Day dot: past day with no entry. Dashed outline, never red.
  final Color dayOpen;

  /// Day dot: today. Thick ring.
  final Color dayToday;

  /// Day dot: future day. Thin outline.
  final Color dayAhead;

  /// Gold-toned text that still meets 4.5:1 on the ground.
  final Color accentText;

  /// Offline and information banner.
  final Color banner;
  final Color onBanner;

  static const light = PgPalette(
    card: PgColors.white,
    dayKept: PgColors.forest,
    onDayKept: PgColors.white,
    dayPartial: PgColors.deepam,
    onDayPartial: PgColors.onDeepam,
    dayOpen: PgColors.outline,
    dayToday: PgColors.indigo,
    dayAhead: PgColors.outlineVariant,
    accentText: PgColors.deepamText,
    banner: PgColors.deepamContainer,
    onBanner: PgColors.onDeepamContainer,
  );

  static const dark = PgPalette(
    card: PgColors.nightSurface,
    dayKept: PgColors.nightForest,
    onDayKept: PgColors.onNightForest,
    dayPartial: PgColors.nightDeepam,
    onDayPartial: PgColors.onNightDeepam,
    dayOpen: PgColors.nightOutline,
    dayToday: PgColors.nightIndigo,
    dayAhead: PgColors.nightOutlineVariant,
    accentText: PgColors.nightDeepam,
    banner: PgColors.nightDeepamContainer,
    onBanner: PgColors.onNightDeepamContainer,
  );

  static PgPalette of(BuildContext context) =>
      Theme.of(context).extension<PgPalette>() ?? light;

  @override
  PgPalette copyWith({
    Color? card,
    Color? dayKept,
    Color? onDayKept,
    Color? dayPartial,
    Color? onDayPartial,
    Color? dayOpen,
    Color? dayToday,
    Color? dayAhead,
    Color? accentText,
    Color? banner,
    Color? onBanner,
  }) {
    return PgPalette(
      card: card ?? this.card,
      dayKept: dayKept ?? this.dayKept,
      onDayKept: onDayKept ?? this.onDayKept,
      dayPartial: dayPartial ?? this.dayPartial,
      onDayPartial: onDayPartial ?? this.onDayPartial,
      dayOpen: dayOpen ?? this.dayOpen,
      dayToday: dayToday ?? this.dayToday,
      dayAhead: dayAhead ?? this.dayAhead,
      accentText: accentText ?? this.accentText,
      banner: banner ?? this.banner,
      onBanner: onBanner ?? this.onBanner,
    );
  }

  @override
  PgPalette lerp(ThemeExtension<PgPalette>? other, double t) {
    if (other is! PgPalette) return this;
    return PgPalette(
      card: Color.lerp(card, other.card, t)!,
      dayKept: Color.lerp(dayKept, other.dayKept, t)!,
      onDayKept: Color.lerp(onDayKept, other.onDayKept, t)!,
      dayPartial: Color.lerp(dayPartial, other.dayPartial, t)!,
      onDayPartial: Color.lerp(onDayPartial, other.onDayPartial, t)!,
      dayOpen: Color.lerp(dayOpen, other.dayOpen, t)!,
      dayToday: Color.lerp(dayToday, other.dayToday, t)!,
      dayAhead: Color.lerp(dayAhead, other.dayAhead, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      banner: Color.lerp(banner, other.banner, t)!,
      onBanner: Color.lerp(onBanner, other.onBanner, t)!,
    );
  }
}

/// Spacing on a 4-point grid, in logical pixels.
abstract final class PgSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
  static const double xxxl = 64;

  /// Left and right padding of every screen.
  static const double screen = md;

  /// Gap between cards in a list.
  static const double cardGap = sm;

  /// Gap between sections of a screen.
  static const double sectionGap = lg;
}

/// Corner radii.
abstract final class PgRadius {
  static const double sm = 8; // inputs
  static const double md = 12; // rows, tiles, banners
  static const double lg = 16; // cards, buttons
  static const double xl = 24; // sheets
  static const double full = 999; // pills, day dots

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius sheetTop = BorderRadius.vertical(
    top: Radius.circular(xl),
  );
}

/// Fixed sizes. Touch targets are sized for older Guruswamis.
abstract final class PgSizes {
  /// Smallest allowed touch target.
  static const double minTouch = 48;

  /// Height of primary, secondary and accent buttons. Buttons grow taller
  /// when a long Tamil or Malayalam label wraps to two lines.
  static const double button = 56;

  /// Minimum height of vow tiles, checklist tiles and setting rows.
  static const double tile = 56;

  static const double chip = 40;
  static const double icon = 24;
  static const double avatar = 40;
  static const double dayDot = 36;
  static const double dayRing = 128;
  static const double dayRingStroke = 12;
  static const double navBar = 72;
  static const double outlineWidth = 1;
  static const double emphasisOutlineWidth = 1.5;

  /// Content never grows wider than this on tablets and foldables.
  static const double maxContentWidth = 600;
}

/// Elevation. Cards are flat; only sheets and the nav bar are raised.
abstract final class PgElevation {
  static const double flat = 0;
  static const double navBar = 3;
  static const double sheet = 6;
}

/// Motion. Honour MediaQuery.disableAnimations: fall back to a fade.
abstract final class PgMotion {
  /// Presses, ticks.
  static const Duration fast = Duration(milliseconds: 120);

  /// Screen and sheet transitions.
  static const Duration base = Duration(milliseconds: 220);

  /// The day ring filling.
  static const Duration slow = Duration(milliseconds: 400);

  /// Length of the companion's celebrate animation (played by Rive).
  static const Duration celebrate = Duration(milliseconds: 1800);

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve standard = Curves.easeInOutCubic;
}

/// Names of the Rive state-machine inputs the companion exposes, as listed
/// in the architecture plan. The character thread owns the final contract.
abstract final class PgCompanionInputs {
  static const mood = 'mood';
  static const dayProgress = 'dayProgress';
  static const celebrate = 'celebrate';
  static const comfort = 'comfort';
  static const listening = 'listening';
  static const sleeping = 'sleeping';
}
