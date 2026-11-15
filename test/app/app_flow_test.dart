import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:piligrim/app/app.dart';
import 'package:piligrim/app/companion_sync.dart';
import 'package:piligrim/core/companion/still_companion_controller.dart';
import 'package:piligrim/app/providers.dart';
import 'package:piligrim/core/db/database.dart';
import 'package:piligrim/core/db/settings_repository.dart';

import '../support/test_content.dart';
import '../support/test_database.dart';

void main() {
  late AppDatabase db;
  var now = DateTime(2027, 11, 16, 5, 30);

  setUp(() {
    db = openTestDatabase();
    now = DateTime(2027, 11, 16, 5, 30);
  });

  tearDown(() => db.close());

  Future<void> pumpApp(
    WidgetTester tester, {
    DiskContentSource? content,
    String? packId,
  }) async {
    // A tall phone, so the whole check-in is on screen.
    await tester.binding.setSurfaceSize(const Size(412, 1400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          contentSourceProvider.overrideWithValue(
            content ?? DiskContentSource(),
          ),
          clockProvider.overrideWithValue(() => now),
          if (packId != null) packIdProvider.overrideWithValue(packId),
        ],
        child: const PiligrimApp(),
      ),
    );
    await settle(tester);
  }

  StillCompanionController companion(WidgetTester tester) =>
      ProviderScope.containerOf(tester.element(find.byType(PiligrimApp)))
          .read(companionControllerProvider);

  testWidgets('a new devotee picks Telugu, begins and checks in', (
    tester,
  ) async {
    await pumpApp(tester);

    // Language first, each in its own script.
    expect(find.text('Choose your language'), findsOneWidget);
    for (final name in ['తెలుగు', 'தமிழ்', 'ಕನ್ನಡ', 'മലയാളം', 'English']) {
      expect(find.text(name), findsOneWidget);
    }
    await tester.tap(find.text('తెలుగు'));
    await settle(tester);

    // The start screen is now in Telugu, defaulting to 41 days from today.
    expect(find.text('మీ దీక్షను ప్రారంభించండి'), findsOneWidget);
    expect(find.text('41 రోజులు'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('begin-journey')));
    await settle(tester);

    // Today: day 1 of 41, a milestone, the draft notice and six vows.
    expect(find.text('41 రోజులలో 1వ రోజు'), findsOneWidget);
    expect(find.text('ఈ రోజు: మాల ధారణ'), findsOneWidget);
    expect(find.textContaining('ముసాయిదా'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNWidgets(6));

    final vow = find.byKey(const ValueKey('vow-sattvic_food'));
    await tester.ensureVisible(vow);
    expect(tester.widget<CheckboxListTile>(vow).value, isFalse);
    await tester.tap(vow);
    await settle(tester);
    expect(tester.widget<CheckboxListTile>(vow).value, isTrue);

    // The check-in is on disk, not just on screen.
    final checks = await db.select(db.vowChecks).get();
    expect(checks.single.vowId, 'sattvic_food');
    expect(checks.single.kept, isTrue);

    // The companion follows today's vows: one of six so far.
    expect(companion(tester).currentDayProgress, closeTo(100 / 6, 0.01));
    expect(companion(tester).pose, isNot(CompanionPose.celebrate));

    // Ticking the rest completes the day, and the companion celebrates.
    for (final id in [
      'morning_bath_pooja',
      'evening_pooja',
      'no_intoxicants',
      'brahmacharya',
      'kind_speech',
    ]) {
      await tester.tap(find.byKey(ValueKey('vow-$id')));
      await settle(tester);
    }
    expect(companion(tester).currentDayProgress, 100);
    expect(companion(tester).pose, CompanionPose.celebrate);

    // The Journey Book, inside the Journey tab, counts the day.
    await tester.tap(find.text('యాత్ర'));
    await settle(tester);
    await tester.tap(find.byTooltip('యాత్ర పుస్తకం'));
    await settle(tester);
    expect(find.text('1 రోజు నమోదైంది'), findsOneWidget);
  });

  testWidgets('a returning devotee lands on Today in their language', (
    tester,
  ) async {
    await SettingsRepository(db).write(SettingsRepository.localeKey, 'ta');
    await pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('begin-journey')));
    await settle(tester);
    expect(find.text('41 நாட்களில் 1ஆம் நாள்'), findsOneWidget);
    expect(companion(tester).pose, CompanionPose.greet);

    // Two days later, with nothing recorded yesterday: comfort, not blame.
    now = DateTime(2027, 11, 18, 5, 30);
    await tester.pumpWidget(const SizedBox());
    await pumpApp(tester);
    expect(find.text('41 நாட்களில் 3ஆம் நாள்'), findsOneWidget);
    expect(
      find.text('நேற்று கடந்துவிட்டது. இன்று ஒரு புதிய நாள்.'),
      findsOneWidget,
    );
    expect(companion(tester).pose, CompanionPose.comfort);
  });

  testWidgets('deleting data returns to the start screen', (tester) async {
    await SettingsRepository(db).write(SettingsRepository.localeKey, 'en');
    await pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('begin-journey')));
    await settle(tester);
    expect(find.text('Day 1 of 41'), findsOneWidget);

    await tester.tap(find.byTooltip('Settings'));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('delete-data')));
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('delete-confirm')));
    await settle(tester);

    expect(find.text('Begin your deeksha'), findsOneWidget);
    expect(await db.select(db.journeys).get(), isEmpty);
  });

  testWidgets('prayers open offline from the content pack', (tester) async {
    await SettingsRepository(db).write(SettingsRepository.localeKey, 'en');
    await pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('begin-journey')));
    await settle(tester);

    await tester.tap(find.text('Guide'));
    await settle(tester);
    await tester.tap(find.text('Saranam chant (sample)'));
    await settle(tester);
    expect(find.text('Swamiye Saranam Ayyappa'), findsOneWidget);
  });

  testWidgets('a different observance runs with no code change', (
    tester,
  ) async {
    await SettingsRepository(db).write(SettingsRepository.localeKey, 'en');
    await pumpApp(
      tester,
      content: DiskContentSource.fixtures(),
      packId: 'sample_fast',
    );

    expect(find.text('7 days'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('begin-journey')));
    await settle(tester);

    expect(find.text('Sample fast'), findsOneWidget);
    expect(find.text('Day 1 of 7'), findsOneWidget);
    expect(find.text('Fast until sunset'), findsOneWidget);
    expect(find.text('Give alms'), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNWidgets(2));
    expect(
      find.textContaining('Draft content'),
      findsNothing,
      reason: 'this pack is marked approved',
    );
    final journey = await db.select(db.journeys).getSingle();
    expect(journey.templateId, 'sample_fast');
  });

  testWidgets('the Group tab says groups are coming', (tester) async {
    await SettingsRepository(db).write(SettingsRepository.localeKey, 'en');
    await pumpApp(tester);
    await tester.tap(find.byKey(const ValueKey('begin-journey')));
    await settle(tester);
    await tester.tap(find.text('Group'));
    await settle(tester);
    expect(
      find.textContaining('Guruswami groups are coming soon'),
      findsOneWidget,
    );
  });
}

/// Lets database streams and route changes land. `pumpAndSettle` is not
/// used because the splash spinner never settles on its own.
Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 12; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}
