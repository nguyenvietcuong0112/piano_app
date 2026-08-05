import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/theme/theme_service.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/no_data_widget.dart';
import '../../../core/widgets/gradient_tab_pill.dart';
import '../../../core/widgets/theme_image.dart';
import '../domain/theme_model.dart';
import '../state/theme_provider.dart';

class ThemeTab extends ConsumerStatefulWidget {
  const ThemeTab({super.key});

  @override
  ConsumerState<ThemeTab> createState() => _ThemeTabState();
}

class _ThemeTabState extends ConsumerState<ThemeTab> {
  int _selectedCategoryId = 0; // 0 = All categories

  Future<void> _applyTheme(BuildContext context, ThemeItem theme) async {
    await ThemeService.setTheme(theme.resName, theme.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Applied Theme: ${theme.titleName}"),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themesAsync = ref.watch(themesProvider);

    return AppScaffold(
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
          final List<ThemeCategory> rawCategories =
              themeResponse?.themeCategories ?? [];

          // Fallback if JSON fails or empty
          final List<ThemeCategory> categories = rawCategories.isNotEmpty
              ? rawCategories
              : [
                  ThemeCategory(
                    categoryID: 1,
                    categoryName: "Anime & Manga",
                    items: [
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
                    ],
                  ),
                  ThemeCategory(
                    categoryID: 2,
                    categoryName: "Nature",
                    items: [
                      ThemeItem(
                          id: 3,
                          titleName: "Cloud & Sky",
                          imageName: "theme_cloud_sky",
                          resName: "theme_cloud_sky"),
                    ],
                  ),
                  ThemeCategory(
                    categoryID: 3,
                    categoryName: "Universe",
                    items: [
                      ThemeItem(
                          id: 4,
                          titleName: "Star",
                          imageName: "theme_star",
                          resName: "theme_star"),
                    ],
                  ),
                ];

          // Filter categories based on selected chip
          final filteredCategories = _selectedCategoryId == 0
              ? categories
              : categories
                  .where((c) => c.categoryID == _selectedCategoryId)
                  .toList();

          return Column(
            children: [
              _buildCategoryChips(categories),

                // Categorized Theme List
                Expanded(
                  child: ValueListenableBuilder<String>(
                    valueListenable: ThemeService.currentThemeRes,
                    builder: (context, currentThemeRes, child) {
                      if (filteredCategories.isEmpty) {
                        return const NoDataWidget(
                          title: "Không có chủ đề nào",
                          subtitle: "Không tìm thấy giao diện phù hợp với danh mục này.",
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: filteredCategories.length,
                        itemBuilder: (context, catIndex) {
                          final category = filteredCategories[catIndex];
                          return _buildCategorySection(
                              context, category, currentThemeRes);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
      ),
    );
  }

  Widget _buildCategoryChips(List<ThemeCategory> categories) {
    return Container(
      height: 48.h,
      margin: EdgeInsets.only(top: 8.h, bottom: 4.h),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          // "All" chip
          GradientTabPill(
            label: "All",
            isSelected: _selectedCategoryId == 0,
            onTap: () {
              setState(() => _selectedCategoryId = 0);
            },
          ),
          ...categories.map((cat) {
            final isSelected = _selectedCategoryId == cat.categoryID;
            return GradientTabPill(
              label: cat.categoryName,
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  _selectedCategoryId = isSelected ? 0 : cat.categoryID;
                });
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCategorySection(
      BuildContext context, ThemeCategory category, String currentThemeRes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Title Header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            category.categoryName,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Grid of Theme Cards in this category
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: category.items.length,
          itemBuilder: (context, index) {
            final theme = category.items[index];
            final isSelected = theme.resName == currentThemeRes;

            return GestureDetector(
              onTap: () => _applyTheme(context, theme),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? Colors.greenAccent : Colors.white24,
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
                        child: ThemeImage(resName: theme.resName),
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
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
