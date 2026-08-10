import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_text_styles.dart';

class PlayerModeScreen extends StatefulWidget {
  final bool initialIsDualMode;

  const PlayerModeScreen({
    super.key,
    this.initialIsDualMode = false,
  });

  @override
  State<PlayerModeScreen> createState() => _PlayerModeScreenState();
}

class _PlayerModeScreenState extends State<PlayerModeScreen> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialIsDualMode ? 1 : 0;
    _pageController = PageController(initialPage: _currentPage);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextPage() {
    if (_currentPage < 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleSave() {
    final bool isDualMode = _currentPage == 1;
    context.pop(isDualMode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090812),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            children: [
              // Top Bar: Back Button | Title | Save Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/icons/ic_back.svg',
                        width: 40.r,
                        height: 40.r,
                      ),
                    ),
                  ),

                  // Screen Title: Player Mode
                  Text(
                    context.tr('player_mode_title') == 'player_mode_title'
                        ? 'Player Mode'
                        : context.tr('player_mode_title'),
                    style: AppTextStyles.textWhite20.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  // Save Button
                  GestureDetector(
                    onTap: _handleSave,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7A44DA),Color(0xFFCF6BEE)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        context.tr('save') == 'save'
                            ? 'Save'
                            : context.tr('save'),
                        style: AppTextStyles.textWhite14.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Main Body Carousel Area
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // PageView for Keyboard Previews
                    PageView(
                      controller: _pageController,
                      onPageChanged: _onPageChanged,
                      children: [
                        _buildModePreviewCard(isDual: false),
                        _buildModePreviewCard(isDual: true),
                      ],
                    ),

                    // Far Left Arrow Button
                    Positioned(
                      left: 0,
                      child: GestureDetector(
                        onTap: _previousPage,
                        child: Container(
                          width: 44.r,
                          height: 44.r,
                          decoration: BoxDecoration(
                            color: const Color(0xFF19162A),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Icon(
                            Icons.chevron_left_rounded,
                            color: _currentPage > 0
                                ? Colors.white
                                : Colors.white38,
                            size: 28.r,
                          ),
                        ),
                      ),
                    ),

                    // Far Right Arrow Button
                    Positioned(
                      right: 0,
                      child: GestureDetector(
                        onTap: _nextPage,
                        child: Container(
                          width: 44.r,
                          height: 44.r,
                          decoration: BoxDecoration(
                            color: const Color(0xFF19162A),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Icon(
                            Icons.chevron_right_rounded,
                            color: _currentPage < 1
                                ? Colors.white
                                : Colors.white38,
                            size: 28.r,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Section: Mode Name + Page Dots
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mode Name
                  Text(
                    _currentPage == 0
                        ? (context.tr('single_row_mode') == 'single_row_mode'
                            ? 'Single Row Mode'
                            : context.tr('single_row_mode'))
                        : (context.tr('dual_row_mode') == 'dual_row_mode'
                            ? 'Dual Row Mode'
                            : context.tr('dual_row_mode')),
                    style: AppTextStyles.textWhite18.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Page Indicator Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 10.r,
                        height: 10.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == 0
                              ? const Color(0xFFCF6BEE)
                              : const Color(0xFF555268),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        width: 10.r,
                        height: 10.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == 1
                              ? const Color(0xFFCF6BEE)
                              : const Color(0xFF555268),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModePreviewCard({required bool isDual}) {
    return Center(
      child: Container(
        width: 380.w,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: const Color(0xFF141224),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: const Color(0xFFCF6BEE).withValues(alpha: 0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 15,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildKeyboardGraphicRow(),
            if (isDual) ...[
              SizedBox(height: 6.h),
              // Mini Navigator Bar Graphic
              Container(
                height: 16.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF221F38),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.arrow_left, color: Colors.white70, size: 14),
                    Text(
                      "🎹 Octave Shift",
                      style: AppTextStyles.textWhite12.copyWith(fontSize: 8),
                    ),
                    const Icon(Icons.arrow_right, color: Colors.white70, size: 14),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              _buildKeyboardGraphicRow(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildKeyboardGraphicRow() {
    return Container(
      height: isLandscape(context) ? 65.h : 50.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: List.generate(14, (index) {
          final isBlackKey = index == 1 ||
              index == 3 ||
              index == 5 ||
              index == 8 ||
              index == 10 ||
              index == 12;
          final noteLabels = [
            "A0",
            "B0",
            "C1",
            "D1",
            "E1",
            "F1",
            "G1",
            "A1",
            "B1",
            "C2",
            "D2",
            "E2",
            "F2",
            "A1"
          ];
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              decoration: BoxDecoration(
                color: isBlackKey ? const Color(0xFF1E1E24) : Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4.r),
                  bottomRight: Radius.circular(4.r),
                ),
                border: Border.all(color: Colors.grey.shade400, width: 0.5),
              ),
              alignment: Alignment.bottomCenter,
              padding: EdgeInsets.only(bottom: 4.h),
              child: isBlackKey
                  ? const SizedBox.shrink()
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 2, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(4.r),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Text(
                          noteLabels[index % noteLabels.length],
                          style: const TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
            ),
          );
        }),
      ),
    );
  }

  bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
}
