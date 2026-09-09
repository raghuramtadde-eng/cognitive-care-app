enum MemoryLaneType { photo, song, habit }

extension MemoryLaneTypeX on MemoryLaneType {
  String get key => name;
  static MemoryLaneType fromKey(String key) =>
      MemoryLaneType.values.firstWhere((e) => e.name == key);
}

/// A personalized reminiscence memory added by the caregiver: a family
/// photo with who it is, where/when it was taken, a short story, and
/// optionally a favorite song to play alongside it. This is a validation/
/// engagement feature, not a cognitive test — `viewCount` and
/// `recognizedCount`/`presentedCount` are soft engagement signals for the
/// caregiver dashboard only, never fed into the adaptive difficulty engine
/// the three cognitive games use (see adaptive_difficulty_service.dart).
class MemoryLaneItem {
  final String id;
  final String patientId;
  final MemoryLaneType type;
  final String title; // the person's name, e.g. "Your daughter Priya"
  final String? description; // the short memory/story
  final String? place;
  final String? memoryDate; // ISO date the memory happened, distinct from createdAt
  final String? localPath;
  final String? remoteUrl;
  final String? songLocalPath;
  final String? songRemoteUrl;
  final int viewCount;
  final int presentedCount; // times shown in the optional "Who is this?" prompt
  final int recognizedCount; // times correctly identified in that prompt
  final String createdAt;
  final String updatedAt;
  final bool isSynced;

  MemoryLaneItem({
    required this.id,
    required this.patientId,
    required this.type,
    required this.title,
    this.description,
    this.place,
    this.memoryDate,
    this.localPath,
    this.remoteUrl,
    this.songLocalPath,
    this.songRemoteUrl,
    this.viewCount = 0,
    this.presentedCount = 0,
    this.recognizedCount = 0,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
  });

  MemoryLaneItem copyWith({
    int? viewCount,
    int? presentedCount,
    int? recognizedCount,
    String? updatedAt,
    bool? isSynced,
    String? localPath,
    String? songLocalPath,
  }) {
    return MemoryLaneItem(
      id: id,
      patientId: patientId,
      type: type,
      title: title,
      description: description,
      place: place,
      memoryDate: memoryDate,
      localPath: localPath ?? this.localPath,
      remoteUrl: remoteUrl,
      songLocalPath: songLocalPath ?? this.songLocalPath,
      songRemoteUrl: songRemoteUrl,
      viewCount: viewCount ?? this.viewCount,
      presentedCount: presentedCount ?? this.presentedCount,
      recognizedCount: recognizedCount ?? this.recognizedCount,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'type': type.key,
      'title': title,
      'description': description,
      'place': place,
      'memoryDate': memoryDate,
      'localPath': localPath,
      'remoteUrl': remoteUrl,
      'songLocalPath': songLocalPath,
      'songRemoteUrl': songRemoteUrl,
      'viewCount': viewCount,
      'presentedCount': presentedCount,
      'recognizedCount': recognizedCount,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory MemoryLaneItem.fromMap(Map<String, dynamic> map) {
    return MemoryLaneItem(
      id: map['id'] as String,
      patientId: map['patientId'] as String,
      type: MemoryLaneTypeX.fromKey(map['type'] as String),
      title: map['title'] as String,
      description: map['description'] as String?,
      place: map['place'] as String?,
      memoryDate: map['memoryDate'] as String?,
      localPath: map['localPath'] as String?,
      remoteUrl: map['remoteUrl'] as String?,
      songLocalPath: map['songLocalPath'] as String?,
      songRemoteUrl: map['songRemoteUrl'] as String?,
      viewCount: (map['viewCount'] as int?) ?? 0,
      presentedCount: (map['presentedCount'] as int?) ?? 0,
      recognizedCount: (map['recognizedCount'] as int?) ?? 0,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
      isSynced: (map['isSynced'] as int) == 1,
    );
  }
}
