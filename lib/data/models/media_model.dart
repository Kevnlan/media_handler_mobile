class MediaFile {
  final String id;
  final String path;   // Local file path
  final String type;   // image, video, audio
  final bool uploaded;

  MediaFile({
    required this.id,
    required this.path,
    required this.type,
    this.uploaded = false,
  });
}
