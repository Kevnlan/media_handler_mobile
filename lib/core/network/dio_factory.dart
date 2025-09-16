import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

/// Factory for creating configured Dio instances with authentication support.
///
/// Creates Dio instances with:
/// - Automatic Bearer token injection
/// - Token refresh on 401 errors
/// - Request/response logging (in debug mode)
/// - Proper error handling
class DioFactory {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// Creates a Dio instance configured with authentication interceptors
  ///
  /// This should be used for all API services that require authentication.
  /// The instance will automatically handle token management.
  static Future<Dio> createAuthenticatedDio() async {
    final dio = Dio();
    final prefs = await SharedPreferences.getInstance();

    // Add authentication interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = prefs.getString(_accessTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired, try to refresh
            final refreshed = await _refreshToken(dio, prefs);
            if (refreshed) {
              // Retry the original request with new token
              final token = prefs.getString(_accessTokenKey);
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              final response = await dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            }
          }
          handler.next(error);
        },
      ),
    );

    // Add logging interceptor for debug mode
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) {
          // Only log in debug mode
          assert(() {
            print(obj);
            return true;
          }());
        },
      ),
    );

    return dio;
  }

  /// Refreshes the access token using the stored refresh token
  static Future<bool> _refreshToken(Dio dio, SharedPreferences prefs) async {
    try {
      final refreshToken = prefs.getString(_refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await dio.post(
        ApiConstants.refreshUrl,
        data: {'refresh': refreshToken},
      );

      final newAccessToken = response.data['access'];
      await prefs.setString(_accessTokenKey, newAccessToken);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Creates a basic Dio instance without authentication
  ///
  /// Use this for public endpoints that don't require authentication.
  static Dio createPublicDio() {
    final dio = Dio();

    // Add basic logging
    dio.interceptors.add(
      LogInterceptor(
        logPrint: (obj) {
          assert(() {
            print(obj);
            return true;
          }());
        },
      ),
    );

    return dio;
  }
}
