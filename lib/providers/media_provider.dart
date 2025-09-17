import 'package:flutter/material.dart';
import '../data/models/media_model.dart';
import '../data/models/collection_model.dart';
import '../data/models/pagination_model.dart';
import '../data/services/media_service.dart';
import '../core/network/dio_factory.dart';

class MediaProvider extends ChangeNotifier {
  late final MediaService _mediaService;

  // Media state
  final Map<MediaType, List<Media>> _mediaByType = {};
  final Map<MediaType, bool> _isLoadingByType = {};
  final Map<MediaType, bool> _hasMoreByType = {};
  final Map<MediaType, int> _currentPageByType = {};

  // Collections state
  List<Collection> _collections = [];
  bool _isLoadingCollections = false;

  // Upload state
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  String? _currentUploadFile;
  
  // General state
  String? _errorMessage;
  Media? _selectedMedia;

  // Prevent recursive API calls
  bool _isHomePageInitialized = false;
  bool _isInitializing = false;

  // Getters
  List<Media> getMediaByType(MediaType type) => _mediaByType[type] ?? [];
  bool isLoadingByType(MediaType type) => _isLoadingByType[type] ?? false;
  bool hasMoreByType(MediaType type) => _hasMoreByType[type] ?? true;
  List<Collection> get collections => _collections;
  bool get isLoadingCollections => _isLoadingCollections;
  bool get isUploading => _isUploading;
  double get uploadProgress => _uploadProgress;
  String? get currentUploadFile => _currentUploadFile;
  String? get errorMessage => _errorMessage;
  Media? get selectedMedia => _selectedMedia;
  bool get isHomePageInitialized => _isHomePageInitialized;
  bool get isInitializing => _isInitializing;

  MediaProvider() {
    _initializeMediaService();
  }

  Future<void> _initializeMediaService() async {
    final dio = await DioFactory.createAuthenticatedDio();
    _mediaService = MediaService(dio);

    // Initialize loading states
    for (final type in MediaType.values) {
      _mediaByType[type] = [];
      _isLoadingByType[type] = false;
      _hasMoreByType[type] = true;
      _currentPageByType[type] = 1;
    }
  }

  // Load media for homepage (first 5 items of each type)
  Future<void> loadHomePageMedia() async {
    // Prevent duplicate calls
    if (_isHomePageInitialized || _isInitializing) {
      return;
    }

    _isInitializing = true;
    _errorMessage = null;
    notifyListeners();

    try {
      for (final type in MediaType.values) {
        _isLoadingByType[type] = true;
        notifyListeners();

        final response = await _mediaService.getMedia(
          page: 1,
          pageSize: 5,
          filters: MediaFilters(type: type, isDeleted: false),
        );

        _mediaByType[type] = response.results;
        _hasMoreByType[type] = response.hasNext;
        _currentPageByType[type] = 1;
        _isLoadingByType[type] = false;
      }

      _isHomePageInitialized = true;
    } catch (e) {
      _errorMessage = e.toString();
      for (final type in MediaType.values) {
        _isLoadingByType[type] = false;
      }
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  // Load media with pagination for specific type
  Future<void> loadMediaByType(
    MediaType type, {
    bool refresh = false,
    MediaFilters? filters,
  }) async {
    if (refresh) {
      _currentPageByType[type] = 1;
      _hasMoreByType[type] = true;
      _mediaByType[type] = [];
    }

    if (_isLoadingByType[type] == true || !_hasMoreByType[type]!) return;

    _isLoadingByType[type] = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final currentFilters =
          filters ?? MediaFilters(type: type, isDeleted: false);

      final response = await _mediaService.getMedia(
        page: _currentPageByType[type]!,
        pageSize: 20,
        filters: currentFilters,
      );

      if (refresh) {
        _mediaByType[type] = response.results;
      } else {
        _mediaByType[type]!.addAll(response.results);
      }

      _hasMoreByType[type] = response.hasNext;
      _currentPageByType[type] = _currentPageByType[type]! + 1;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingByType[type] = false;
      notifyListeners();
    }
  }

  // Load single media by ID
  Future<void> loadMediaById(String id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedMedia = await _mediaService.getMediaById(id);
    } catch (e) {
      _errorMessage = e.toString();
      _selectedMedia = null;
    }
    notifyListeners();
  }

  // Upload media with validation and progress tracking
  Future<Media?> uploadMedia({
    required String name,
    required MediaType type,
    required String filePath,
    String? description,
    String? collectionId,
  }) async {
    try {
      // Reset state
      _isUploading = true;
      _uploadProgress = 0.0;
      _currentUploadFile = name;
      _errorMessage = null;
      notifyListeners();

      // Validate file before upload
      await _mediaService.validateFile(filePath, type);

      // Upload with progress tracking
      final media = await _mediaService.createMedia(
        name: name,
        type: type,
        filePath: filePath,
        description: description,
        collectionId: collectionId,
        onSendProgress: (sent, total) {
          _uploadProgress = sent / total;
          notifyListeners();
        },
      );

      // Add to local cache
      _mediaByType[type]?.insert(0, media);

      // Reset upload state
      _isUploading = false;
      _uploadProgress = 0.0;
      _currentUploadFile = null;
      _errorMessage = null;
      notifyListeners();

      return media;
    } on MediaUploadException catch (e) {
      _errorMessage = e.message;
      _isUploading = false;
      _uploadProgress = 0.0;
      _currentUploadFile = null;
      notifyListeners();
      return null;
    } catch (e) {
      _errorMessage = e.toString();
      _isUploading = false;
      _uploadProgress = 0.0;
      _currentUploadFile = null;
      notifyListeners();
      return null;
    }
  }

  // Batch upload multiple files
  Future<UploadBatchResult> uploadBatch(List<FileUploadRequest> files) async {
    int successCount = 0;
    int errorCount = 0;
    List<Media> uploadedMedia = [];
    List<String> errors = [];

    for (int i = 0; i < files.length; i++) {
      final file = files[i];
      
      // Update progress for batch
      _currentUploadFile = '${file.name} (${i + 1}/${files.length})';
      notifyListeners();

      final result = await uploadMedia(
        name: file.name,
        type: file.type,
        filePath: file.filePath,
        description: file.description,
        collectionId: file.collectionId,
      );

      if (result != null) {
        successCount++;
        uploadedMedia.add(result);
      } else {
        errorCount++;
        if (_errorMessage != null) {
          errors.add('${file.name}: $_errorMessage');
        }
      }
    }

    return UploadBatchResult(
      successCount: successCount,
      errorCount: errorCount,
      uploadedMedia: uploadedMedia,
      errors: errors,
    );
  }

  // Update media
  Future<Media?> updateMedia({
    required String id,
    String? name,
    String? description,
    String? collectionId,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (collectionId != null) data['collection_id'] = collectionId;

      final updatedMedia = await _mediaService.updateMedia(id, data);

      // Update in local cache
      _updateMediaInCache(updatedMedia);

      if (_selectedMedia?.id == id) {
        _selectedMedia = updatedMedia;
      }

      return updatedMedia;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      notifyListeners();
    }
  }

  // Delete media
  Future<bool> deleteMedia(String id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _mediaService.deleteMedia(id);

      // Remove from local cache
      _removeMediaFromCache(id);

      if (_selectedMedia?.id == id) {
        _selectedMedia = null;
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Load collections
  Future<void> loadCollections() async {
    _isLoadingCollections = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _mediaService.getCollections();
      _collections = response.results;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingCollections = false;
      notifyListeners();
    }
  }

  // Create collection
  Future<Collection?> createCollection({
    required String name,
    String? description,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final collection = await _mediaService.createCollection(
        name: name,
        description: description,
      );

      _collections.insert(0, collection);
      return collection;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      notifyListeners();
    }
  }

  // Update collection
  Future<Collection?> updateCollection({
    required String id,
    String? name,
    String? description,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;

      final updatedCollection = await _mediaService.updateCollection(id, data);

      final index = _collections.indexWhere((c) => c.id == id);
      if (index != -1) {
        _collections[index] = updatedCollection;
      }

      return updatedCollection;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      notifyListeners();
    }
  }

  // Delete collection
  Future<bool> deleteCollection(String id) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _mediaService.deleteCollection(id);
      _collections.removeWhere((c) => c.id == id);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  // Helper methods
  void _updateMediaInCache(Media media) {
    for (final type in MediaType.values) {
      final list = _mediaByType[type];
      if (list != null) {
        final index = list.indexWhere((m) => m.id == media.id);
        if (index != -1) {
          list[index] = media;
        }
      }
    }
  }

  void _removeMediaFromCache(String id) {
    for (final type in MediaType.values) {
      _mediaByType[type]?.removeWhere((m) => m.id == id);
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSelectedMedia() {
    _selectedMedia = null;
    notifyListeners();
  }

  /// Resets the homepage initialization state to allow fresh loading
  void resetHomePageState() {
    _isHomePageInitialized = false;
    _isInitializing = false;
    // Clear existing data
    for (final type in MediaType.values) {
      _mediaByType[type] = [];
      _isLoadingByType[type] = false;
      _hasMoreByType[type] = true;
      _currentPageByType[type] = 1;
    }
    notifyListeners();
  }

  /// Checks if any media type has data
  bool get hasAnyMedia {
    return MediaType.values.any(
      (type) => (_mediaByType[type]?.isNotEmpty ?? false),
    );
  }

  /// Gets total media count across all types
  int get totalMediaCount {
    return MediaType.values.fold(
      0,
      (sum, type) => sum + (_mediaByType[type]?.length ?? 0),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

/// Request model for file upload
class FileUploadRequest {
  final String name;
  final MediaType type;
  final String filePath;
  final String? description;
  final String? collectionId;

  FileUploadRequest({
    required this.name,
    required this.type,
    required this.filePath,
    this.description,
    this.collectionId,
  });
}

/// Result model for batch uploads
class UploadBatchResult {
  final int successCount;
  final int errorCount;
  final List<Media> uploadedMedia;
  final List<String> errors;

  UploadBatchResult({
    required this.successCount,
    required this.errorCount,
    required this.uploadedMedia,
    required this.errors,
  });

  bool get hasErrors => errorCount > 0;
  bool get isSuccess => errorCount == 0;
  String get summary => '$successCount succeeded, $errorCount failed';
}
