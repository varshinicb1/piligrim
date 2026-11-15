import 'package:flutter_test/flutter_test.dart';
import 'package:piligrim/core/content/content_repository.dart';
import 'package:piligrim/core/db/database.dart';
import 'package:piligrim/core/db/journey_repository.dart';
import 'package:piligrim/core/db/settings_repository.dart';
import 'package:piligrim/core/sync/outbox.dart';
import 'package:piligrim/core/vow_engine/vow_engine.dart';

import '../../support/test_content.dart';
import '../../support/test_database.dart';

void main() {
  late AppDatabase db;
  late JourneyRepository repository;
  late ObservanceTemplate template;
  const start = LocalDate(2027, 11, 16);
  DateTime now() => DateTime(2027, 11, 16, 6);

  setUp(() async {
    db = openTestDatabase();
    repository = JourneyRepository(db, now: now);
    template = (await ContentRepository(
      DiskContentSource(),
    ).loadPack('ayyappa_deeksha')).template;
  });

  tearDown(() => db.close());

  Future<Journey> startJourney() => repository.startJourney(
    template: template,
    startDate: start,
    plannedDays: 41,
    sankalpam: '  ',
  );

  test('there is no active journey on a fresh install', () async {
    expect(await repository.watchActiveJourney().first, isNull);
  });

  test('starting a journey makes it the active one', () async {
    final journey = await startJourney();
    final active = await repository.watchActiveJourney().first;
    expect(active?.id, journey.id);
    expect(active?.startDate, start);
    expect(active?.templateId, 'ayyappa_deeksha');
    expect(active?.sankalpam, isNull, reason: 'blank text is stored as null');
  });

  test('refuses a second active journey', () async {
    await startJourney();
    expect(startJourney, throwsStateError);
  });

  test('refuses a length the template does not allow', () {
    expect(
      () => repository.startJourney(
        template: template,
        startDate: start,
        plannedDays: 7,
      ),
      throwsArgumentError,
    );
  });

  test('a completed journey frees the way for the next one', () async {
    final first = await startJourney();
    await repository.setJourneyStatus(first.id, JourneyStatus.completed);
    expect(await repository.watchActiveJourney().first, isNull);
    await startJourney();
  });

  test('ticking and unticking vows is kept per day', () async {
    final journey = await startJourney();
    Future<void> tick(LocalDate date, String vow, bool kept) => repository
        .setVowKept(journeyId: journey.id, date: date, vowId: vow, kept: kept);

    await tick(start, 'sattvic_food', true);
    await tick(start, 'kind_speech', true);
    await tick(start, 'kind_speech', false);
    await tick(start.addDays(1), 'kind_speech', true);

    final entries = await repository.watchEntries(journey.id).first;
    expect(entries.map((e) => e.entry.date), [start, start.addDays(1)]);
    expect(entries[0].keptVowIds, {'sattvic_food'});
    expect(entries[1].keptVowIds, {'kind_speech'});
  });

  test('a note and vows for the same day share one entry', () async {
    final journey = await startJourney();
    await repository.saveNote(
      journeyId: journey.id,
      date: start,
      note: ' Walked to the temple at dawn. ',
    );
    await repository.setVowKept(
      journeyId: journey.id,
      date: start,
      vowId: 'evening_pooja',
      kept: true,
    );
    final entries = await repository.watchEntries(journey.id).first;
    expect(entries, hasLength(1));
    expect(entries.single.entry.note, 'Walked to the temple at dawn.');
    expect(entries.single.toRecord().hasReflection, isTrue);
  });

  test('a day with every vow unticked still appears, with none kept', () async {
    final journey = await startJourney();
    await repository.setVowKept(
      journeyId: journey.id,
      date: start,
      vowId: 'evening_pooja',
      kept: false,
    );
    final entries = await repository.watchEntries(journey.id).first;
    expect(entries.single.keptVowIds, isEmpty);
    expect(entries.single.toRecord().isCheckedIn, isFalse);
  });

  test('watchers see new entries as they are written', () async {
    final journey = await startJourney();
    final seen = <int>[];
    final sub = repository
        .watchEntries(journey.id)
        .listen((entries) => seen.add(entries.length));
    await pumpEventQueue();
    await repository.saveNote(journeyId: journey.id, date: start, note: 'x');
    await pumpEventQueue();
    await sub.cancel();
    expect(seen, [0, 1]);
  });

  test('deleting journey data removes everything but settings', () async {
    final journey = await startJourney();
    await repository.saveNote(journeyId: journey.id, date: start, note: 'x');
    await repository.setVowKept(
      journeyId: journey.id,
      date: start,
      vowId: 'evening_pooja',
      kept: true,
    );
    final settings = SettingsRepository(db);
    await settings.write(SettingsRepository.localeKey, 'te');

    await repository.deleteAllJourneyData();

    expect(await repository.watchActiveJourney().first, isNull);
    expect(await db.select(db.dayEntries).get(), isEmpty);
    expect(await db.select(db.vowChecks).get(), isEmpty);
    expect(await settings.read(SettingsRepository.localeKey), 'te');
  });

  test('deleting a journey row cascades to its days and vow checks', () async {
    final journey = await startJourney();
    await repository.setVowKept(
      journeyId: journey.id,
      date: start,
      vowId: 'evening_pooja',
      kept: true,
    );
    await db.delete(db.journeys).go();
    expect(await db.select(db.dayEntries).get(), isEmpty);
    expect(await db.select(db.vowChecks).get(), isEmpty);
  });

  group('outbox', () {
    test('nothing is queued while sync is off', () async {
      final journey = await startJourney();
      await repository.saveNote(journeyId: journey.id, date: start, note: 'x');
      expect(await db.select(db.outboxItems).get(), isEmpty);
    });

    test('every change is queued when sync is on', () async {
      final syncing = JourneyRepository(
        db,
        now: now,
        outbox: DatabaseOutbox(db, now: now),
      );
      final journey = await syncing.startJourney(
        template: template,
        startDate: start,
        plannedDays: 41,
      );
      await syncing.setVowKept(
        journeyId: journey.id,
        date: start,
        vowId: 'evening_pooja',
        kept: true,
      );
      await syncing.saveNote(journeyId: journey.id, date: start, note: 'x');
      final queued = await db.select(db.outboxItems).get();
      expect(queued.map((item) => item.entityType), [
        'journey',
        'vow_check',
        'day_entry',
      ]);
    });
  });

  test('settings overwrite by key', () async {
    final settings = SettingsRepository(db);
    expect(await settings.read('locale'), isNull);
    await settings.write('locale', 'ta');
    await settings.write('locale', 'ml');
    expect(await settings.read('locale'), 'ml');
  });
}
