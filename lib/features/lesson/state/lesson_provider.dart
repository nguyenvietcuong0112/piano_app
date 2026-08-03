import 'package:flutter_riverpod/flutter_riverpod.dart';
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
