import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../data/models/media_model.dart';
import '../data/models/collection_model.dart';
import '../data/models/pagination_model.dart';
import '../data/services/media_service.dart';

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

  // General state
  bool _isUploading = false;
  String? _errorMessage;
  Media? _selectedMedia;

  // Getters
  List<Media> getMediaByType(MediaType type) => _mediaByType[type] ?? [];
  bool isLoadingByType(MediaType type) => _isLoadingByType[type] ?? false;
  bool hasMoreByType(MediaType type) => _hasMoreByType[type] ?? true;
  List<Collection> get collections => _collections;
  bool get isLoadingCollections => _isLoadingCollections;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  Media? get selectedMedia => _selectedMedia;

  MediaProvider() {
    _initializeMediaService();
  }

  Future<void> _initializeMediaService() async {
    final dio = Dio();
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
    } catch (e) {
      _errorMessage = e.toString();
      for (final type in MediaType.values) {
        _isLoadingByType[type] = false;
      }
    }
    notifyListeners();
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

  // Upload media
  Future<Media?> uploadMedia({
    required String name,
    required MediaType type,
    required String filePath,
    String? description,
    String? collectionId,
  }) async {
    _isUploading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final media = await _mediaService.createMedia(
        name: name,
        type: type,
        filePath: filePath,
        description: description,
        collectionId: collectionId,
      );

      // Add to local cache
      _mediaByType[type]?.insert(0, media);

      return media;
    } catch (e) {
      _errorMessage = e.toString();
      return null;
    } finally {
      _isUploading = false;
      notifyListeners();
    }
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

  @override
  void dispose() {
    super.dispose();
  }
}
