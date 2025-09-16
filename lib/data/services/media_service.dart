import 'package:dio/dio.dart';
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
  /// Dio HTTP client for making API requests
  final Dio _dio;

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

  Future<Media> createMedia({
    required String name,
    required MediaType type,
    required String filePath,
    String? description,
    String? collectionId,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'type': type.value,
        'description': description,
        'collection': collectionId,
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(ApiConstants.mediaUrl, data: formData);

      return Media.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
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
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Server response timeout. Please try again.';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final message =
            e.response?.data['message'] ??
            e.response?.data['error'] ??
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
