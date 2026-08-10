import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';
import '../../ads/const/ad_id_extension.dart';
import '../../ads/const/ad_id_name.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/firebase_remote_config_service.dart';
import '../../core/localization/app_localizations.dart';
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

  void _onTap(int index) {
    if (index == widget.navigationShell.currentIndex) {
      widget.navigationShell.goBranch(index, initialLocation: true);
      return;
    }

    final bool canShowAd = !AppConstants.isPremiumUser.value &&
        FirebaseRemoteConfigService.getBoolConfigByKey(
          FirebaseRemoteConfigService.inter_all,
        );

    if (canShowAd) {
      EasyAds.instance.showInterstitialAd(
        context,
        adId: MyAdIdName.interAll.getId,
        adIdName: MyAdIdName.interAll,
        adDissmissed: () {
          if (mounted) {
            widget.navigationShell.goBranch(
              index,
              initialLocation: false,
            );
          }
        },
        onFailed: () {
          if (mounted) {
            widget.navigationShell.goBranch(
              index,
              initialLocation: false,
            );
          }
        },
      );
    } else {
      widget.navigationShell.goBranch(
        index,
        initialLocation: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = widget.navigationShell.currentIndex;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final titles = [
      context.tr('piano_lessons'),
      context.tr('piano_keyboard_themes'),
      context.tr('piano'),
      context.tr('my_song_collection'),
    ];
    final currentTitle = (currentIndex >= 0 && currentIndex < titles.length)
        ? titles[currentIndex]
        : context.tr('piano_lessons');

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
          title: context.tr('quit_app'),
          message: context.tr('quit_app_msg'),
          confirmText: context.tr('quit'),
          cancelText: context.tr('cancel'),
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
