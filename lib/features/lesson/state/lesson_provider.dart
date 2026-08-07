import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/shared_preference_service.dart';
import '../data/lesson_datasource.dart';
import '../domain/lesson_model.dart';

final lessonDataSourceProvider = Provider<LessonDataSource>((ref) {
  return LessonDataSource();
});

final lessonsProvider = FutureProvider<LessonsResponse?>((ref) async {
  final ds = ref.watch(lessonDataSourceProvider);
  return await ds.getAllLessons();
});

final lessonNotesProvider =
    FutureProvider.family<List<LessonNote>, String>((ref, fileName) async {
  final ds = ref.watch(lessonDataSourceProvider);
  return await ds.getLessonNotes(fileName);
});

class UnlockedLessonsNotifier extends StateNotifier<Set<String>> {
  UnlockedLessonsNotifier() : super({}) {
    _loadUnlockedLessons();
  }

  Future<void> _loadUnlockedLessons() async {
    final list = await SharedPreferenceService.getUnlockedLessons();
    state = list.toSet();
  }

  Future<void> unlockLesson(String songId) async {
    await SharedPreferenceService.unlockLesson(songId);
    state = {...state, songId};
  }
}

final unlockedLessonsProvider =
    StateNotifierProvider<UnlockedLessonsNotifier, Set<String>>((ref) {
  return UnlockedLessonsNotifier();
});
