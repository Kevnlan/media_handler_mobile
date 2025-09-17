import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decode/jwt_decode.dart';
import '../models/auth_models.dart';
import '../models/user_model.dart';
import '../../core/constants/api_constants.dart';

/// AuthService handles all authentication-related API calls and token management.
///
/// Features:
/// - JWT token storage and management
/// - Automatic token refresh on 401 errors
/// - User profile fetching
/// - Login/logout/register API calls
/// - Token validation and expiry checking
///
/// Uses Dio for HTTP requests with automatic Bearer token injection.
class AuthService {
  /// SharedPreferences key for storing access token
  static const String _accessTokenKey = 'access_token';

  /// SharedPreferences key for storing refresh token
  static const String _refreshTokenKey = 'refresh_token';

  /// SharedPreferences key for storing user data
  static const String _userKey = 'user_data';

  /// Dio HTTP client for making API requests
  final Dio _dio;

  /// SharedPreferences instance for local storage
  final SharedPreferences _prefs;

  /// Constructor initializes the service with dependencies and sets up interceptors
  AuthService(this._dio, this._prefs) {
    _setupInterceptors();
  }

  /// Sets up Dio interceptors for automatic token management
  ///
  /// - Automatically adds Bearer token to all requests
  /// - Handles 401 errors by attempting token refresh
  /// - Retries original request with new token if refresh succeeds
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
        ApiConstants.loginUrl,
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
  print(" check url ${ApiConstants.registerUrl}");
    try {
      final response = await _dio.post(
        ApiConstants.registerUrl,
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);
      await _saveAuthData(authResponse);
      return authResponse;
    } on DioException catch (e) {
        print("Status code: ${e.response?.statusCode}");
    print("Response data: ${e.response?.data}");
      throw _handleDioException(e);
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiConstants.refreshUrl,
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
        // Try to parse stored user data
        final Map<String, dynamic> userMap = {};
        final jsonString = userJson.substring(
          1,
          userJson.length - 1,
        ); // Remove { }
        final pairs = jsonString.split(',');
        for (final pair in pairs) {
          final parts = pair.split(':');
          if (parts.length == 2) {
            final key = parts[0].replaceAll('"', '').trim();
            final value = parts[1].replaceAll('"', '').trim();
            userMap[key] = value;
          }
        }
        return User.fromJson(userMap);
      } catch (e) {
        // If parsing fails, fetch from API
        try {
          return await fetchUserProfile();
        } catch (e) {
          return null;
        }
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

  Future<User> fetchUserProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profileUrl);
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> logout() async {
    try {
      // Call logout API to invalidate token on server
      await _dio.post(ApiConstants.logoutUrl);
    } catch (e) {
      // Even if API call fails, we should clear local tokens
    } finally {
      // Clear local storage
      await _prefs.remove(_accessTokenKey);
      await _prefs.remove(_refreshTokenKey);
      await _prefs.remove(_userKey);
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
