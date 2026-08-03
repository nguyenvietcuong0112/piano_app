import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:project_flutter/core/app_router.dart';
import 'package:project_flutter/core/app_theme.dart';
import 'package:project_flutter/core/audio_engine.dart';
import 'package:project_flutter/core/theme_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeService.init();
  await AudioEngine().ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
    DeviceOrientation.portraitUp,
  ]);
  runApp(
    const ProviderScope(
      child: RealPianoApp(),
    ),
  );
}

class RealPianoApp extends ConsumerWidget {
  const RealPianoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return ScreenUtilInit(
      // Standard mobile design scale ratio (Landscape 844 x 390)
      designSize: const Size(844, 390),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'The Piano',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          routerConfig: router,
        );
      },
    );
  }
}
