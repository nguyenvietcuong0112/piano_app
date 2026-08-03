class LessonNote {
  final int type;
  final int group;
  final int position;
  final int breakTime;

  LessonNote({
    this.type = 0,
    this.group = 4,
    this.position = 0,
    this.breakTime = 400,
  });

  factory LessonNote.fromJson(Map<String, dynamic> json) {
    return LessonNote(
      type: json['type'] ?? 0,
      group: json['group'] ?? 4,
      position: json['position'] ?? 0,
      breakTime: json['breakTime'] ?? 400,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        'group': group,
        'position': position,
        'breakTime': breakTime,
      };
}

class LessonNoteContainer {
  final List<LessonNote>? data;

  LessonNoteContainer({this.data});

  factory LessonNoteContainer.fromJson(Map<String, dynamic> json) {
    return LessonNoteContainer(
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

  LessonsItem({
    required this.id,
    required this.titleName,
    required this.authorName,
    required this.duration,
    required this.lessonsData,
    required this.thumbnail,
  });

  factory LessonsItem.fromJson(Map<String, dynamic> json) {
    return LessonsItem(
      id: json['id'] ?? 0,
      titleName: json['song'] ?? json['name'] ?? json['titleName'] ?? json['title'] ?? '',
      authorName: json['artist'] ?? json['author'] ?? json['authorName'] ?? 'Unknown',
      duration: json['duration'] ?? json['time'] ?? '03:00',
      lessonsData: json['lessonsData'] ?? json['urlData'] ?? '',
      thumbnail: json['thumb'] ?? json['urlThumb'] ?? json['thumbnail'] ?? '',
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
