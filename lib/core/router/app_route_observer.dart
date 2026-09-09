import 'package:flutter/material.dart';
import '../helper/firebase_helper.dart';

/// NavigatorObserver that automatically tracks screen views on route transitions.
class AppRouteObserver extends NavigatorObserver {
  static final Map<String, String> _screenNameMap = {
    'splash': 'SplashScreen',
    'language': 'LanguageScreen',
    'onboard': 'OnboardScreen',
    'home': 'HomeScreen',
    'themes': 'ThemesScreen',
    'piano': 'PianoScreen',
    'my-songs': 'MySongsScreen',
    'play': 'PlayPianoScreen',
    'player-mode': 'PlayerModeScreen',
    'sheet-playback': 'PianoSheetPlaybackScreen',
    'all-lessons': 'AllLessonsScreen',
    'songs-landscape': 'SongsLandscapeScreen',
    'lesson-play': 'LessonPlayScreen',
    'premium': 'PremiumScreen',
    'settings': 'SettingsScreen',
    'all-themes': 'AllThemesScreen',
    'theme-preview': 'ThemePreviewScreen',
    'recordings': 'RecordingsScreen',
  };

  static String? _lastLoggedScreen;

  /// Manually or automatically logs a screen name with duplicate suppression.
  static void logScreen(String screenName) {
    if (_lastLoggedScreen == screenName) return;
    _lastLoggedScreen = screenName;
    FirebaseHelper.setTrackingScreenName(screenName);
  }

  /// Resets the last logged screen cache if needed (e.g. on route return).
  static void resetLastLoggedScreen() {
    _lastLoggedScreen = null;
  }

  void _trackRoute(Route<dynamic>? route) {
    if (route == null) return;
    final name = route.settings.name;
    if (name != null && name.isNotEmpty) {
      final screenName = _screenNameMap[name] ?? _formatScreenName(name);
      logScreen(screenName);
    }
  }

  static String _formatScreenName(String routeName) {
    final cleanName = routeName.replaceAll('/', '').replaceAll('-', '_');
    if (cleanName.isEmpty) return 'UnknownScreen';
    final parts = cleanName.split('_');
    return '${parts.map((p) => p.isEmpty ? '' : '${p[0].toUpperCase()}${p.substring(1)}').join('')}Screen';
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _trackRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _trackRoute(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _trackRoute(newRoute);
    }
  }
}
