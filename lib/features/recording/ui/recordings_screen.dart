import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../ads/dimens/ad_dimen.dart';
import '../../../core/services/recording_storage_service.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/no_data_widget.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../ads/const/ad_id_name.dart';
import '../../../ads/const/ad_id_extension.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/firebase_remote_config_service.dart';
import 'package:easy_ads_flutter/easy_ads_flutter.dart';

class RecordingsScreen extends StatefulWidget {
  const RecordingsScreen({super.key});

  @override
  State<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends State<RecordingsScreen> {
  int _selectedTabIndex = 0; // 0: My recording, 1: Piano Sheets
  List<RecordingItemModel> _recordings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRecordings();
  }

  Future<void> _loadRecordings() async {
    setState(() => _isLoading = true);
    final list = await RecordingStorageService.getRecordings();
    setState(() {
      _recordings = list;
      _isLoading = false;
    });
  }

  Future<void> _handleDelete(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C182F),
        title: Text(context.tr('delete_rec'), style: AppTextStyles.textWhite16),
        content: Text(
          context.tr('delete_rec_confirm'),
          style: AppTextStyles.textGrey14,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.tr('cancel'), style: AppTextStyles.textGrey14),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(context.tr('delete'), style: AppTextStyles.textWhite14),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await RecordingStorageService.deleteRecording(id);
      _loadRecordings();
    }
  }

  Future<void> _handleRename(RecordingItemModel item) async {
    final controller = TextEditingController(text: item.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C182F),
        title: Text(context.tr('rename_rec'), style: AppTextStyles.textWhite16),
        content: TextField(
          controller: controller,
          style: AppTextStyles.textWhite14,
          decoration: InputDecoration(
            hintText: context.tr('enter_rec_title'),
            hintStyle: AppTextStyles.textGrey14,
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFCF6BEE)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFCF6BEE), width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(context.tr('cancel'), style: AppTextStyles.textGrey14),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCF6BEE),
            ),
            child: Text(context.tr('save'), style: AppTextStyles.textWhite14),
          ),
        ],
      ),
    );

    if (newTitle != null && newTitle.isNotEmpty) {
      await RecordingStorageService.updateRecording(item.copyWith(title: newTitle));
      _loadRecordings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            _buildTopHeader(),

            // Main Body: Sidebar + Content
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Sidebar Menu
                  _buildSidebar(),

                  // Divider
                  Container(
                    width: 1,
                    color: Colors.white.withValues(alpha: 0.08),
                  ),

                  // Right Content Area
                  Expanded(
                    child: _selectedTabIndex == 0
                        ? _buildMyRecordingsContent()
                        : _buildPianoSheetsContent(),
                  ),
                ],
              ),
            ),

            // Bottom Banner Ad
            if (!AppConstants.isPremiumUser.value &&
                FirebaseRemoteConfigService.getBoolConfigByKey(
                  FirebaseRemoteConfigService.native_banner,
                ))
              SizedBox(
                width: double.infinity,
                child: EasyNativeAd(
                  factoryId: MyAdIdName.nativeBanner,
                  adId: MyAdIdName.nativeBanner.getId,
                  adIdName: MyAdIdName.nativeBanner,
                  height: AdDimen.nativeBannerHeight,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Back Button
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => context.pop(),
              child: SvgPicture.asset(
                'assets/icons/ic_back.svg',
                width: 40.r,
                height: 40.r,
              ),
            ),
          ),

          // Title
          Text(
            context.tr('my_recordings'),
            style: AppTextStyles.textWhite18,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 130.w,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // My recording Tab
          _buildSidebarTab(
            index: 0,
            icon: Icons.mic_rounded,
            label: context.tr('my_recordings'),
          ),
          SizedBox(height: 12.h),
          // Piano Sheets Tab
          _buildSidebarTab(
            index: 1,
            icon: Icons.piano_rounded,
            label: "Piano Sheets",
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarTab({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedTabIndex == index;

    if (isSelected) {
      return PrimaryButton(
        text: label,
        height: 66.r,
        borderRadius: 16,
        backgroundGradient: const LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [
            Color(0xFF8B56ED),
            Color(0xFF5333A5),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFFCE64F0).withValues(alpha: 0.5),
            Color(0xFF999999).withValues(alpha: 0.5),
            Color(0xFFFFFFFF).withValues(alpha: 0.5),
          ],
          stops: [0.0, 0.5, 1.0],
        ),
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFCF6BEE),Color(0xFF7A44DA)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.textWhite14.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        height: 66.r,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: const Color(0xFF131024),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.r),
                color: const Color(0xFF282042),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.textGrey14.copyWith(color: Colors.white70),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyRecordingsContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFCF6BEE)),
      );
    }

    if (_recordings.isEmpty) {
      return _buildEmptyRecordingsView();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: _recordings.length,
      itemBuilder: (context, index) {
        final item = _recordings[index];
        return _buildRecordingRowItem(item);
      },
    );
  }

  Widget _buildEmptyRecordingsView() {
    return NoDataWidget(
      imageAsset: 'assets/images/img_empty_recording.png',
      imageHeight: 110,
      title: context.tr('no_recordings_yet'),
      subtitle: context.tr('no_recordings_sub'),
    );
  }

  Widget _buildRecordingRowItem(RecordingItemModel item) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFF131024),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Music Note Purple Circle Icon Badge
          Container(
            width: 38.r,
            height: 38.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF7E48F0), Color(0xFF9B63F8)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Icon(
              Icons.music_note_rounded,
              color: Colors.white,
              size: 20.r,
            ),
          ),
          SizedBox(width: 12.w),

          // Recording Title & Date Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: AppTextStyles.textWhite14.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  item.date,
                  style: AppTextStyles.textGrey12.copyWith(color: Colors.white.withValues(alpha: 0.45)),
                ),
              ],
            ),
          ),

          // Duration
          Text(
            item.duration,
            style: AppTextStyles.textPurple12.copyWith(color: const Color(0xFFB880FF), fontSize: 12.r, fontWeight: FontWeight.w500),
          ),
          SizedBox(width: 16.w),

          // Delete Action Button
          GestureDetector(
            onTap: () => _handleDelete(item.id),
            child: Icon(
              Icons.delete_outline_rounded,
              color: const Color(0xFFB880FF),
              size: 20.r,
            ),
          ),
          SizedBox(width: 14.w),

          // Edit / Rename Action Button
          GestureDetector(
            onTap: () => _handleRename(item),
            child: Icon(
              Icons.edit_outlined,
              color: const Color(0xFFB880FF),
              size: 20.r,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPianoSheetsContent() {
    return const NoDataWidget(
      imageAsset: 'assets/images/img_nodata.png',
      imageHeight: 110,
      title: "No piano sheets available",
      subtitle: "Your exported piano sheet notes will be displayed here",
    );
  }
}
