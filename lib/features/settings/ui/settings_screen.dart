import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showRateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text(
          "Rate App",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Do you like our app? Please rate us 5 stars!",
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 32.sp,
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Later", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9E54E5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Submit", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Sharing Piano App..."),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: const Text(
          "Privacy Policy",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const SingleChildScrollView(
          child: Text(
            "We value your privacy. This application respects and protects your personal data. No personal sensitive information is collected or shared with third parties without your consent.",
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close", style: TextStyle(color: Color(0xFF9E54E5))),
          ),
        ],
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
                        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
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
                  "Settings",
                  style: AppTextStyles.textWhite22.copyWith(fontWeight: FontWeight.bold),
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
                  title: "Language",
                  onTap: () => context.push('/language'),
                ),
                _buildSettingTile(
                  icon: Icons.star_outline_rounded,
                  title: "Rate app",
                  onTap: () => _showRateDialog(context),
                ),
                _buildSettingTile(
                  icon: Icons.thumb_up_alt_outlined,
                  title: "Share app",
                  onTap: () => _showShareDialog(context),
                ),
                _buildSettingTile(
                  icon: Icons.shield_outlined,
                  title: "Policy",
                  onTap: () => _showPolicyDialog(context),
                ),
                _buildSettingTile(
                  icon: Icons.menu_book_rounded,
                  title: "Version",
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
