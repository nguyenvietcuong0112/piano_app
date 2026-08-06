class ThemeItem {
  final int id;
  final String titleName;
  final String imageName;
  final String resName;
  final String folder;
  final String? urlThumb;
  final String? urlTheme;

  ThemeItem({
    required this.id,
    required this.titleName,
    required this.imageName,
    required this.resName,
    this.folder = 'default',
    this.urlThumb,
    this.urlTheme,
  });

  static String _cleanName(String raw) {
    if (raw.isEmpty) return 'Theme Item';
    var name = raw;
    if (name.startsWith('IMAGE_')) {
      name = name.substring(6);
    }
    if (name.endsWith('.jpg') || name.endsWith('.png') || name.endsWith('.webp')) {
      name = name.substring(0, name.lastIndexOf('.'));
    }
    return name.isNotEmpty ? name : 'Theme Item';
  }

  factory ThemeItem.fromJson(Map<String, dynamic> json) {
    final originalUrl = json['original_image_url'] ?? json['urlTheme'] ?? json['resName'];
    final thumbUrl = json['thumbnail_image_url'] ?? json['urlThumb'] ?? json['imageName'];
    final res = originalUrl ?? thumbUrl ?? 'theme_1';

    final catFolder = json['category'] ?? json['folder'] ?? 'default';
    final rawName = json['name'] ?? json['titleName'] ?? 'Theme Item';

    final int parsedId = json['id'] is int
        ? json['id']
        : (json['id']?.toString().hashCode ?? 0);

    return ThemeItem(
      id: parsedId,
      titleName: _cleanName(rawName),
      imageName: thumbUrl ?? res,
      resName: originalUrl ?? res,
      folder: catFolder.toString().toLowerCase(),
      urlThumb: thumbUrl,
      urlTheme: originalUrl,
    );
  }
}

class ThemeCategory {
  final int categoryID;
  final String categoryName;
  final String folder;
  final List<ThemeItem> items;

  ThemeCategory({
    required this.categoryID,
    required this.categoryName,
    this.folder = 'default',
    required this.items,
  });

  static String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }

  factory ThemeCategory.fromJson(Map<String, dynamic> json) {
    final catName = json['categoryName'] ?? json['category'] ?? 'General';
    return ThemeCategory(
      categoryID: json['categoryID'] ?? catName.hashCode,
      categoryName: _capitalize(catName.toString()),
      folder: (json['folder'] ?? catName).toString().toLowerCase(),
      items: (json['content'] as List<dynamic>?)
              ?.map((e) => ThemeItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          (json['items'] as List<dynamic>?)
              ?.map((e) => ThemeItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          (json['images'] as List<dynamic>?)
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
    // Check if response is from WallAPI (flat list of images with 'category')
    if (json.containsKey('images') && json['images'] is List) {
      final List<dynamic> imagesList = json['images'];
      final Map<String, List<ThemeItem>> groupMap = {};

      for (final item in imagesList) {
        if (item is Map<String, dynamic>) {
          final themeItem = ThemeItem.fromJson(item);
          final catKey = themeItem.folder;
          groupMap.putIfAbsent(catKey, () => []).add(themeItem);
        }
      }

      int catId = 1;
      final List<ThemeCategory> categories = [];
      groupMap.forEach((catKey, items) {
        final catName = catKey.isEmpty
            ? 'General'
            : catKey[0].toUpperCase() + catKey.substring(1);
        categories.add(ThemeCategory(
          categoryID: catId++,
          categoryName: catName,
          folder: catKey,
          items: items,
        ));
      });

      return ThemeResponse(themeCategories: categories);
    }

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
