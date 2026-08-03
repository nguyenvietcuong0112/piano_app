import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:project_flutter/features/lessons/all_lessons_screen.dart';
import 'package:project_flutter/features/lessons/home_tab.dart';
import 'package:project_flutter/features/lessons/lesson_model.dart';
import 'package:project_flutter/features/lessons/lesson_play_screen.dart';
import 'package:project_flutter/features/piano/piano_tab.dart';
import 'package:project_flutter/features/piano/play_piano_screen.dart';
import 'package:project_flutter/features/themes/theme_tab.dart';
import 'package:project_flutter/features/main/main_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    debugLogDiagnostics: false,
    routes: [
      // StatefulShellRoute for Bottom Navigation Bar tabs with state preservation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeTab(),
              ),
            ],
          ),
          // Branch 1: Themes Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/themes',
                name: 'themes',
                builder: (context, state) => const ThemeTab(),
              ),
            ],
          ),
          // Branch 2: Piano Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/piano',
                name: 'piano',
                builder: (context, state) => const PianoTab(),
              ),
            ],
          ),
        ],
      ),

      // Free Play Landscape Piano Screen
      GoRoute(
        path: '/play',
        name: 'play',
        builder: (context, state) => const PlayPianoScreen(),
      ),

      // All Lessons Category List Screen
      GoRoute(
        path: '/all-lessons',
        name: 'all-lessons',
        builder: (context, state) => const AllLessonsScreen(),
      ),

      // Waterfall Piano Lesson Play Practice Screen
      GoRoute(
        path: '/lesson-play',
        name: 'lesson-play',
        builder: (context, state) {
          final lesson = state.extra as LessonsItem;
          return LessonPlayScreen(lesson: lesson);
        },
      ),
    ],
  );
});
