import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:piligrim/core/db/database.dart';
import 'package:piligrim/core/db/encrypted_executor.dart';
import 'package:piligrim/core/db/journey_repository.dart';
import 'package:piligrim/core/vow_engine/vow_engine.dart';

void main() {
  late Directory directory;
  late File file;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('piligrim_db_test');
    file = File('${directory.path}/piligrim.db');
  });

  tearDown(() => directory.deleteSync(recursive: true));

  AppDatabase open(String key) => AppDatabase(
    NativeDatabase(file, setup: (db) => applyEncryptionKey(db, key)),
  );

  const template = ObservanceTemplate(
    id: 't',
    version: '1',
    tradition: 'test',
    minDays: 1,
    defaultDays: 41,
    maxDays: 60,
    vows: [],
    milestones: [],
    mascotTheme: 'none',
  );
  const secret = 'For my mother to recover';

  Future<void> writeJourney(String key) async {
    final db = open(key);
    await JourneyRepository(db, now: DateTime.now).startJourney(
      template: template,
      startDate: const LocalDate(2027, 11, 16),
      plannedDays: 41,
      sankalpam: secret,
    );
    await db.close();
  }

  test('generated keys are 64 hex characters and differ each time', () {
    final a = generateDatabaseKey();
    final b = generateDatabaseKey();
    expect(a, matches(RegExp(r'^[0-9a-f]{64}$')));
    expect(a, isNot(b));
  });

  test('the file on disk does not contain the devotee\'s words', () async {
    await writeJourney(generateDatabaseKey());
    final bytes = file.readAsBytesSync();
    final text = latin1.decode(bytes);
    expect(text, isNot(contains(secret)));
    expect(
      text.startsWith('SQLite format 3'),
      isFalse,
      reason: 'a plain SQLite header means the file is not encrypted',
    );
  });

  test('the same key reads the data back', () async {
    final key = generateDatabaseKey();
    await writeJourney(key);
    final db = open(key);
    final journey = await db.select(db.journeys).getSingle();
    expect(journey.sankalpam, secret);
    await db.close();
  });

  test('a different key cannot open the database', () async {
    await writeJourney(generateDatabaseKey());
    final db = open(generateDatabaseKey());
    await expectLater(db.select(db.journeys).get(), throwsA(anything));
    await db.close();
  });

  test('rejects a malformed key before touching the database', () {
    final db = open('not-a-key');
    expect(db.select(db.journeys).get(), throwsA(anything));
  });
}
