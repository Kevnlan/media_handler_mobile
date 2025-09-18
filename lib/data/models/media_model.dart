class Media {
  final String id;
  final int user;
  final String name;
  final MediaType type;
  final int? size;
  final String? fileUrl;
  final String? storagePath;
  final String? description;
  final bool isDeleted;
  final String? collectionId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Media({
    required this.id,
    required this.user,
    required this.name,
    required this.type,
    this.size,
    this.fileUrl,
    this.storagePath,
    this.description,
    this.isDeleted = false,
    this.collectionId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Media.fromJson(Map<String, dynamic> json) {
    return Media(
      id: json['id'] ?? '',
      user: json['user'] ?? 0,
      name: json['name'] ?? '',
      type: MediaType.fromString(json['type'] ?? 'image'),
      size: json['size'],
      fileUrl: json['file'],
      storagePath: json['storage_path'],
      description: json['description'],
      isDeleted: json['is_deleted'] ?? false,
      collectionId: json['collection'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user,
      'name': name,
      'type': type.value,
      'size': size,
      'file': fileUrl,
      'storage_path': storagePath,
      'description': description,
      'is_deleted': isDeleted,
      'collection': collectionId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Media copyWith({
    String? id,
    int? user,
    String? name,
    MediaType? type,
    int? size,
    String? fileUrl,
    String? storagePath,
    String? description,
    bool? isDeleted,
    String? collectionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Media(
      id: id ?? this.id,
      user: user ?? this.user,
      name: name ?? this.name,
      type: type ?? this.type,
      size: size ?? this.size,
      fileUrl: fileUrl ?? this.fileUrl,
      storagePath: storagePath ?? this.storagePath,
      description: description ?? this.description,
      isDeleted: isDeleted ?? this.isDeleted,
      collectionId: collectionId ?? this.collectionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Helper methods
  String get formattedSize {
    if (size == null) return 'Unknown';
    if (size! < 1024) return '$size B';
    if (size! < 1024 * 1024) return '${(size! / 1024).toStringAsFixed(1)} KB';
    if (size! < 1024 * 1024 * 1024) {
      return '${(size! / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(size! / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

enum MediaType {
  image('image'),
  video('video'),
  audio('audio');

  const MediaType(this.value);
  final String value;

  static MediaType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'image':
        return MediaType.image;
      case 'video':
        return MediaType.video;
      case 'audio':
        return MediaType.audio;
      default:
        return MediaType.image;
    }
  }

  String get displayName {
    switch (this) {
      case MediaType.image:
        return 'Images';
      case MediaType.video:
        return 'Videos';
      case MediaType.audio:
        return 'Audio';
    }
  }
}
