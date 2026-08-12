import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_text_styles.dart';

class CustomHeaderBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onVipTap;
  final VoidCallback? onSettingsTap;

  const CustomHeaderBar({
    super.key,
    required this.title,
    this.onVipTap,
    this.onSettingsTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.symmetric(horizontal: 16.w, vertical: 10),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.textWhite22,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // VIP / Crown Button
              ValueListenableBuilder<bool>(
                valueListenable: AppConstants.isPremiumUser,
                builder: (context, isPremium, child) {
                  if (isPremium) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: onVipTap ?? () => context.push('/premium'),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/icons/ic_premium.svg',
                          width: 40.sp,
                          height: 40.sp,
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Settings Button
              GestureDetector(
                onTap: onSettingsTap ?? () => context.push('/settings'),
                child: Center(
                  child: SvgPicture.asset(
                    'assets/icons/ic_settings.svg',
                    width: 40.sp,
                    height: 40.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
