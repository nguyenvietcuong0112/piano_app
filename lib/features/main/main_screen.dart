import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/exit_confirmation_dialog.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import 'widgets/custom_header_bar.dart';

class MainScreen extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      EasyAds.instance.appLifecycleReactor?.setOnSplashScreen(false);
      EasyAds.instance.appLifecycleReactor?.setAllowAppOpenAd(true);
    });
  }

  static const List<String> _titles = [
    "Piano Lesssion",
    "Piano Theme",
    "Piano Instrument",
    "My Song",
  ];

  void _onTap(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final currentTitle = (currentIndex >= 0 && currentIndex < _titles.length)
        ? _titles[currentIndex]
        : "Piano Lesssion";

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // If not on first tab (Home), go back to Home tab first
        if (widget.navigationShell.currentIndex != 0) {
          _onTap(0);
          return;
        }

        // Show reusable ExitConfirmationDialog when backing out of main screen
        final shouldExit = await ExitConfirmationDialog.show(
          context,
          title: "Exit App",
          message: "Are you sure you want to exit the app?",
          confirmText: "Exit",
          cancelText: "Cancel",
        );

        if (shouldExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        extendBody: true,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              CustomHeaderBar(title: currentTitle),
              Expanded(child: widget.navigationShell),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
              bottom: bottomPadding > 0 ? bottomPadding : 12.sp),
          child: CustomBottomNavBar(
            currentIndex: currentIndex,
            onTap: _onTap,
          ),
        ),
      ),
    );
  }
}
