import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../domain/lesson_model.dart';
import '../state/lesson_provider.dart';

class AllLessonsScreen extends ConsumerWidget {
  final List<LessonsCategory> categories;

  const AllLessonsScreen({super.key, this.categories = const []});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(lessonsProvider);
    final displayCategories = categories.isNotEmpty
        ? categories
        : (lessonsAsync.asData?.value?.categories ?? []);

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
          onPressed: () => context.pop(),
        ),
      ),
      body: displayCategories.isEmpty
          ? const Center(
              child: Text(
                "No lessons found",
                style: TextStyle(color: Colors.white54),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: displayCategories.length,
              itemBuilder: (context, catIndex) {
                final category = displayCategories[catIndex];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        category.categoryName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: category.items.length,
                      itemBuilder: (context, itemIndex) {
                        final song = category.items[itemIndex];
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
                              backgroundColor:
                                  Colors.amber.withValues(alpha: 0.15),
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
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    song.titleName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: song.level == 1
                                        ? const Color(0xFF1B5E20)
                                        : (song.level == 2
                                            ? const Color(0xFFE65100)
                                            : const Color(0xFFB71C1C)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    song.level == 1
                                        ? "⭐ Dễ"
                                        : (song.level == 2
                                            ? "⭐⭐ Vừa"
                                            : "⭐⭐⭐ Khó"),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
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
                            onTap: () => context.push('/lesson-play', extra: song),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
    );
  }
}
