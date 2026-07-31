import 'package:flutter/material.dart';
import '../models/lesson.dart';
import 'lesson_play_screen.dart';

class AllLessonsScreen extends StatelessWidget {
  final List<LessonsCategory> categories;

  const AllLessonsScreen({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121218),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E2C),
        elevation: 0,
        title: const Text(
          "All Song Lessons",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: categories.isEmpty
          ? const Center(
              child: Text(
                "No lessons available",
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, catIndex) {
                final category = categories[catIndex];
                final songs = category.items;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category Header
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            category.categoryName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Song Tiles for this Category
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: songs.length,
                      itemBuilder: (context, songIndex) {
                        final song = songs[songIndex];
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E2C),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white10),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            leading: CircleAvatar(
                              backgroundColor: Colors.amber.withOpacity(0.15),
                              child: Image.asset(
                                'assets/icons/ic_note.png',
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.music_note,
                                        color: Colors.amber),
                              ),
                            ),
                            title: Text(
                              song.titleName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            subtitle: Text(
                              "${song.authorName} • ${song.duration}",
                              style: const TextStyle(
                                  color: Colors.white60, fontSize: 13),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                "PLAY",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      LessonPlayScreen(lesson: song),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
    );
  }
}
