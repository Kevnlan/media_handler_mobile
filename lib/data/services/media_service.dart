import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as path;
import '../models/media_model.dart';
import '../models/collection_model.dart';
import '../models/pagination_model.dart';
import '../../core/constants/api_constants.dart';

/// MediaService handles all media-related API calls.
///
/// Features:
/// - Media CRUD operations (Create, Read, Update, Delete)
/// - Collection management
/// - File upload functionality
/// - Pagination support
/// - Search and filtering
///
/// All requests automatically include authentication tokens via Dio interceptors.
class MediaService {
  final Dio _dio;
  
  // Maximum file size (10MB)
  static const int maxFileSize = 10 * 1024 * 1024;
  
  // Target size for compression (8MB)
  static const int targetFileSize = 8 * 1024 * 1024;

  MediaService(this._dio);

  // Media endpoints
  Future<PaginationResponse<Media>> getMedia({
    int page = 1,
    int pageSize = 20,
    MediaFilters? filters,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (filters != null) {
        queryParams.addAll(filters.toQueryParams());
      }

      final response = await _dio.get(
        ApiConstants.mediaUrl,
        queryParameters: queryParams,
      );

      return PaginationResponse.fromJson(
        response.data,
        (json) => Media.fromJson(json),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Media> getMediaById(String id) async {
    try {
      final response = await _dio.get(ApiConstants.mediaByIdUrl(id));
      return Media.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Create media with file size validation and compression
  Future<Media> createMedia({
    required String name,
    required MediaType type,
    required String filePath,
    String? description,
    String? collectionId,
    Function(int, int)? onSendProgress,
  }) async {
    try {
      File file = File(filePath);
      
      // Step 1: Check if file exists
      if (!await file.exists()) {
        throw MediaUploadException('File not found: $filePath');
      }

      // Step 2: Get and validate file size
      final originalSize = await file.length();

      // Step 3: Compress if it's an image and too large
      if (type == MediaType.image && originalSize > targetFileSize) {
        file = await _compressImage(file);
        await file.length();
      }

      // Step 4: Final size validation
      final finalSize = await file.length();
      if (finalSize > maxFileSize) {
        throw MediaUploadException(
          'File size (${_getFileSizeString(finalSize)}) exceeds maximum allowed size of ${_getFileSizeString(maxFileSize)}'
        );
      }

      // Step 5: Create form data
      final fileName = path.basename(file.path);
      final formData = FormData.fromMap({
        'name': name,
        'type': type.value,
        if (description != null) 'description': description,
        if (collectionId != null) 'collection': collectionId,
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      // Step 6: Upload with progress tracking
      final response = await _dio.post(
        ApiConstants.mediaUrl,
        data: formData,
        onSendProgress: (sent, total) {
          if (onSendProgress != null) {
            onSendProgress(sent, total);
          }
          (sent / total * 100).toStringAsFixed(0);
        },
      );

      // Step 7: Clean up compressed file if created
      if (file.path != filePath && await file.exists()) {
        await file.delete();
      }

      return Media.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      if (e is MediaUploadException) rethrow;
      throw MediaUploadException('Upload failed: $e');
    }
  }

  /// Compress image file
  Future<File> _compressImage(File file) async {
    try {
      final fileSize = await file.length();
      
      // Calculate quality based on target size
      int quality = ((targetFileSize / fileSize) * 100).round();
      quality = quality.clamp(50, 95);
      
      final String targetPath = path.join(
        Directory.systemTemp.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}',
      );

      XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: 1920,
        minHeight: 1080,
      );

      if (result != null) {
        final compressedFile = File(result.path);
        final compressedSize = await compressedFile.length();
        
        // If still too large, compress more aggressively
        if (compressedSize > maxFileSize) {
          return await _compressAggressively(file);
        }
        
        return compressedFile;
      }
      
      return file;
    } catch (e) {
      return file;
    }
  }

  /// More aggressive compression
  Future<File> _compressAggressively(File file) async {
    try {
      final String targetPath = path.join(
        Directory.systemTemp.path,
        'compressed_aggressive_${DateTime.now().millisecondsSinceEpoch}_${path.basename(file.path)}',
      );

      XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: 60,
        minWidth: 1280,
        minHeight: 720,
      );

      return result != null ? File(result.path) : file;
    } catch (e) {
      return file;
    }
  }

  /// Get human-readable file size
  String _getFileSizeString(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  /// Validate file before upload
  Future<void> validateFile(String filePath, MediaType type) async {
    final file = File(filePath);
    
    if (!await file.exists()) {
      throw MediaUploadException('File not found');
    }
    
    final fileSize = await file.length();
    
    // For non-image files, strictly enforce size limit
    if (type != MediaType.image && fileSize > maxFileSize) {
      throw MediaUploadException(
        'File size (${_getFileSizeString(fileSize)}) exceeds maximum allowed size of ${_getFileSizeString(maxFileSize)}'
      );
    }
    
    // For images, we'll compress them if needed during upload
    if (type == MediaType.image && fileSize > maxFileSize * 2) {
      // Reject if image is more than twice the max size (compression won't help much)
      throw MediaUploadException(
        'Image file is too large (${_getFileSizeString(fileSize)}). Please select a smaller image.'
      );
    }
  }

  Future<Media> updateMedia(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        ApiConstants.mediaByIdUrl(id),
        data: data,
      );
      return Media.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Media> patchMedia(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.patch(
        ApiConstants.mediaByIdUrl(id),
        data: data,
      );
      return Media.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> deleteMedia(String id) async {
    try {
      await _dio.delete(ApiConstants.mediaByIdUrl(id));
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> addToCollection(String mediaId, String collectionId) async {
    try {
      await _dio.post(
        ApiConstants.addToCollectionUrl(mediaId),
        data: {'collection_id': collectionId},
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> removeFromCollection(String mediaId) async {
    try {
      await _dio.post(ApiConstants.removeFromCollectionUrl(mediaId));
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  // Collection endpoints
  Future<PaginationResponse<Collection>> getCollections({
    int page = 1,
    int pageSize = 20,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _dio.get(
        ApiConstants.collectionsUrl,
        queryParameters: queryParams,
      );

      return PaginationResponse.fromJson(
        response.data,
        (json) => Collection.fromJson(json),
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Collection> getCollectionById(String id) async {
    try {
      final response = await _dio.get(ApiConstants.collectionByIdUrl(id));
      return Collection.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Collection> createCollection({
    required String name,
    String? description,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.collectionsUrl,
        data: {'name': name, 'description': description},
      );
      return Collection.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Collection> updateCollection(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.put(
        ApiConstants.collectionByIdUrl(id),
        data: data,
      );
      return Collection.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Collection> patchCollection(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.patch(
        ApiConstants.collectionByIdUrl(id),
        data: data,
      );
      return Collection.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> deleteCollection(String id) async {
    try {
      await _dio.delete(ApiConstants.collectionByIdUrl(id));
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  String _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timeout. Please check your internet connection.';
      case DioExceptionType.sendTimeout:
        return 'Upload timeout. The file might be too large or your connection is slow.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 413) {
          return 'File too large. Maximum size is ${_getFileSizeString(maxFileSize)}';
        }
        final message =
            e.response?.data['message'] ??
            e.response?.data['error'] ??
            e.response?.data['detail'] ??
            'Server error occurred.';
        return '$message (Error $statusCode)';
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return 'No internet connection. Please check your connection.';
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }
}

/// Custom exception for media upload errors
class MediaUploadException implements Exception {
  final String message;
  MediaUploadException(this.message);
  
  @override
  String toString() => message;
}
