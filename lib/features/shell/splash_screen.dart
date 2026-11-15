import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../app/providers.dart';

import 'package:piligrim_design/piligrim_design.dart';

import '../../l10n/app_localizations.dart';

/// Shown while the database opens, and if it cannot be opened.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final failed =
        ref.watch(localeControllerProvider).hasError ||
        ref.watch(activeJourneyProvider).hasError;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(PgSpacing.lg),
          child: failed
              ? Text(
                  AppLocalizations.of(context).loadError,
                  textAlign: TextAlign.center,
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
