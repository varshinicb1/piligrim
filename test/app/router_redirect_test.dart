import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piligrim/app/router.dart';
import 'package:piligrim/core/db/database.dart';
import 'package:piligrim/core/vow_engine/vow_engine.dart';

void main() {
  final journey = Journey(
    id: 'j',
    templateId: 't',
    templateVersion: '1',
    startDate: const LocalDate(2027, 11, 16),
    plannedDays: 41,
    status: JourneyStatus.active,
    createdAt: DateTime(2027),
    updatedAt: DateTime(2027),
  );
  const noLocale = AsyncData<Locale?>(null);
  const telugu = AsyncData<Locale?>(Locale('te'));
  const noJourney = AsyncData<Journey?>(null);
  final hasJourney = AsyncData<Journey?>(journey);

  String? redirect(
    String location,
    AsyncValue<Locale?> locale,
    AsyncValue<Journey?> journey,
  ) => redirectFor(location: location, locale: locale, journey: journey);

  test('waits on the splash screen while the database opens', () {
    expect(
      redirect(Routes.today, const AsyncLoading(), const AsyncLoading()),
      Routes.splash,
    );
    expect(redirect(Routes.splash, telugu, const AsyncLoading()), isNull);
  });

  test('stays on the splash screen if the database cannot be opened', () {
    expect(
      redirect(
        Routes.today,
        telugu,
        AsyncError<Journey?>(StateError('x'), StackTrace.empty),
      ),
      Routes.splash,
    );
  });

  test('asks for a language first', () {
    expect(redirect(Routes.splash, noLocale, noJourney), Routes.language);
    expect(redirect(Routes.today, noLocale, hasJourney), Routes.language);
    expect(redirect(Routes.language, noLocale, noJourney), isNull);
  });

  test('then asks to begin a journey', () {
    expect(redirect(Routes.language, telugu, noJourney), Routes.startJourney);
    expect(redirect(Routes.splash, telugu, noJourney), Routes.startJourney);
    expect(redirect(Routes.today, telugu, noJourney), Routes.startJourney);
    expect(redirect(Routes.guide, telugu, noJourney), Routes.startJourney);
    expect(redirect(Routes.startJourney, telugu, noJourney), isNull);
  });

  test('settings stay reachable before a journey begins', () {
    expect(redirect(Routes.settings, telugu, noJourney), isNull);
  });

  test('an active journey lands on Today and leaves onboarding', () {
    expect(redirect(Routes.splash, telugu, hasJourney), Routes.today);
    expect(redirect(Routes.startJourney, telugu, hasJourney), Routes.today);
    expect(redirect(Routes.journey, telugu, hasJourney), isNull);
    expect(redirect(Routes.prayer('x'), telugu, hasJourney), isNull);
  });
}
