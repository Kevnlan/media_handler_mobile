import 'package:flutter/material.dart';

import '../data/repositories/media.dart' show MediaRepository;

class MediaViewModel extends ChangeNotifier {
  final MediaRepository _repo = MediaRepository();
  bool _isUploading = false;

  bool get isUploading => _isUploading;

  Future<void> upload(String filePath, String type) async {
    _isUploading = true;
    notifyListeners();

    try {
      await _repo.uploadMedia(filePath, type);
    } catch (e) {
      debugPrint("Upload failed: $e");
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }
}
