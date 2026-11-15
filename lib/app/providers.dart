import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/content/content_pack.dart';
import '../core/content/content_repository.dart';
import '../core/db/database.dart';
import '../core/db/encrypted_executor.dart';
import '../core/db/journey_repository.dart';
import '../core/db/settings_repository.dart';
import '../core/l10n/languages.dart';
import '../core/vow_engine/vow_engine.dart';

/// The observance the app runs. Other malas become other pack ids; nothing
/// else in the app names a particular deeksha.
final packIdProvider = Provider<String>((ref) => 'ayyappa_deeksha');

/// The current time. Overridden in tests.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Today's calendar date. Invalidated when the app returns to the
/// foreground, so the day rolls over after midnight.
final todayProvider = Provider<LocalDate>(
  (ref) => LocalDate.fromDateTime(ref.watch(clockProvider)()),
);

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase(openEncryptedExecutor(SecureDatabaseKeyStore()));
  ref.onDispose(database.close);
  return database;
});

final journeyRepositoryProvider = Provider<JourneyRepository>(
  (ref) => JourneyRepository(
    ref.watch(databaseProvider),
    now: ref.watch(clockProvider),
  ),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(databaseProvider)),
);

final contentSourceProvider = Provider<ContentSource>(
  (ref) => AssetContentSource(),
);

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => ContentRepository(ref.watch(contentSourceProvider)),
);

/// The language the devotee chose, or null before they have chosen one.
final localeControllerProvider =
    AsyncNotifierProvider<LocaleController, Locale?>(LocaleController.new);

class LocaleController extends AsyncNotifier<Locale?> {
  @override
  Future<Locale?> build() async {
    final code = await ref
        .watch(settingsRepositoryProvider)
        .read(SettingsRepository.localeKey);
    return code != null && isSupportedLanguage(code) ? Locale(code) : null;
  }

  Future<void> setLocale(Locale locale) async {
    await ref
        .read(settingsRepositoryProvider)
        .write(SettingsRepository.localeKey, locale.languageCode);
    state = AsyncData(locale);
  }
}

final contentPackProvider = FutureProvider<ContentPack>(
  (ref) =>
      ref.watch(contentRepositoryProvider).loadPack(ref.watch(packIdProvider)),
);

/// The pack's wording in the chosen language.
final packStringsProvider = FutureProvider<PackStrings>((ref) async {
  final pack = await ref.watch(contentPackProvider.future);
  final locale = await ref.watch(localeControllerProvider.future);
  return ref
      .watch(contentRepositoryProvider)
      .loadStrings(
        pack,
        locale?.languageCode ?? ContentRepository.baseLanguage,
      );
});

final activeJourneyProvider = StreamProvider<Journey?>(
  (ref) => ref.watch(journeyRepositoryProvider).watchActiveJourney(),
);

final journeyEntriesProvider =
    StreamProvider.family<List<DayEntryWithVows>, String>(
      (ref, journeyId) =>
          ref.watch(journeyRepositoryProvider).watchEntries(journeyId),
    );

/// Everything the journey screens need, in one place.
class JourneyOverview {
  JourneyOverview({
    required this.journey,
    required this.pack,
    required this.strings,
    required this.today,
    required List<DayEntryWithVows> entries,
  }) : clock = JourneyClock(
         startDate: journey.startDate,
         plannedDays: journey.plannedDays,
       ),
       entriesByDate = {for (final e in entries) e.entry.date: e} {
    summary = summarizeJourney(
      clock: clock,
      template: pack.template,
      today: today,
      records: entries.map((e) => e.toRecord()),
    );
  }

  final Journey journey;
  final ContentPack pack;
  final PackStrings strings;
  final LocalDate today;
  final JourneyClock clock;
  final Map<LocalDate, DayEntryWithVows> entriesByDate;
  late final JourneySummary summary;

  ObservanceTemplate get template => pack.template;

  /// Today's day number, or null before the start and after the end.
  int? get todayNumber => clock.dayNumberOn(today);

  List<MilestoneDefinition> get milestonesToday => todayNumber == null
      ? const []
      : template.milestonesOnDay(todayNumber!, journey.plannedDays);

  /// How many of the template's vows are ticked for today.
  int get vowsKeptToday {
    final kept = entriesByDate[today]?.keptVowIds ?? const <String>{};
    return template.vows.where((vow) => kept.contains(vow.id)).length;
  }
}

/// Null when there is no active journey.
final journeyOverviewProvider = FutureProvider<JourneyOverview?>((ref) async {
  final journey = await ref.watch(activeJourneyProvider.future);
  if (journey == null) return null;
  final pack = await ref.watch(contentPackProvider.future);
  final strings = await ref.watch(packStringsProvider.future);
  final entries = await ref.watch(journeyEntriesProvider(journey.id).future);
  return JourneyOverview(
    journey: journey,
    pack: pack,
    strings: strings,
    today: ref.watch(todayProvider),
    entries: entries,
  );
});
