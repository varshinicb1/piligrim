import 'package:drift/drift.dart';

import '../vow_engine/local_date.dart';
import 'tables.dart';

export 'tables.dart' show JourneyStatus;

part 'database.g.dart';

/// The phone's own database: the source of truth for a devotee's journey.
@DriftDatabase(
  tables: [
    Journeys,
    DayEntries,
    VowChecks,
    MilestoneRecords,
    OutboxItems,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
