import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  final List<CustomNavItem> items;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items = const [
      CustomNavItem(
        label: "Home",
        svgPath: "assets/icons/ic_nav_home.svg",
        iconData: Icons.home_rounded,
      ),
      CustomNavItem(
        label: "Theme",
        svgPath: "assets/icons/ic_nav_theme.svg",
        iconData: Icons.palette_rounded,
      ),
      CustomNavItem(
        label: "Piano",
        svgPath: "assets/icons/ic_nav_piano.svg",
        iconData: Icons.piano_rounded,
      ),
      CustomNavItem(
        label: "My Song",
        svgPath: "assets/icons/ic_nav_my_song.svg",
        iconData: Icons.music_note_rounded,
      ),
    ],
  });

  @override
  Widget build(BuildContext context) {
    const activeColor = Color(0xFFAD57E6);
    const inactiveColor = Color(0xFF8A8A9E);

    return GradientBorderCard(
      height: 74,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      borderRadius: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isSelected = index == currentIndex;
          final item = items[index];
          final color = isSelected ? activeColor : inactiveColor;

          return Expanded(
            child: InkWell(
              onTap: () => onTap(index),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SVG Icon with Fallback to IconData
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
        width: 24,
        height: 24,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        placeholderBuilder: (context) => Icon(
          item.iconData,
          size: 24,
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
