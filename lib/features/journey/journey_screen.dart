import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/widgets/async_body.dart';
import '../../l10n/app_localizations.dart';

/// Every day of the journey, with what was recorded on it.
class JourneyScreen extends ConsumerWidget {
  const JourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabJourney),
        actions: [
          IconButton(
            tooltip: l10n.tabBook,
            icon: const Icon(Icons.auto_stories_outlined),
            onPressed: () => context.go(Routes.book),
          ),
        ],
      ),
      body: AsyncBody<JourneyOverview>(
        value: ref.watch(journeyOverviewProvider),
        builder: (context, overview) => ListView.builder(
          itemCount: overview.journey.plannedDays,
          itemBuilder: (context, index) =>
              _DayTile(overview: overview, dayNumber: index + 1),
        ),
      ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.overview, required this.dayNumber});

  final JourneyOverview overview;
  final int dayNumber;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final date = overview.clock.dateOfDay(dayNumber);
    final entry = overview.entriesByDate[date];
    final isFuture = date.isAfter(overview.today);
    final isToday = date == overview.today;
    final milestones = overview.template.milestonesOnDay(
      dayNumber,
      overview.journey.plannedDays,
    );
    final note = entry?.entry.note;

    final String status;
    if (entry != null) {
      status = l10n.vowsKeptCount(
        entry.keptVowIds.length,
        overview.template.vows.length,
      );
    } else {
      // A day without an entry is stated plainly, with no judgement.
      status = isFuture ? '' : l10n.noEntryYet;
    }

    return ListTile(
      enabled: !isFuture,
      selected: isToday,
      leading: CircleAvatar(
        backgroundColor: entry != null
            ? scheme.primaryContainer
            : scheme.surfaceContainerHighest,
        foregroundColor: scheme.onSurface,
        child: Text('$dayNumber'),
      ),
      title: Text(
        [
          l10n.dayLabel(dayNumber),
          for (final milestone in milestones)
            overview.strings.text(milestone.titleKey),
        ].join(' · '),
      ),
      subtitle: Text(
        [
          MaterialLocalizations.of(context)
              .formatMediumDate(date.toLocalDateTime()),
          if (status.isNotEmpty) status,
          ?note,
        ].join('\n'),
      ),
      isThreeLine: note != null,
    );
  }
}
