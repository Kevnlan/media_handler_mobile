import 'package:dio/dio.dart';

class MediaRepository {
  final Dio _dio = Dio(BaseOptions(baseUrl: "https://your-server.com/api"));

  Future<void> uploadMedia(String filePath, String type) async {
    final fileName = filePath.split('/').last;

    final formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(filePath, filename: fileName),
      "type": type,
    });

    await _dio.post("/upload", data: formData);
  }
}
