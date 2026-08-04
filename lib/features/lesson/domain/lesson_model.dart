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
    return LessonNoteContainer(
      startOctave: json['startOctave'] ?? json['octave'] ?? 4,
      startKeyPosition: json['startKeyPosition'] ?? json['startPos'] ?? 0,
      visibleWhiteKeysCount: json['visibleWhiteKeysCount'] ?? json['keysCount'] ?? 14,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => LessonNote.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LessonsItem {
  final int id;
  final String titleName;
  final String authorName;
  final String duration;
  final String lessonsData;
  final String thumbnail;
  final int level;
  final int startOctave;
  final int startKeyPosition;
  final int visibleWhiteKeysCount;

  LessonsItem({
    required this.id,
    required this.titleName,
    required this.authorName,
    required this.duration,
    required this.lessonsData,
    required this.thumbnail,
    this.level = 1,
    this.startOctave = 4,
    this.startKeyPosition = 0,
    this.visibleWhiteKeysCount = 14,
  });

  factory LessonsItem.fromJson(Map<String, dynamic> json) {
    return LessonsItem(
      id: json['id'] ?? 0,
      titleName: json['song'] ?? json['name'] ?? json['titleName'] ?? json['title'] ?? '',
      authorName: json['artist'] ?? json['author'] ?? json['authorName'] ?? 'Unknown',
      duration: json['duration'] ?? json['time'] ?? '03:00',
      lessonsData: json['lessonsData'] ?? json['urlData'] ?? '',
      thumbnail: json['thumb'] ?? json['urlThumb'] ?? json['thumbnail'] ?? '',
      level: json['level'] ?? json['type'] ?? 1,
      startOctave: json['startOctave'] ?? json['octave'] ?? 4,
      startKeyPosition: json['startKeyPosition'] ?? json['startPos'] ?? 0,
      visibleWhiteKeysCount: json['visibleWhiteKeysCount'] ?? json['keysCount'] ?? 14,
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

  LessonsResponse({required this.categories});

  factory LessonsResponse.fromJson(Map<String, dynamic> json) {
    return LessonsResponse(
      categories: (json['data'] as List<dynamic>?)
              ?.map((e) => LessonsCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          (json['categories'] as List<dynamic>?)
              ?.map((e) => LessonsCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
