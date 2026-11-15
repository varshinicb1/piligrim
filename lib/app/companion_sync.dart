import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/companion/companion_controller.dart';
import '../core/companion/still_companion_controller.dart';
import 'providers.dart';

final companionControllerProvider = Provider<StillCompanionController>((ref) {
  final controller = StillCompanionController();
  ref.onDispose(controller.dispose);
  return controller;
});

final companionDirectorProvider = Provider<CompanionDirector>(
  (ref) => CompanionDirector(ref.watch(companionControllerProvider)),
);

/// Keeps the companion in step with the journey, following the app event
/// mapping in the motion spec. Screens that show the companion watch this.
///
/// Wired so far: time of day, today's vow progress, greet or comfort on
/// open, and the day-complete celebration. Milestone and journey-complete
/// celebrations, listening, thinking, quiet and sleeping belong to the
/// features that cause them.
final companionSyncProvider = Provider<void>((ref) {
  final controller = ref.watch(companionControllerProvider);
  final director = ref.watch(companionDirectorProvider);
  var opened = false;

  void apply(JourneyOverview? previous, JourneyOverview next) {
    controller.timeOfDay = timeOfDayBandFor(ref.read(clockProvider)());
    final total = next.template.vows.length;
    director.onVowsChanged(done: next.vowsKeptToday, total: total);

    if (!opened) {
      opened = true;
      // "First open today" is not tracked yet, so each launch greets.
      director.onAppOpened(
        missedDays: next.summary.missedDays,
        firstOpenToday: true,
      );
      return;
    }
    final sameDay = previous != null && previous.today == next.today;
    if (sameDay &&
        total > 0 &&
        next.vowsKeptToday == total &&
        previous.vowsKeptToday < total) {
      director.onDayCompleted();
    }
  }

  ref.listen(journeyOverviewProvider, (previous, next) {
    final overview = next.value;
    if (overview != null) apply(previous?.value, overview);
  }, fireImmediately: true);
});
