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
    final assetPath = isDual
        ? 'assets/images/img_dual_mode.png'
        : 'assets/images/img_single_mode.png';

    return Center(
      child: Container(
        width: 0.65.sw,
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: const Color(0xFF141224),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 20,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: Image.asset(
            assetPath,
            width: double.infinity,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildFullKeyboardPreviewBlock(),
                  if (isDual) ...[
                    SizedBox(height: 8.h),
                    _buildFullKeyboardPreviewBlock(),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFullKeyboardPreviewBlock() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141320),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top Mini Overview Navigator Bar
          Container(
            height: 24.h,
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1C2E),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11.r),
                topRight: Radius.circular(11.r),
              ),
            ),
            child: Row(
              children: [
                // << Fast Left
                const Icon(Icons.fast_rewind_rounded, color: Colors.white70, size: 14),
                SizedBox(width: 4.w),
                // < Left
                const Icon(Icons.arrow_left_rounded, color: Colors.white70, size: 16),
                SizedBox(width: 8.w),

                // Center Mini Keyboard Overview Map
                Expanded(
                  child: Container(
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF100E1D),
                      borderRadius: BorderRadius.circular(3.r),
                      border: Border.all(color: Colors.white24, width: 0.5),
                    ),
                    child: Stack(
                      children: [
                        // Mini White Keys Background
                        Row(
                          children: List.generate(40, (i) => Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 0.2),
                              color: Colors.white54,
                            ),
                          )),
                        ),
                        // Mini Active Viewport Box Highlight (White rectangle)
                        Positioned(
                          left: 8.w,
                          top: 0,
                          bottom: 0,
                          width: 28.w,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(2.r),
                              boxShadow: const [
                                BoxShadow(color: Colors.white70, blurRadius: 2),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: 8.w),
                // > Right
                const Icon(Icons.arrow_right_rounded, color: Colors.white70, size: 16),
                SizedBox(width: 4.w),
                // >> Fast Right
                const Icon(Icons.fast_forward_rounded, color: Colors.white70, size: 14),
              ],
            ),
          ),

          // Main Keyboard Row Layout
          Container(
            height: isLandscape(context) ? 75.h : 60.h,
            padding: const EdgeInsets.all(2),
            child: Stack(
              children: [
                // White Keys Row
                Row(
                  children: [
                    _buildPreviewWhiteKey("A0", false),
                    _buildPreviewWhiteKey("B0", false),
                    _buildPreviewWhiteKey("C1", true), // C keys have rounded pill
                    _buildPreviewWhiteKey("D1", false),
                    _buildPreviewWhiteKey("E1", false),
                    _buildPreviewWhiteKey("F1", false),
                    _buildPreviewWhiteKey("G1", false),
                    _buildPreviewWhiteKey("A1", false),
                    _buildPreviewWhiteKey("B1", false),
                    _buildPreviewWhiteKey("C2", true), // C keys have rounded pill
                    _buildPreviewWhiteKey("D2", false),
                    _buildPreviewWhiteKey("E2", false),
                    _buildPreviewWhiteKey("F2", false),
                    _buildPreviewWhiteKey("A1", false),
                    _buildPreviewWhiteKey("A1", false),
                  ],
                ),

                // Black Keys Row Overlay
                Positioned.fill(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final totalWhiteKeys = 15;
                      final keyWidth = constraints.maxWidth / totalWhiteKeys;
                      final blackKeyIndices = [0, 2, 3, 5, 6, 7, 9, 10, 12, 13];

                      return Stack(
                        children: blackKeyIndices.map((idx) {
                          return Positioned(
                            left: (idx + 1) * keyWidth - (keyWidth * 0.3),
                            top: 0,
                            width: keyWidth * 0.6,
                            height: constraints.maxHeight * 0.6,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E24),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(3.r),
                                  bottomRight: Radius.circular(3.r),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewWhiteKey(String label, bool isPill) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(4.r),
            bottomRight: Radius.circular(4.r),
          ),
          border: Border.all(color: Colors.black26, width: 0.5),
        ),
        alignment: Alignment.bottomCenter,
        padding: EdgeInsets.only(bottom: 6.h),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: isPill
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(color: Colors.black45, width: 0.8),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
        ),
      ),
    );
  }

  bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
}
