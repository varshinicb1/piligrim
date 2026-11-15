import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../sync/outbox.dart';
import '../vow_engine/vow_engine.dart';
import 'database.dart';

class DayEntryWithVows {
  const DayEntryWithVows({required this.entry, required this.keptVowIds});

  final DayEntry entry;
  final Set<String> keptVowIds;

  DayRecord toRecord() => DayRecord(
    date: entry.date,
    keptVowIds: keptVowIds,
    hasReflection: (entry.note ?? '').trim().isNotEmpty,
  );
}

/// All reads and writes of journeys and their days.
class JourneyRepository {
  JourneyRepository(
    this._db, {
    required this._now,
    this._outbox = const DisabledOutbox(),
    String Function()? newId,
  }) : _newId = newId ?? const Uuid().v4;

  final AppDatabase _db;
  final DateTime Function() _now;
  final Outbox _outbox;
  final String Function() _newId;

  SimpleSelectStatement<$JourneysTable, Journey> get _activeJourney =>
      _db.select(_db.journeys)
        ..where((j) => j.status.equalsValue(JourneyStatus.active))
        ..orderBy([(j) => OrderingTerm.desc(j.createdAt)])
        ..limit(1);

  Stream<Journey?> watchActiveJourney() => _activeJourney.watchSingleOrNull();

  /// Starts a journey. Only one journey can be active at a time.
  Future<Journey> startJourney({
    required ObservanceTemplate template,
    required LocalDate startDate,
    required int plannedDays,
    String? sankalpam,
    String? guideName,
  }) {
    if (!template.isValidLength(plannedDays)) {
      throw ArgumentError.value(
        plannedDays,
        'plannedDays',
        'Must be ${template.minDays} to ${template.maxDays} days',
      );
    }
    return _db.transaction(() async {
      final active = await _activeJourney.getSingleOrNull();
      if (active != null) {
        throw StateError('A journey is already active');
      }
      final now = _now();
      final journey = Journey(
        id: _newId(),
        templateId: template.id,
        templateVersion: template.version,
        startDate: startDate,
        plannedDays: plannedDays,
        sankalpam: _blankToNull(sankalpam),
        guideName: _blankToNull(guideName),
        status: JourneyStatus.active,
        createdAt: now,
        updatedAt: now,
      );
      await _db.into(_db.journeys).insert(journey);
      await _outbox.record(
        entityType: 'journey',
        entityId: journey.id,
        operation: 'upsert',
        payload: {
          'templateId': journey.templateId,
          'templateVersion': journey.templateVersion,
          'startDate': journey.startDate.toIso(),
          'plannedDays': journey.plannedDays,
          'sankalpam': journey.sankalpam,
          'guideName': journey.guideName,
          'status': journey.status.name,
          'updatedAt': now.toIso8601String(),
        },
      );
      return journey;
    });
  }

  Future<void> setJourneyStatus(String journeyId, JourneyStatus status) {
    return _db.transaction(() async {
      final now = _now();
      await (_db.update(
        _db.journeys,
      )..where((j) => j.id.equals(journeyId))).write(
        JourneysCompanion(status: Value(status), updatedAt: Value(now)),
      );
      await _outbox.record(
        entityType: 'journey',
        entityId: journeyId,
        operation: 'status',
        payload: {'status': status.name, 'updatedAt': now.toIso8601String()},
      );
    });
  }

  /// Every recorded day of a journey, oldest first.
  Stream<List<DayEntryWithVows>> watchEntries(String journeyId) {
    final query =
        _db.select(_db.dayEntries).join([
            leftOuterJoin(
              _db.vowChecks,
              _db.vowChecks.entryId.equalsExp(_db.dayEntries.id) &
                  _db.vowChecks.kept.equals(true),
            ),
          ])
          ..where(_db.dayEntries.journeyId.equals(journeyId))
          ..orderBy([OrderingTerm.asc(_db.dayEntries.date)]);

    return query.watch().map((rows) {
      final entries = <String, DayEntry>{};
      final kept = <String, Set<String>>{};
      for (final row in rows) {
        final entry = row.readTable(_db.dayEntries);
        entries[entry.id] = entry;
        final check = row.readTableOrNull(_db.vowChecks);
        final vows = kept.putIfAbsent(entry.id, () => <String>{});
        if (check != null) vows.add(check.vowId);
      }
      return [
        for (final entry in entries.values)
          DayEntryWithVows(entry: entry, keptVowIds: kept[entry.id]!),
      ];
    });
  }

  Future<void> setVowKept({
    required String journeyId,
    required LocalDate date,
    required String vowId,
    required bool kept,
  }) {
    return _db.transaction(() async {
      final now = _now();
      final entryId = await _ensureEntry(journeyId, date, now);
      await _db
          .into(_db.vowChecks)
          .insertOnConflictUpdate(
            VowChecksCompanion.insert(
              entryId: entryId,
              vowId: vowId,
              kept: kept,
              updatedAt: now,
            ),
          );
      await _outbox.record(
        entityType: 'vow_check',
        entityId: '$entryId/$vowId',
        operation: 'upsert',
        payload: {'kept': kept, 'updatedAt': now.toIso8601String()},
      );
    });
  }

  Future<void> saveNote({
    required String journeyId,
    required LocalDate date,
    required String note,
  }) {
    return _db.transaction(() async {
      final now = _now();
      final entryId = await _ensureEntry(journeyId, date, now);
      final cleaned = _blankToNull(note);
      await (_db.update(
        _db.dayEntries,
      )..where((e) => e.id.equals(entryId))).write(
        DayEntriesCompanion(note: Value(cleaned), updatedAt: Value(now)),
      );
      await _outbox.record(
        entityType: 'day_entry',
        entityId: entryId,
        operation: 'note',
        payload: {'note': cleaned, 'updatedAt': now.toIso8601String()},
      );
    });
  }

  /// Removes every journey and entry from this phone. Settings are kept.
  Future<void> deleteAllJourneyData() {
    return _db.transaction(() async {
      await _db.delete(_db.vowChecks).go();
      await _db.delete(_db.milestoneRecords).go();
      await _db.delete(_db.dayEntries).go();
      await _db.delete(_db.journeys).go();
      await _db.delete(_db.outboxItems).go();
    });
  }

  Future<String> _ensureEntry(
    String journeyId,
    LocalDate date,
    DateTime now,
  ) async {
    final existing =
        await (_db.select(_db.dayEntries)..where(
              (e) => e.journeyId.equals(journeyId) & e.date.equalsValue(date),
            ))
            .getSingleOrNull();
    if (existing != null) return existing.id;
    final id = _newId();
    await _db
        .into(_db.dayEntries)
        .insert(
          DayEntriesCompanion.insert(
            id: id,
            journeyId: journeyId,
            date: date,
            createdAt: now,
            updatedAt: now,
          ),
        );
    return id;
  }

  static String? _blankToNull(String? value) {
    final trimmed = value?.trim() ?? '';
    return trimmed.isEmpty ? null : trimmed;
  }
}
