class ThemeItem {
  final int id;
  final String titleName;
  final String imageName;
  final String resName;

  ThemeItem({
    required this.id,
    required this.titleName,
    required this.imageName,
    required this.resName,
  });

  factory ThemeItem.fromJson(Map<String, dynamic> json) {
    return ThemeItem(
      id: json['id'] ?? 0,
      titleName: json['name'] ?? json['titleName'] ?? '',
      imageName: json['urlThumb'] ?? json['imageName'] ?? 'theme_jujutsu_kaisen',
      resName: json['urlTheme'] ?? json['resName'] ?? 'theme_jujutsu_kaisen',
    );
  }
}

class ThemeCategory {
  final int categoryID;
  final String categoryName;
  final List<ThemeItem> items;

  ThemeCategory({
    required this.categoryID,
    required this.categoryName,
    required this.items,
  });

  factory ThemeCategory.fromJson(Map<String, dynamic> json) {
    return ThemeCategory(
      categoryID: json['categoryID'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      items: (json['content'] as List<dynamic>?)
              ?.map((e) => ThemeItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          (json['items'] as List<dynamic>?)
              ?.map((e) => ThemeItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ThemeResponse {
  final List<ThemeCategory> themeCategories;

  ThemeResponse({required this.themeCategories});

  factory ThemeResponse.fromJson(Map<String, dynamic> json) {
    return ThemeResponse(
      themeCategories: (json['data'] as List<dynamic>?)
              ?.map((e) => ThemeCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          (json['themeCategories'] as List<dynamic>?)
              ?.map((e) => ThemeCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
