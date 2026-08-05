import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/custom_bottom_nav_bar.dart';
import 'widgets/custom_header_bar.dart';

class MainScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainScreen({
    super.key,
    required this.navigationShell,
  });

  static const List<String> _titles = [
    "Piano Lesssion",
    "Piano Theme",
    "Piano Instrument",
    "My Song",
  ];

  void _onTap(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = navigationShell.currentIndex;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final currentTitle = (currentIndex >= 0 && currentIndex < _titles.length)
        ? _titles[currentIndex]
        : "Piano Lesssion";

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            CustomHeaderBar(title: currentTitle),
            Expanded(child: navigationShell),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding > 0 ? bottomPadding : 12.sp),
        child: CustomBottomNavBar(
          currentIndex: currentIndex,
          onTap: _onTap,
        ),
      ),
    );
  }
}
