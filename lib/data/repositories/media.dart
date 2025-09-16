import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/network/dio_factory.dart';

/// MediaRepository handles media upload operations with authentication
///
/// Uses DioFactory to create authenticated HTTP client for secure uploads
class MediaRepository {
  late final Dio _dio;

  /// Constructor initializes authenticated Dio instance
  MediaRepository() {
    _initializeDio();
  }

  /// Initializes authenticated Dio instance using DioFactory
  Future<void> _initializeDio() async {
    _dio = await DioFactory.createAuthenticatedDio();
  }

  /// Uploads media file to the server
  ///
  /// [filePath] - Path to the file to upload
  /// [type] - Type of media (image, video, etc.)
  Future<void> uploadMedia(String filePath, String type) async {
    final fileName = filePath.split('/').last;

    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath, filename: fileName),
      "type": type,
    });

    await _dio.post(ApiConstants.mediaUrl, data: formData);
  }
}
