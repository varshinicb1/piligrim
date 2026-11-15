import 'package:drift/drift.dart';

import '../vow_engine/local_date.dart';

/// Stores a [LocalDate] as `YYYY-MM-DD` text, which also sorts correctly.
class LocalDateConverter extends TypeConverter<LocalDate, String> {
  const LocalDateConverter();

  @override
  LocalDate fromSql(String fromDb) => LocalDate.parse(fromDb);

  @override
  String toSql(LocalDate value) => value.toIso();
}

enum JourneyStatus { active, completed, abandoned }

/// One person's instance of an observance template.
class Journeys extends Table {
  TextColumn get id => text()();
  TextColumn get templateId => text()();
  TextColumn get templateVersion => text()();
  TextColumn get startDate => text().map(const LocalDateConverter())();
  IntColumn get plannedDays => integer()();
  TextColumn get sankalpam => text().nullable()();
  TextColumn get guideName => text().nullable()();
  TextColumn get status => textEnum<JourneyStatus>()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// What the devotee recorded on one calendar day of a journey.
@TableIndex(name: 'day_entries_journey', columns: {#journeyId})
class DayEntries extends Table {
  TextColumn get id => text()();
  TextColumn get journeyId =>
      text().references(Journeys, #id, onDelete: KeyAction.cascade)();
  TextColumn get date => text().map(const LocalDateConverter())();
  TextColumn get note => text().nullable()();
  TextColumn get mood => text().nullable()();

  /// Paths are relative to the app's media directory. Media files never
  /// leave the phone unless backup is on.
  TextColumn get photoPath => text().nullable()();
  TextColumn get voiceNotePath => text().nullable()();
  TextColumn get transcript => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {journeyId, date},
  ];
}

/// Whether one vow was kept on one day. A row per vow keeps last-writer-wins
/// sync per field rather than per day.
class VowChecks extends Table {
  TextColumn get entryId =>
      text().references(DayEntries, #id, onDelete: KeyAction.cascade)();
  TextColumn get vowId => text()();
  BoolColumn get kept => boolean()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {entryId, vowId};
}

/// A milestone the devotee has marked as reached, such as irumudi kattu.
class MilestoneRecords extends Table {
  TextColumn get journeyId =>
      text().references(Journeys, #id, onDelete: KeyAction.cascade)();
  TextColumn get milestoneId => text()();
  TextColumn get reachedOn => text().map(const LocalDateConverter())();
  TextColumn get note => text().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {journeyId, milestoneId};
}

/// Changes waiting to be sent to the backend. Empty unless sync is on; see
/// lib/core/sync/outbox.dart.
class OutboxItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
}

/// Small key-value settings such as the chosen language.
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
