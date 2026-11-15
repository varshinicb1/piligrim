import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:piligrim/core/content/content_pack.dart';
import 'package:piligrim/core/content/content_repository.dart';
import 'package:piligrim/core/l10n/languages.dart';

import '../../support/test_content.dart';

void main() {
  final repository = ContentRepository(DiskContentSource());

  test('the bundled Ayyappa pack loads as a 41 to 60 day observance', () async {
    final pack = await repository.loadPack('ayyappa_deeksha');
    expect(pack.template.minDays, 41);
    expect(pack.template.defaultDays, 41);
    expect(pack.template.maxDays, 60);
    expect(pack.template.vows, isNotEmpty);
    expect(pack.isVetted, isFalse, reason: 'not yet reviewed by Guruswamis');
  });

  test('the pack covers every app language', () async {
    final pack = await repository.loadPack('ayyappa_deeksha');
    expect(pack.languages.toSet(), {for (final l in appLanguages) l.code});
  });

  test('every language has wording for every vow and milestone', () async {
    final pack = await repository.loadPack('ayyappa_deeksha');
    final keys = [
      'template.title',
      for (final vow in pack.template.vows) vow.titleKey,
      for (final milestone in pack.template.milestones) milestone.titleKey,
    ];
    for (final language in pack.languages) {
      final source = DiskContentSource();
      final raw = jsonDecode(
        await source.readText(pack.id, 'strings/$language.json'),
      ) as Map<String, dynamic>;
      for (final key in keys) {
        expect(raw[key], isA<String>(), reason: '$language is missing $key');
      }
    }
  });

  test('every prayer has a title and lines in the base language', () async {
    final pack = await repository.loadPack('ayyappa_deeksha');
    final strings = await repository.loadStrings(pack, 'en');
    for (final prayer in pack.prayers) {
      expect(strings.text(prayer.titleKey), isNot(prayer.titleKey));
      expect(strings.lines(prayer.linesKey), isNotEmpty);
    }
  });

  test('a translation falls back to the base language per key', () async {
    final pack = await repository.loadPack('ayyappa_deeksha');
    final telugu = await repository.loadStrings(pack, 'te');
    expect(telugu.text('template.title'), 'అయ్యప్ప దీక్ష');
    expect(telugu.lines('prayer.saranam_sample.lines'), isNotEmpty);
  });

  test('an unknown language falls back to the base language', () async {
    final pack = await repository.loadPack('ayyappa_deeksha');
    final strings = await repository.loadStrings(pack, 'hi');
    expect(strings.text('template.title'), 'Ayyappa Deeksha');
  });

  test('a missing key shows the key rather than a blank', () {
    const strings = PackStrings(primary: {}, fallback: {});
    expect(strings.text('vow.x.title'), 'vow.x.title');
    expect(strings.lines('prayer.x.lines'), isEmpty);
  });

  test('a different observance loads from data alone', () async {
    final fixtures = ContentRepository(DiskContentSource.fixtures());
    final pack = await fixtures.loadPack('sample_fast');
    expect(pack.template.defaultDays, 7);
    expect(pack.template.vows.map((vow) => vow.id), [
      'fast_until_sunset',
      'give_alms',
    ]);
    expect(pack.isVetted, isTrue);
    final strings = await fixtures.loadStrings(pack, 'te');
    expect(strings.text('vow.give_alms.title'), 'Give alms');
  });

  test('rejects a pack whose base language lacks wording', () async {
    final fixtures = ContentRepository(DiskContentSource.fixtures());
    final pack = await fixtures.loadPack('broken_pack');
    await expectLater(
      fixtures.loadStrings(pack, 'en'),
      throwsA(
        isA<FormatException>().having(
          (e) => e.message,
          'message',
          allOf(contains('vow.fast_until_sunset.title'), contains('midpoint')),
        ),
      ),
    );
  });

  test('refuses a pack written for a newer schema', () {
    expect(
      () => ContentPack.fromJson({'schemaVersion': 2}),
      throwsFormatException,
    );
  });
}
