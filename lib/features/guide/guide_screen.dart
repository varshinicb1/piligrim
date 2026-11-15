import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../app/router.dart';

import 'package:piligrim_design/piligrim_design.dart';

import '../../core/widgets/async_body.dart';
import '../../core/widgets/draft_notice.dart';
import '../../l10n/app_localizations.dart';

/// The Guide tab. Prayers from the content pack are here, available
/// offline. Ask, Prepare, Rules and Emergency numbers join them later.
class GuideScreen extends ConsumerWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabGuide)),
      body: AsyncBody<JourneyOverview>(
        value: ref.watch(journeyOverviewProvider),
        builder: (context, overview) => ListView(
          children: [
            if (!overview.pack.isVetted)
              const Padding(
                padding: EdgeInsets.all(PgSpacing.md),
                child: DraftNotice(),
              ),
            ListTile(
              title: Text(
                l10n.tabPrayers,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            for (final prayer in overview.pack.prayers)
              ListTile(
                key: ValueKey('prayer-${prayer.id}'),
                leading: const Icon(Icons.self_improvement),
                title: Text(overview.strings.text(prayer.titleKey)),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go(Routes.prayer(prayer.id)),
              ),
          ],
        ),
      ),
    );
  }
}
