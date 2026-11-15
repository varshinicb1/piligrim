import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';
import '../../core/l10n/languages.dart';
import '../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteDataTitle),
        content: Text(l10n.deleteDataBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            key: const ValueKey('delete-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.deleteConfirm),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      // The router returns to the start screen once the journey is gone.
      await ref.read(journeyRepositoryProvider).deleteAllJourneyData();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final current = ref.watch(localeControllerProvider).value?.languageCode;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        children: [
          ListTile(
            title: Text(
              l10n.languageSetting,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          for (final language in appLanguages)
            ListTile(
              key: ValueKey('settings-language-${language.code}'),
              title: Text(language.nativeName),
              trailing: language.code == current
                  ? Icon(Icons.check, color: scheme.primary)
                  : null,
              selected: language.code == current,
              onTap: () => ref
                  .read(localeControllerProvider.notifier)
                  .setLocale(language.locale),
            ),
          const Divider(),
          ListTile(
            key: const ValueKey('delete-data'),
            leading: Icon(Icons.delete_outline, color: scheme.error),
            title: Text(l10n.deleteDataTitle),
            onTap: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }
}
