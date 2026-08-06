import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/services/shared_preference_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _shareApp() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String packageName = packageInfo.packageName;
      final String shareUrl =
          'https://play.google.com/store/apps/details?id=$packageName';
      await Share.share(shareUrl);
    } catch (e) {
      debugPrint('Error sharing app: $e');
    }
  }

  Future<void> _openPolicyUrl() async {
    final Uri uri = Uri.parse('https://everprofit.ltd/privacy');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Error launching policy url: $e');
    }
  }

  void _showRateDialog(BuildContext context) {
    int selectedRating = 5;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: const Color(0xFF1E1E2C),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
            title: Text(
              context.tr('rate_dialog_title'),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.tr('rate_dialog_desc'),
                  style: const TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    final isFilled = starIndex <= selectedRating;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRating = starIndex;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Icon(
                          isFilled
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: isFilled ? Colors.amber : Colors.grey,
                          size: 36.sp,
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text(context.tr('later'),
                    style: const TextStyle(color: Colors.white54)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9E54E5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await SharedPreferenceService.setBool('is_app_rated', true);
                  await SharedPreferenceService.setInt(
                      'user_app_rating', selectedRating);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Thank you for rating us $selectedRating stars!'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: Text(context.tr('submit'),
                    style: const TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar with Back Button & Centered Title
          Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: 20.h),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40.sp,
                      height: 40.sp,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E2C),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.10)),
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/ic_back.svg',
                        width: 40.sp,
                        height: 40.sp,
                      ),
                    ),
                  ),
                ),
                Text(
                  context.tr('settings'),
                  style: AppTextStyles.textWhite22
                      .copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Menu List
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildSettingTile(
                  icon: Icons.language_rounded,
                  title: context.tr('language'),
                  onTap: () => context.push('/language', extra: false),
                ),
                _buildSettingTile(
                  icon: Icons.star_outline_rounded,
                  title: context.tr('rate_app'),
                  onTap: () => _showRateDialog(context),
                ),
                _buildSettingTile(
                  icon: Icons.thumb_up_alt_outlined,
                  title: context.tr('share_app'),
                  onTap: _shareApp,
                ),
                _buildSettingTile(
                  icon: Icons.shield_outlined,
                  title: context.tr('policy'),
                  onTap: _openPolicyUrl,
                ),
                _buildSettingTile(
                  icon: Icons.menu_book_rounded,
                  title: context.tr('version'),
                  trailingText: "0.0.1",
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: const LinearGradient(
          colors: [Color(0xFF141126), Color(0xFF0F0F1E)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            child: Row(
              children: [
                // Circular Purple Icon Badge
                Container(
                  width: 42.sp,
                  height: 42.sp,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF9E54E5), Color(0xFF6C38CC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 22.sp,
                  ),
                ),
                SizedBox(width: 14.w),
                // Title
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // Optional Trailing Text (e.g., Version)
                if (trailingText != null)
                  Text(
                    trailingText,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
