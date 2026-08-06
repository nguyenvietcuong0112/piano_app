import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/recording_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/no_data_widget.dart';
import '../../../core/widgets/primary_button.dart';

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
        title: Text("Delete Recording", style: TextStyle(color: Colors.white, fontSize: 16.r)),
        content: Text(
          "Are you sure you want to delete this recording?",
          style: TextStyle(color: Colors.white70, fontSize: 13.r),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel", style: TextStyle(color: Colors.white60, fontSize: 13.r)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text("Delete", style: TextStyle(color: Colors.white, fontSize: 13.r)),
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
        title: Text("Rename Recording", style: TextStyle(color: Colors.white, fontSize: 16.r)),
        content: TextField(
          controller: controller,
          style: TextStyle(color: Colors.white, fontSize: 14.r),
          decoration: InputDecoration(
            hintText: "Enter title",
            hintStyle: TextStyle(color: Colors.white54, fontSize: 13.r),
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
            child: Text("Cancel", style: TextStyle(color: Colors.white60, fontSize: 13.r)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFCF6BEE),
            ),
            child: Text("Save", style: TextStyle(color: Colors.white, fontSize: 13.r)),
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
            "Recording",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.r,
              fontWeight: FontWeight.bold,
            ),
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
            label: "My recording",
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.r,
                    fontWeight: FontWeight.bold,
                  ),
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
        height: 52.h,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: const Color(0xFF1B162C),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
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
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.r,
                  fontWeight: FontWeight.w500,
                ),
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
    return const NoDataWidget(
      imageAsset: 'assets/images/img_nodata.png',
      imageHeight: 110,
      title: "No recordings yet",
      subtitle: "Your recordings will appear here",
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
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.r,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  item.date,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontSize: 11.r,
                  ),
                ),
              ],
            ),
          ),

          // Duration
          Text(
            item.duration,
            style: TextStyle(
              color: const Color(0xFFB880FF),
              fontSize: 12.r,
              fontWeight: FontWeight.w500,
            ),
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
