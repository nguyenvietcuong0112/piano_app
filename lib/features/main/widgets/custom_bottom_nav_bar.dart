import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/gradient_border_card.dart';

class CustomNavItem {
  final String label;
  final String? svgPath;
  final IconData iconData;

  const CustomNavItem({
    required this.label,
    this.svgPath,
    required this.iconData,
  });
}

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<CustomNavItem>? items;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items,
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFAD57E6);
    const inactiveColor = Color(0xFF8A8A9E);

    final navItems = items ?? [
      CustomNavItem(
        label: context.tr('home'),
        svgPath: "assets/icons/ic_nav_home.svg",
        iconData: Icons.home_rounded,
      ),
      CustomNavItem(
        label: context.tr('themes'),
        svgPath: "assets/icons/ic_nav_theme.svg",
        iconData: Icons.palette_rounded,
      ),
      CustomNavItem(
        label: context.tr('piano'),
        svgPath: "assets/icons/ic_nav_piano.svg",
        iconData: Icons.piano_rounded,
      ),
      CustomNavItem(
        label: context.tr('my_songs'),
        svgPath: "assets/icons/ic_nav_my_song.svg",
        iconData: Icons.music_note_rounded,
      ),
    ];

    return GradientBorderCard(
      height: 74.sp,
      margin:  EdgeInsets.symmetric(horizontal: 8.sp),
      padding: EdgeInsets.symmetric(horizontal: 12.sp),
      borderRadius: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final isSelected = index == currentIndex;
          final item = navItems[index];
          final color = isSelected ? activeColor : inactiveColor;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildIcon(item, color),
                  const SizedBox(height: 4),
                  Text(
                    item.label,
                    style: AppTextStyles.textGrey12.copyWith(
                      color: color,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      letterSpacing: 0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildIcon(CustomNavItem item, Color color) {
    if (item.svgPath != null && item.svgPath!.isNotEmpty) {
      return SvgPicture.asset(
        item.svgPath!,
        width: 24.sp,
        height: 24.sp,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        placeholderBuilder: (context) => Icon(
          item.iconData,
          size: 24.sp,
          color: color,
        ),
      );
    }
    return Icon(
      item.iconData,
      size: 24,
      color: color,
    );
  }
}
