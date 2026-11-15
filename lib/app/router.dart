import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/db/database.dart';
import '../features/journey/journey_screen.dart';
import '../features/journey_book/journey_book_screen.dart';
import '../features/onboarding/language_screen.dart';
import '../features/onboarding/start_journey_screen.dart';
import '../features/guide/prayer_detail_screen.dart';
import '../features/guide/guide_screen.dart';
import '../features/group/group_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/home_shell.dart';
import '../features/shell/splash_screen.dart';
import '../features/today/today_screen.dart';
import 'providers.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const language = '/onboarding/language';
  static const startJourney = '/onboarding/start';
  static const today = '/today';
  static const journey = '/journey';
  static const book = '/journey/book';
  static const group = '/group';
  static const guide = '/guide';
  static const settings = '/settings';

  static String prayer(String id) => '/guide/prayers/$id';
}

/// Where the app should be, given what it knows about the devotee.
///
/// Returns null to stay on [location].
String? redirectFor({
  required String location,
  required AsyncValue<Locale?> locale,
  required AsyncValue<Journey?> journey,
}) {
  String? go(String target) => location == target ? null : target;

  if (locale.hasError || journey.hasError) return go(Routes.splash);
  if (!locale.hasValue || !journey.hasValue) return go(Routes.splash);
  if (locale.value == null) return go(Routes.language);

  if (journey.value == null) {
    // Settings stay reachable so the language can be changed before a
    // journey begins.
    return location == Routes.settings ? null : go(Routes.startJourney);
  }
  final onboarding = location.startsWith('/onboarding');
  return onboarding || location == Routes.splash ? Routes.today : null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.onDispose(refresh.dispose);
  ref.listen(localeControllerProvider, (_, _) => refresh.value++);
  ref.listen(activeJourneyProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) => redirectFor(
      location: state.matchedLocation,
      locale: ref.read(localeControllerProvider),
      journey: ref.read(activeJourneyProvider),
    ),
    routes: [
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.language,
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: Routes.startJourney,
        builder: (context, state) => const StartJourneyScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.today,
                builder: (context, state) => const TodayScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.journey,
                builder: (context, state) => const JourneyScreen(),
                routes: [
                  GoRoute(
                    path: 'book',
                    builder: (context, state) => const JourneyBookScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.group,
                builder: (context, state) => const GroupScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.guide,
                builder: (context, state) => const GuideScreen(),
                routes: [
                  GoRoute(
                    path: 'prayers/:prayerId',
                    builder: (context, state) => PrayerDetailScreen(
                      prayerId: state.pathParameters['prayerId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
