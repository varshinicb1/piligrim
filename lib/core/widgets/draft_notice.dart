import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

import 'package:piligrim_design/piligrim_design.dart';

/// Shown wherever content from an unreviewed pack is on screen.
class DraftNotice extends StatelessWidget {
  const DraftNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(PgRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PgSpacing.xs),
        child: Row(
          children: [
            Icon(Icons.edit_note, color: scheme.onTertiaryContainer),
            const SizedBox(width: PgSpacing.xs),
            Expanded(
              child: Text(
                AppLocalizations.of(context).draftContentNotice,
                style: TextStyle(color: scheme.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
