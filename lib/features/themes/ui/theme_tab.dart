import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_flutter/core/theme/theme_service.dart';
import '../domain/theme_model.dart';
import '../state/theme_provider.dart';

class ThemeTab extends ConsumerWidget {
  const ThemeTab({super.key});

  Future<void> _applyTheme(BuildContext context, ThemeItem theme) async {
    await ThemeService.setTheme(theme.resName, theme.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Applied Theme: ${theme.titleName}"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themesAsync = ref.watch(themesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: themesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.amber)),
        error: (err, stack) => Center(
          child: Text(
            'Error loading themes: $err',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
        data: (themeResponse) {
          List<ThemeItem> allThemes = [];
          if (themeResponse != null) {
            for (var cat in themeResponse.themeCategories) {
              allThemes.addAll(cat.items);
            }
          }

          if (allThemes.isEmpty) {
            allThemes = [
              ThemeItem(
                  id: 1,
                  titleName: "Jujutsu Kaisen",
                  imageName: "theme_jujutsu_kaisen",
                  resName: "theme_jujutsu_kaisen"),
              ThemeItem(
                  id: 2,
                  titleName: "One Piece",
                  imageName: "theme_one_piece",
                  resName: "theme_one_piece"),
              ThemeItem(
                  id: 3,
                  titleName: "Cloud & Sky",
                  imageName: "theme_cloud_sky",
                  resName: "theme_cloud_sky"),
              ThemeItem(
                  id: 4,
                  titleName: "Star Universe",
                  imageName: "theme_star",
                  resName: "theme_star"),
            ];
          }

          return ValueListenableBuilder<String>(
            valueListenable: ThemeService.currentThemeRes,
            builder: (context, currentThemeRes, child) {
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: allThemes.length,
                itemBuilder: (context, index) {
                  final theme = allThemes[index];
                  final isSelected = theme.resName == currentThemeRes;

                  return GestureDetector(
                    onTap: () => _applyTheme(context, theme),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Colors.greenAccent
                              : Colors.white24,
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: Colors.greenAccent.withValues(alpha: 0.4),
                              blurRadius: 10,
                            ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/${theme.resName}.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Image.asset(
                                  'assets/images/${theme.resName}.png',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, err, stack) =>
                                      Container(color: const Color(0xFF2A2A3D)),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              left: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                color: Colors.black.withValues(alpha: 0.75),
                                child: Text(
                                  theme.titleName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  radius: 14,
                                  backgroundColor: Colors.greenAccent,
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.black,
                                    size: 18,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
