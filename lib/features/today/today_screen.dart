import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/router.dart';

import 'package:piligrim_design/piligrim_design.dart';

import '../../app/companion_sync.dart';
import '../../core/companion/companion_view.dart';
import '../../core/vow_engine/vow_engine.dart';
import '../../core/widgets/async_body.dart';
import '../../core/widgets/draft_notice.dart';
import '../../l10n/app_localizations.dart';

/// The daily check-in: tick today's vows and leave a line about the day.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final overview = ref.watch(journeyOverviewProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          overview.value?.strings.text('template.title') ?? l10n.appTitle,
        ),
        actions: [
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: AsyncBody<JourneyOverview>(
        value: overview,
        builder: (context, data) => _TodayBody(overview: data),
      ),
    );
  }
}

class _TodayBody extends ConsumerWidget {
  const _TodayBody({required this.overview});

  final JourneyOverview overview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(companionSyncProvider);
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final journey = overview.journey;
    final phase = overview.summary.phase;

    return ListView(
      padding: const EdgeInsets.all(PgSpacing.md),
      children: [
        if (!overview.pack.isVetted) ...[
          const DraftNotice(),
          const SizedBox(height: PgSpacing.md),
        ],
        Center(
          child: CompanionView(
            controller: ref.watch(companionControllerProvider),
            journeyProgress: overview.clock.progressOn(overview.today),
          ),
        ),
        const SizedBox(height: PgSpacing.md),
        Text(
          switch (phase) {
            JourneyPhase.upcoming => l10n.journeyUpcoming(
              overview.clock.daysUntilStart(overview.today),
            ),
            JourneyPhase.active => l10n.dayOfTotal(
              overview.todayNumber!,
              journey.plannedDays,
            ),
            JourneyPhase.complete => l10n.journeyComplete(journey.plannedDays),
          },
          key: const ValueKey('today-headline'),
          style: textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        for (final milestone in overview.milestonesToday)
          Padding(
            padding: const EdgeInsets.only(top: PgSpacing.xs),
            child: Text(
              l10n.milestoneToday(overview.strings.text(milestone.titleKey)),
              style: textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ),
        if (overview.summary.missedDays > 0)
          Padding(
            padding: const EdgeInsets.only(top: PgSpacing.xs),
            child: Text(l10n.comfortMessage, textAlign: TextAlign.center),
          ),
        if (phase == JourneyPhase.active) ..._checkIn(context, ref),
      ],
    );
  }

  List<Widget> _checkIn(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final today = overview.today;
    final entry = overview.entriesByDate[today];
    final kept = entry?.keptVowIds ?? const <String>{};
    final repository = ref.read(journeyRepositoryProvider);

    return [
      const SizedBox(height: PgSpacing.lg),
      Text(l10n.todaysVows, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: PgSpacing.xs),
      Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (final vow in overview.template.vows)
              CheckboxListTile(
                key: ValueKey('vow-${vow.id}'),
                value: kept.contains(vow.id),
                title: Text(overview.strings.text(vow.titleKey)),
                onChanged: (value) => repository.setVowKept(
                  journeyId: overview.journey.id,
                  date: today,
                  vowId: vow.id,
                  kept: value ?? false,
                ),
              ),
          ],
        ),
      ),
      const SizedBox(height: PgSpacing.lg),
      _ReflectionField(
        // A new day gets a fresh field.
        key: ValueKey('reflection-${today.toIso()}'),
        initialText: entry?.entry.note ?? '',
        onSave: (text) => repository.saveNote(
          journeyId: overview.journey.id,
          date: today,
          note: text,
        ),
      ),
      const SizedBox(height: PgSpacing.md),
      // Photo and voice capture belong to the journey features work.
      Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(l10n.addPhoto),
            ),
          ),
          const SizedBox(width: PgSpacing.xs),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.mic_none),
              label: Text(l10n.addVoiceNote),
            ),
          ),
        ],
      ),
      Padding(
        padding: const EdgeInsets.only(top: PgSpacing.xxs),
        child: Text(
          l10n.comingSoon,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ),
    ];
  }
}

class _ReflectionField extends StatefulWidget {
  const _ReflectionField({
    super.key,
    required this.initialText,
    required this.onSave,
  });

  final String initialText;
  final Future<void> Function(String text) onSave;

  @override
  State<_ReflectionField> createState() => _ReflectionFieldState();
}

class _ReflectionFieldState extends State<_ReflectionField> {
  late final _controller = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final messenger = ScaffoldMessenger.of(context);
    final saved = AppLocalizations.of(context).saved;
    FocusScope.of(context).unfocus();
    await widget.onSave(_controller.text);
    messenger.showSnackBar(SnackBar(content: Text(saved)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const ValueKey('reflection-field'),
          controller: _controller,
          maxLines: 3,
          maxLength: 500,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.reflectionLabel),
        ),
        const SizedBox(height: PgSpacing.xs),
        FilledButton(
          key: const ValueKey('reflection-save'),
          onPressed: _save,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
