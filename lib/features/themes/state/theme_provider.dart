import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/theme_datasource.dart';
import '../domain/theme_model.dart';

final themeDataSourceProvider = Provider<ThemeDataSource>((ref) {
  return ThemeDataSource();
});

final themesProvider = FutureProvider<ThemeResponse?>((ref) async {
  final ds = ref.watch(themeDataSourceProvider);
  return await ds.getThemes();
});
