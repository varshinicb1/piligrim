import 'package:material_ui/material_ui.dart';
import 'package:piligrim_design/piligrim_design.dart';

import '../../l10n/app_localizations.dart';

/// Placeholder for Guruswami groups, which need sign-in and the backend.
class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabGroup)),
      body: ListView(
        padding: const EdgeInsets.all(PgSpacing.lg),
        children: [
          Icon(
            Icons.groups_outlined,
            size: PgSpacing.xxxl,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: PgSpacing.md),
          Text(
            l10n.groupIntro,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
