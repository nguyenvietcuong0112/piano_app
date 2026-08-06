import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/splash_page.dart';
import '../../features/language/language_page.dart';
import '../../features/onboard/onboard_page.dart';
import '../../features/home/ui/home_tab.dart';
import '../../features/lesson/domain/lesson_model.dart';
import '../../features/lesson/ui/all_lessons_screen.dart';
import '../../features/lesson/ui/lesson_play_screen.dart';
import '../../features/piano/ui/piano_tab.dart';
import '../../features/piano/ui/play_piano_screen.dart';
import '../../features/themes/domain/theme_model.dart';
import '../../features/themes/ui/theme_tab.dart';
import '../../features/themes/ui/all_themes_screen.dart';
import '../../features/themes/ui/theme_preview_screen.dart';
import '../../features/my_songs/ui/my_songs_tab.dart';
import '../../features/premium/ui/premium_screen.dart';
import '../../features/settings/ui/settings_screen.dart';
import '../../features/main/main_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => SplashPage(
          onFinished: () => context.go('/home'),
        ),
      ),
      GoRoute(
        path: '/language',
        name: 'language',
        builder: (context, state) => const LanguagePage(isFirstLaunch: true),
      ),
      GoRoute(
        path: '/onboard',
        name: 'onboard',
        builder: (context, state) => const OnboardPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/themes',
                name: 'themes',
                builder: (context, state) => const ThemeTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/piano',
                name: 'piano',
                builder: (context, state) => const PianoTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-songs',
                name: 'my-songs',
                builder: (context, state) => const MySongsTab(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/play',
        name: 'play',
        builder: (context, state) => const PlayPianoScreen(),
      ),
      GoRoute(
        path: '/all-lessons',
        name: 'all-lessons',
        builder: (context, state) => const AllLessonsScreen(),
      ),
      GoRoute(
        path: '/lesson-play',
        name: 'lesson-play',
        builder: (context, state) {
          final lesson = state.extra as LessonsItem;
          return LessonPlayScreen(lesson: lesson);
        },
      ),
      GoRoute(
        path: '/premium',
        name: 'premium',
        builder: (context, state) => const PremiumScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/all-themes',
        name: 'all-themes',
        builder: (context, state) {
          final category = state.extra as ThemeCategory;
          return AllThemesScreen(category: category);
        },
      ),
      GoRoute(
        path: '/theme-preview',
        name: 'theme-preview',
        builder: (context, state) {
          final theme = state.extra as ThemeItem;
          return ThemePreviewScreen(theme: theme);
        },
      ),
    ],
  );
});
