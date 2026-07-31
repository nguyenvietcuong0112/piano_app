import 'package:flutter/material.dart';
import '../../models/lesson.dart';
import '../../services/local_data_provider.dart';
import '../lesson_play_screen.dart';
import '../play_piano_screen.dart';
import '../all_lessons_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<LessonsCategory> categories = [];
  List<LessonsItem> popularSongs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final response = await LocalDataProvider.getAllLessons();
    if (response != null) {
      final cats = response.categories;
      final List<LessonsItem> allSongs = [];
      for (var c in cats) {
        allSongs.addAll(c.items);
      }
      setState(() {
        categories = cats;
        // Take the first 3 items for the Home tab display
        popularSongs = allSongs.take(3).toList();
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.amber),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF121218),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header App Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Real Piano",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: Colors.white70),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Settings")),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Acoustic Piano Banner Card
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PlayPianoScreen(),
                    ),
                  );
                },
                child: Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF3A1C71), Color(0xFFD76D77)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Acoustic Piano",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Free Play & Waterfall Lessons",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "PLAY NOW",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: Image.asset(
                          'assets/icons/ic_piano.png',
                          width: 72,
                          height: 72,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.piano,
                                  size: 72, color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Featured Popular Songs Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Popular Song Lessons",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (categories.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AllLessonsScreen(
                              categories: categories,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "See All >",
                        style: TextStyle(color: Colors.amber),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              // 3 Top Popular Items List View
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: popularSongs.length,
                itemBuilder: (context, index) {
                  final song = popularSongs[index];
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
            ],
          ),
        ),
      ),
    );
  }
}
