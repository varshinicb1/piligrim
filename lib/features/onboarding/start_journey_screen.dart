import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/router.dart';
import '../../core/content/content_pack.dart';

import 'package:piligrim_design/piligrim_design.dart';

import '../../core/vow_engine/vow_engine.dart';
import '../../core/widgets/async_body.dart';
import '../../l10n/app_localizations.dart';

/// Second screen: when the mala is worn and for how long.
class StartJourneyScreen extends ConsumerWidget {
  const StartJourneyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.startTitle),
        actions: [
          IconButton(
            tooltip: l10n.languageSetting,
            icon: const Icon(Icons.language),
            onPressed: () => context.push(Routes.settings),
          ),
        ],
      ),
      body: AsyncBody<ContentPack>(
        value: ref.watch(contentPackProvider),
        builder: (context, pack) => _StartJourneyForm(pack: pack),
      ),
    );
  }
}

class _StartJourneyForm extends ConsumerStatefulWidget {
  const _StartJourneyForm({required this.pack});

  final ContentPack pack;

  @override
  ConsumerState<_StartJourneyForm> createState() => _StartJourneyFormState();
}

class _StartJourneyFormState extends ConsumerState<_StartJourneyForm> {
  final _sankalpam = TextEditingController();
  late LocalDate _startDate = ref.read(todayProvider);
  late int _plannedDays = widget.pack.template.defaultDays;
  bool _saving = false;

  @override
  void dispose() {
    _sankalpam.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = ref.read(todayProvider);
    // A devotee may install the app part-way through a deeksha, or ahead
    // of mala dharana.
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate.toLocalDateTime(),
      firstDate: today.addDays(-widget.pack.template.maxDays).toLocalDateTime(),
      lastDate: today.addDays(90).toLocalDateTime(),
    );
    if (picked != null) {
      setState(() => _startDate = LocalDate.fromDateTime(picked));
    }
  }

  Future<void> _begin() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(journeyRepositoryProvider)
          .startJourney(
            template: widget.pack.template,
            startDate: _startDate,
            plannedDays: _plannedDays,
            sankalpam: _sankalpam.text,
          );
      // The router moves to Today when the active journey appears.
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final template = widget.pack.template;
    final textTheme = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(PgSpacing.md),
      children: [
        ListTile(
          key: const ValueKey('start-date'),
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.event),
          title: Text(l10n.startDateLabel),
          subtitle: Text(
            MaterialLocalizations.of(context)
                .formatFullDate(_startDate.toLocalDateTime()),
          ),
          onTap: _pickDate,
        ),
        const SizedBox(height: PgSpacing.md),
        Text(l10n.lengthLabel, style: textTheme.titleMedium),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _plannedDays.toDouble(),
                min: template.minDays.toDouble(),
                max: template.maxDays.toDouble(),
                divisions: template.maxDays > template.minDays
                    ? template.maxDays - template.minDays
                    : null,
                label: l10n.daysCount(_plannedDays),
                onChanged: (value) =>
                    setState(() => _plannedDays = value.round()),
              ),
            ),
            Text(l10n.daysCount(_plannedDays), style: textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: PgSpacing.md),
        TextField(
          controller: _sankalpam,
          maxLines: 3,
          maxLength: 280,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l10n.sankalpamLabel),
        ),
        const SizedBox(height: PgSpacing.lg),
        FilledButton(
          key: const ValueKey('begin-journey'),
          onPressed: _saving ? null : _begin,
          child: Text(l10n.beginJourney),
        ),
      ],
    );
  }
}
