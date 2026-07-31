class LessonNote {
  final int type; // 0: white, 1: black
  final int group; // octave (e.g. 4)
  final int position; // position within octave (0..6)
  final int breakTime; // delay ms before next note

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
  final int level;
  final int score;

  LessonsItem({
    required this.id,
    required this.titleName,
    required this.authorName,
    required this.duration,
    required this.lessonsData,
    required this.thumbnail,
    this.level = 1,
    this.score = 100,
  });

  factory LessonsItem.fromJson(Map<String, dynamic> json) {
    return LessonsItem(
      id: json['id'] ?? 0,
      titleName: json['song'] ?? json['titleName'] ?? '',
      authorName: json['artist'] ?? json['authorName'] ?? '',
      duration: json['duration'] ?? '02:30',
      lessonsData: json['lessonsData'] ?? '',
      thumbnail: json['thumb'] ?? json['thumbnail'] ?? '',
      level: json['level'] ?? 1,
      score: json['score'] ?? 100,
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

class PopularResponse {
  final List<LessonsCategory> categories;

  PopularResponse({required this.categories});

  factory PopularResponse.fromJson(Map<String, dynamic> json) {
    return PopularResponse(
      categories: (json['data'] as List<dynamic>?)
              ?.map((e) => LessonsCategory.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
