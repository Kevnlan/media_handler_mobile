import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';

class AuthService {
  static const String baseUrl =
      'YOUR_DJANGO_API_BASE_URL'; // Replace with your actual API URL
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'user_data';

  final Dio _dio;
  final SharedPreferences _prefs;

  AuthService(this._dio, this._prefs) {
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired, try to refresh
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry the original request
              final token = await getAccessToken();
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              final response = await _dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } else {
              // Refresh failed, logout user
              await logout();
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/auth/login/', // Adjust endpoint as needed
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await _saveAuthData(authResponse);
      return authResponse;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/auth/register/', // Adjust endpoint as needed
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await _saveAuthData(authResponse);
      return authResponse;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        '$baseUrl/api/auth/token/refresh/', // Adjust endpoint as needed
        data: {'refresh': refreshToken},
      );

      final newAccessToken = response.data['access'];
      await _prefs.setString(_accessTokenKey, newAccessToken);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> _saveAuthData(AuthResponse authResponse) async {
    await _prefs.setString(_accessTokenKey, authResponse.accessToken);
    await _prefs.setString(_refreshTokenKey, authResponse.refreshToken);
    // Store user data as JSON string for easier parsing
    final userJsonString = authResponse.user
        .toJson()
        .entries
        .map((e) => '"${e.key}":"${e.value}"')
        .join(',');
    await _prefs.setString(_userKey, '{$userJsonString}');
  }

  Future<String?> getAccessToken() async {
    return _prefs.getString(_accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return _prefs.getString(_refreshTokenKey);
  }

  Future<User?> getCurrentUser() async {
    final userJson = _prefs.getString(_userKey);
    if (userJson != null) {
      try {
        // For now, return null and get user data from API calls
        // In a real implementation, you'd parse the stored JSON
        return null;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<bool> isTokenValid() async {
    final token = await getAccessToken();
    if (token == null) return false;

    try {
      final payload = Jwt.parseJwt(token);
      final exp = payload['exp'] as int;
      final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return currentTime < exp;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    if (token == null) return false;

    final isValid = await isTokenValid();
    if (!isValid) {
      // Try to refresh the token
      final refreshed = await _refreshToken();
      return refreshed;
    }

    return true;
  }

  Future<void> logout() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_userKey);
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
