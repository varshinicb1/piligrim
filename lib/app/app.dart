import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:piligrim_design/piligrim_design.dart';

import '../l10n/app_localizations.dart';
import 'providers.dart';
import 'router.dart';

class PiligrimApp extends ConsumerStatefulWidget {
  const PiligrimApp({super.key});

  @override
  ConsumerState<PiligrimApp> createState() => _PiligrimAppState();
}

class _PiligrimAppState extends ConsumerState<PiligrimApp> {
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    // The app may sit in the background past midnight.
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(todayProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeControllerProvider).value;
    // Fonts and line heights depend on the script, so the theme is rebuilt
    // with the language.
    final themeLocale = locale ?? const Locale('en');
    return MaterialApp.router(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      routerConfig: ref.watch(routerProvider),
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: PiligrimTheme.light(themeLocale),
      darkTheme: PiligrimTheme.dark(themeLocale),
    );
  }
}
