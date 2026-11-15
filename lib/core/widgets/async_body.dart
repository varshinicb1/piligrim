import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../l10n/app_localizations.dart';

import 'package:piligrim_design/piligrim_design.dart';

/// Shows [builder] once [value] has data, keeping the last data on screen
/// while it refreshes. Shows a spinner before the first data and a plain
/// message on failure.
class AsyncBody<T extends Object> extends StatelessWidget {
  const AsyncBody({super.key, required this.value, required this.builder});

  final AsyncValue<T?> value;
  final Widget Function(BuildContext context, T data) builder;

  @override
  Widget build(BuildContext context) {
    final data = value.value;
    if (data != null) return builder(context, data);
    if (value.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(PgSpacing.lg),
          child: Text(
            AppLocalizations.of(context).loadError,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return const Center(child: CircularProgressIndicator());
  }
}
