import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_fgbg/flutter_fgbg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:overlay_support/overlay_support.dart';

import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import 'app_initializer.dart';

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    AppInitializer.init();
  }

  @override
  void dispose() {
    AppInitializer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return FGBGNotifier(
      onEvent: AppInitializer.handleStateApp,
      child: OverlaySupport.global(
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: ScreenUtilInit(
            designSize: const Size(390, 844),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp.router(
                title: 'Real Piano',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.darkTheme,
                routerConfig: router,
                builder: (context, myWidget) {
                  myWidget = MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: const TextScaler.linear(1.0),
                    ),
                    child: myWidget ?? const SizedBox(),
                  );
                  return EasyLoading.init()(context, myWidget);
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
