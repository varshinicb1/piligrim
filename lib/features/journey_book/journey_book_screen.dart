import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';

import 'package:piligrim_design/piligrim_design.dart';

import '../../core/widgets/async_body.dart';
import '../../l10n/app_localizations.dart';

/// Placeholder for the keepsake. The journey features work builds the
/// story, the recap film and the PDF from the same [JourneyOverview].
class JourneyBookScreen extends ConsumerWidget {
  const JourneyBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabBook)),
      body: AsyncBody<JourneyOverview>(
        value: ref.watch(journeyOverviewProvider),
        builder: (context, overview) => ListView(
          padding: const EdgeInsets.all(PgSpacing.lg),
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 96,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: PgSpacing.md),
            Text(
              l10n.bookDaysRecorded(overview.summary.daysCheckedIn),
              key: const ValueKey('book-days-recorded'),
              style: textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: PgSpacing.md),
            Text(
              l10n.bookIntro,
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
