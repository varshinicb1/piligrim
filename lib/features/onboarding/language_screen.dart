import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';

import 'package:piligrim_design/piligrim_design.dart';

import '../../core/l10n/languages.dart';
import '../../l10n/app_localizations.dart';

/// First screen: the devotee picks a language, shown in its own script.
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.languageTitle)),
      body: ListView.separated(
        padding: const EdgeInsets.all(PgSpacing.md),
        itemCount: appLanguages.length,
        separatorBuilder: (context, index) =>
            const SizedBox(height: PgSpacing.xs),
        itemBuilder: (context, index) {
          final language = appLanguages[index];
          return FilledButton.tonal(
            key: ValueKey('language-${language.code}'),
            onPressed: () => ref
                .read(localeControllerProvider.notifier)
                .setLocale(language.locale),
            child: Text(
              language.nativeName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          );
        },
      ),
    );
  }
}
