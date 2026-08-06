import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/widgets/app_loading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/shared_preference_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/no_data_widget.dart';
import '../../../core/widgets/song_thumbnail.dart';
import '../../lesson/domain/lesson_model.dart';

class MySongsTab extends ConsumerStatefulWidget {
  const MySongsTab({super.key});

  @override
  ConsumerState<MySongsTab> createState() => _MySongsTabState();
}

class _MySongsTabState extends ConsumerState<MySongsTab> {
  List<Map<String, dynamic>> _completedSongs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _loadCompletedSongs();
  }

  Future<void> _loadCompletedSongs() async {
    setState(() => _isLoading = true);
    final list = await SharedPreferenceService.getCompletedSongsList();
    if (mounted) {
      setState(() {
        _completedSongs = list;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    int totalCompleted = _completedSongs.length;
    int perfectMastered = _completedSongs.where((s) => (s['stars'] as num?)?.toInt() == 5).length;

    return AppScaffold(
      body: RefreshIndicator(
        onRefresh: _loadCompletedSongs,
        color: const Color(0xFFAD57E6),
        backgroundColor: const Color(0xFF1E1E2C),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(top: 16.h, bottom: 90.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Summary Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B1E63), Color(0xFF1A1438)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: const Color(0x66AD57E6), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFAD57E6).withValues(alpha: 0.15),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        color: Color(0xFFAD57E6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 30),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Bộ Sưu Tập Bài Hát Đã Đánh",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white10,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "🎵 Đã học: $totalCompleted",
                                  style: const TextStyle(color: Colors.cyanAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  "🌟 5 Sao: $perfectMastered",
                                  style: const TextStyle(color: Colors.amberAccent, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Danh Sách Đã Hoàn Thành",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: _loadCompletedSongs,
                    icon: const Icon(Icons.refresh_rounded, color: Color(0xFFAD57E6), size: 20),
                    tooltip: "Làm mới",
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: AppLoading(),
                )
              else if (_completedSongs.isEmpty)
                NoDataWidget(
                  title: "Chưa có bài hát luyện tập nào",
                  subtitle: "Hãy chọn bài học bất kỳ ở màn Home và hoàn thành bài chơi để lưu lịch sử vào đây nhé!",
                  actionText: "Khám Phá Bài Hát Ngay",
                  actionIcon: Icons.play_arrow_rounded,
                  onActionPressed: () => context.go('/home'),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _completedSongs.length,
                  itemBuilder: (context, index) {
                    final item = _completedSongs[index];
                    final String songId = item['songId']?.toString() ?? '0';
                    final String title = item['titleName'] ?? 'Unknown Song';
                    final String artist = item['authorName'] ?? 'Unknown Artist';
                    final String duration = item['duration'] ?? '03:00';
                    final String lessonsData = item['lessonsData'] ?? '';
                    final int level = (item['level'] as num?)?.toInt() ?? 1;
                    final int stars = (item['stars'] as num?)?.toInt() ?? 0;
                    final int accuracy = (item['accuracy'] as num?)?.toInt() ?? 0;

                    final thumbUrl = (item['thumb'] ?? item['thumbnail'] ?? '').toString();

                    final lessonItem = LessonsItem(
                      id: int.tryParse(songId) ?? DateTime.now().millisecondsSinceEpoch,
                      titleName: title,
                      authorName: artist,
                      duration: duration,
                      lessonsData: lessonsData,
                      level: level,
                      thumbnail: thumbUrl,
                    );

                    return GestureDetector(
                      onTap: () async {
                        await context.push('/lesson-play', extra: lessonItem);
                        await SystemChrome.setPreferredOrientations([
                          DeviceOrientation.portraitUp,
                        ]);
                        _loadCompletedSongs();
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
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
                        child: Row(
                          children: [
                            // Music Thumbnail Container
                            SongThumbnail(
                              thumbnailUrl: thumbUrl,
                              width: 80.sp,
                              height: 80.sp,
                              borderRadius: 14,
                            ),
                            const SizedBox(width: 14),

                            // Song Info & Stars
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: AppTextStyles.textWhite14,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    artist,
                                    style: AppTextStyles.textGrey12,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),

                                  // Stars Rating
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    alignment: Alignment.centerLeft,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ...List.generate(5, (starIdx) {
                                          return Icon(
                                            starIdx < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                                            color: starIdx < stars ? Colors.amber : Colors.white24,
                                            size: 12,
                                          );
                                        }),
                                        const SizedBox(width: 6), 
                                        Text(
                                          "$accuracy% ACC",
                                          style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Play Button
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFD065F2),
                                    borderRadius: BorderRadius.circular(16.r),
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFFCC69EE).withValues(alpha: 0.25),
                                        const Color(0xFF7745D3).withValues(alpha: 0.25),
                                      ],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.replay_rounded, size: 14, color: Colors.white),
                                      SizedBox(width: 4.w),
                                      Text(
                                        "Luyện lại",
                                        style: AppTextStyles.textWhite12.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
