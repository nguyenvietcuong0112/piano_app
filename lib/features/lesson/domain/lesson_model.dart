import '../../../core/constants/app_constants.dart';

class LessonNote {
  final int type;
  final int group;
  final int position;
  final int breakTime;
  final int duration;

  LessonNote({
    this.type = 0,
    this.group = 4,
    this.position = 0,
    this.breakTime = 400,
    this.duration = 300,
  });

  factory LessonNote.fromJson(Map<String, dynamic> json) {
    return LessonNote(
      type: json['type'] ?? 0,
      group: json['group'] ?? 4,
      position: json['position'] ?? 0,
      breakTime: json['breakTime'] ?? 400,
      duration: json['duration'] ?? 300,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'group': group,
        'position': position,
        'breakTime': breakTime,
        'duration': duration,
      };
}

class LessonNoteContainer {
  final int startOctave;
  final int startKeyPosition;
  final int visibleWhiteKeysCount;
  final List<LessonNote>? data;

  LessonNoteContainer({
    this.startOctave = 4,
    this.startKeyPosition = 0,
    this.visibleWhiteKeysCount = 14,
    this.data,
  });

  factory LessonNoteContainer.fromJson(Map<String, dynamic> json) {
    final noteList = (json['data'] as List<dynamic>?)
        ?.map((e) => LessonNote.fromJson(e as Map<String, dynamic>))
        .toList();

    int rawOctave = json['startOctave'] ?? json['octave'] ?? 4;
    int effectiveOctave = rawOctave;

    if (noteList != null && noteList.isNotEmpty) {
      int minGroup = noteList.map((e) => e.group).reduce((a, b) => a < b ? a : b);
      int maxGroup = noteList.map((e) => e.group).reduce((a, b) => a > b ? a : b);

      // Auto-correct if API returns startOctave that is out of range of note groups
      if (rawOctave < minGroup - 1 || rawOctave > maxGroup) {
        effectiveOctave = minGroup;
      }
    }

    return LessonNoteContainer(
      startOctave: effectiveOctave,
      startKeyPosition: json['startKeyPosition'] ?? json['startPos'] ?? 0,
      visibleWhiteKeysCount: json['visibleWhiteKeysCount'] ?? json['keysCount'] ?? 14,
      data: noteList,
    );
  }

  String get calculatedDurationFormatted {
    if (data == null || data!.isEmpty) return "03:00";
    int totalMs = 0;
    for (var note in data!) {
      totalMs += note.breakTime;
    }
    totalMs += data!.last.duration;

    int totalSec = (totalMs / 1000).round();
    int min = totalSec ~/ 60;
    int sec = totalSec % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }
}

class LessonsItem {
  final int id;
  final String titleName;
  final String authorName;
  final String? genre;
  final String jsonUrlEasy;
  final String jsonUrlMedium;
  final String jsonUrlHard;
  final String? audioUrl;
  final String duration;
  final String thumbnail;
  final int level; // 1: Easy, 2: Medium, 3: Hard
  final int startOctave;
  final int startKeyPosition;
  final int visibleWhiteKeysCount;
  final String createdAt;
  final String? updatedAt;

  LessonsItem({
    required this.id,
    required this.titleName,
    required this.authorName,
    this.genre,
    String? jsonUrlEasy,
    String? lessonsData,
    this.jsonUrlMedium = '',
    this.jsonUrlHard = '',
    this.audioUrl,
    required this.duration,
    required this.thumbnail,
    this.level = 1,
    this.startOctave = 4,
    this.startKeyPosition = 0,
    this.visibleWhiteKeysCount = 14,
    this.createdAt = '',
    this.updatedAt,
  }) : jsonUrlEasy = jsonUrlEasy ?? lessonsData ?? '';

  /// Dynamic getter for lessonsData note URL based on difficulty level (1=Easy, 2=Medium, 3=Hard)
  String get lessonsData {
    String rawPath;
    switch (level) {
      case 2:
        rawPath = jsonUrlMedium.isNotEmpty ? jsonUrlMedium : jsonUrlEasy;
        break;
      case 3:
        rawPath = jsonUrlHard.isNotEmpty
            ? jsonUrlHard
            : (jsonUrlMedium.isNotEmpty ? jsonUrlMedium : jsonUrlEasy);
        break;
      case 1:
      default:
        rawPath = jsonUrlEasy;
        break;
    }

    if (rawPath.isEmpty) return '';

    if (rawPath.startsWith('http://') || rawPath.startsWith('https://')) {
      return rawPath;
    }

    if (rawPath.startsWith('/')) {
      if (!rawPath.startsWith('/piano/')) {
        return '${AppConstants.baseApiHost}/piano$rawPath';
      }
      return '${AppConstants.baseApiHost}$rawPath';
    }

    if (rawPath.endsWith('.json') && !rawPath.contains('/')) {
      return rawPath;
    }

    return '${AppConstants.baseApiHost}/$rawPath';
  }

  /// Dynamic getter for full thumbnail URL (resolves relative API path to absolute host URL)
  String get fullThumbnailUrl {
    if (thumbnail.isEmpty) return '';
    if (thumbnail.startsWith('http://') || thumbnail.startsWith('https://')) {
      return thumbnail;
    }
    if (thumbnail.startsWith('/')) {
      if (!thumbnail.startsWith('/piano/')) {
        return '${AppConstants.baseApiHost}/piano$thumbnail';
      }
      return '${AppConstants.baseApiHost}$thumbnail';
    }
    if (thumbnail.contains('/') || thumbnail.contains('.')) {
      return '${AppConstants.baseApiHost}/$thumbnail';
    }
    return thumbnail;
  }

  LessonsItem copyWith({
    int? id,
    String? titleName,
    String? authorName,
    String? genre,
    String? jsonUrlEasy,
    String? jsonUrlMedium,
    String? jsonUrlHard,
    String? audioUrl,
    String? duration,
    String? thumbnail,
    int? level,
    int? startOctave,
    int? startKeyPosition,
    int? visibleWhiteKeysCount,
    String? createdAt,
    String? updatedAt,
  }) {
    return LessonsItem(
      id: id ?? this.id,
      titleName: titleName ?? this.titleName,
      authorName: authorName ?? this.authorName,
      genre: genre ?? this.genre,
      jsonUrlEasy: jsonUrlEasy ?? this.jsonUrlEasy,
      jsonUrlMedium: jsonUrlMedium ?? this.jsonUrlMedium,
      jsonUrlHard: jsonUrlHard ?? this.jsonUrlHard,
      audioUrl: audioUrl ?? this.audioUrl,
      duration: duration ?? this.duration,
      thumbnail: thumbnail ?? this.thumbnail,
      level: level ?? this.level,
      startOctave: startOctave ?? this.startOctave,
      startKeyPosition: startKeyPosition ?? this.startKeyPosition,
      visibleWhiteKeysCount: visibleWhiteKeysCount ?? this.visibleWhiteKeysCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory LessonsItem.fromJson(Map<String, dynamic> json) {
    String easy = json['json_url_easy'] ?? json['lessonsData'] ?? json['urlData'] ?? '';
    String medium = json['json_url_medium'] ?? '';
    String hard = json['json_url_hard'] ?? '';

    return LessonsItem(
      id: json['id'] ?? 0,
      titleName: json['title'] ?? json['song'] ?? json['name'] ?? json['titleName'] ?? '',
      authorName: json['artist'] ?? json['author'] ?? json['authorName'] ?? 'Unknown',
      genre: json['genre'],
      jsonUrlEasy: easy,
      jsonUrlMedium: medium,
      jsonUrlHard: hard,
      audioUrl: json['audio_url'],
      duration: json['duration'] ?? json['time'] ?? '03:00',
      thumbnail: json['thumbnail'] ?? json['thumb'] ?? json['urlThumb'] ?? '',
      level: json['level'] ?? json['difficulty'] ?? json['star_level'] ?? json['type'] ?? 1,
      startOctave: json['startOctave'] ?? json['octave'] ?? 4,
      startKeyPosition: json['startKeyPosition'] ?? json['startPos'] ?? 0,
      visibleWhiteKeysCount: json['visibleWhiteKeysCount'] ?? json['keysCount'] ?? 14,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'],
    );
  }
}

class LessonsCategory {
  final int categoryID;
  final String categoryName;
  final List<LessonsItem> items;

  LessonsCategory({
    required this.categoryID,
    required this.categoryName,
    required this.items,
  });

  factory LessonsCategory.fromJson(Map<String, dynamic> json) {
    return LessonsCategory(
      categoryID: json['categoryID'] ?? 0,
      categoryName: json['categoryName'] ?? '',
      items: (json['content'] as List<dynamic>?)
              ?.map((e) => LessonsItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          (json['items'] as List<dynamic>?)
              ?.map((e) => LessonsItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class LessonsResponse {
  final List<LessonsCategory> categories;
  final int total;
  final int skip;
  final int limit;

  LessonsResponse({
    required this.categories,
    this.total = 0,
    this.skip = 0,
    this.limit = 20,
  });

  factory LessonsResponse.fromJson(Map<String, dynamic> json) {
    List<LessonsCategory> categories = [];

    if (json.containsKey('items') && json['items'] is List) {
      final itemsListRaw = json['items'] as List<dynamic>;
      
      Map<int, Map<String, dynamic>> categoryMap = {};
      
      for (var itemRaw in itemsListRaw) {
        if (itemRaw is Map<String, dynamic>) {
          final item = LessonsItem.fromJson(itemRaw);
          final categoryId = itemRaw['category_id'] ?? 1;
          final categoryName = itemRaw['category_name'] ?? 'Popular Songs';
          
          if (!categoryMap.containsKey(categoryId)) {
            categoryMap[categoryId] = {
              'category_id': categoryId,
              'category_name': categoryName,
              'items': <LessonsItem>[],
            };
          }
          (categoryMap[categoryId]!['items'] as List<LessonsItem>).add(item);
        }
      }
      
      categories = categoryMap.values.map((catMap) {
        return LessonsCategory(
          categoryID: catMap['category_id'] as int,
          categoryName: catMap['category_name'] as String,
          items: catMap['items'] as List<LessonsItem>,
        );
      }).toList();

      categories.sort((a, b) => a.categoryID.compareTo(b.categoryID));
    } else {
      categories = (json['data'] as List<dynamic>?)
              ?.map((e) => LessonsCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          (json['categories'] as List<dynamic>?)
              ?.map((e) => LessonsCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];
    }

    int totalCount = json['total'] ??
        (categories.isNotEmpty
            ? categories.fold(0, (sum, c) => sum + c.items.length)
            : 0);

    return LessonsResponse(
      categories: categories,
      total: totalCount,
      skip: json['skip'] ?? 0,
      limit: json['limit'] ?? 20,
    );
  }
}

