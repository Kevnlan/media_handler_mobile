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

  /// Flag to prevent infinite refresh loops
  bool _isRefreshing = false;

  /// Constructor initializes the service with dependencies and sets up interceptors
  AuthService(this._dio, this._prefs) {
    _setupInterceptors();
  }

  /// Sets up Dio interceptors for automatic token management
  ///
  /// - Automatically adds Bearer token to all requests
  /// - Handles 401 errors by attempting token refresh (only once)
  /// - Retries original request with new token if refresh succeeds
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Don't add token to refresh endpoint to avoid issues
          if (!options.path.contains('/refresh')) {
            final token = await getAccessToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          // Only attempt refresh for non-refresh endpoints and when not already refreshing
          if (error.response?.statusCode == 401 && 
              !error.requestOptions.path.contains('/refresh') &&
              !error.requestOptions.path.contains('/login') &&
              !error.requestOptions.path.contains('/register') &&
              !_isRefreshing) {
            
            print('Token expired, attempting refresh...');
            _isRefreshing = true;
            
            try {
              final refreshed = await _refreshToken();
              
              if (refreshed) {
                // Retry the original request with new token
                final token = await getAccessToken();
                error.requestOptions.headers['Authorization'] = 'Bearer $token';
                
                try {
                  final response = await _dio.fetch(error.requestOptions);
                  handler.resolve(response);
                  return;
                } catch (retryError) {
                  // If retry also fails, clear auth and pass error
                  await _clearAuthData();
                  handler.next(error);
                  return;
                }
              } else {
                // Refresh failed, clear auth data
                print('Token refresh failed, clearing auth data...');
                await _clearAuthData();
              }
            } catch (e) {
              print('Error during token refresh: $e');
              await _clearAuthData();
            } finally {
              _isRefreshing = false;
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
    print("check url ${ApiConstants.registerUrl}");
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
      if (refreshToken == null) {
        print('No refresh token available');
        return false;
      }

      // Create a new Dio instance without interceptors to avoid loops
      final dio = Dio(_dio.options);
      dio.options.sendTimeout = const Duration(seconds: 5);
      dio.options.receiveTimeout = const Duration(seconds: 5);
      
      try {
        final response = await dio.post(
          ApiConstants.refreshUrl,
          data: {'refresh': refreshToken},
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            // Must throw an exception, not return a value
            throw TimeoutException('Refresh token timeout');
          },
        );

        if (response.statusCode == 200 && response.data['access'] != null) {
          final newAccessToken = response.data['access'];
          await _prefs.setString(_accessTokenKey, newAccessToken);
          
          // Update refresh token if provided
          if (response.data['refresh'] != null) {
            await _prefs.setString(_refreshTokenKey, response.data['refresh']);
          }
          
          print('Token refreshed successfully');
          return true;
        }
      } catch (e) {
        print('Refresh request failed: $e');
        return false;
      }
      
      return false;
    } catch (e) {
      print('Refresh token error: $e');
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

  Future<void> _clearAuthData() async {
    await _prefs.remove(_accessTokenKey);
    await _prefs.remove(_refreshTokenKey);
    await _prefs.remove(_userKey);
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
        print('Error parsing cached user data: $e');
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
      print('Error validating token: $e');
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        print('No access token found');
        return false;
      }

      final isValid = await isTokenValid();
      if (!isValid) {
        print('Token is invalid/expired, attempting refresh...');
        
        // Attempt refresh with proper error handling
        try {
          final refreshed = await _refreshToken().timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              print('Refresh timeout during isLoggedIn check');
              // Must throw an exception for timeout
              throw TimeoutException('Refresh timeout');
            },
          );
          
          if (!refreshed) {
            // If refresh fails, clear auth data
            await _clearAuthData();
            return false;
          }
          
          return refreshed;
        } catch (e) {
          print('Refresh failed during isLoggedIn: $e');
          await _clearAuthData();
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Error checking login status: $e');
      // On any error, clear auth and return false
      await _clearAuthData();
      return false;
    }
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
      // Don't use timeout here to avoid compilation issues
      await _dio.post(ApiConstants.logoutUrl);
    } catch (e) {
      print('Logout API error: $e');
      // Even if API call fails, we should clear local tokens
    } finally {
      // Clear local storage
      await _clearAuthData();
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

// Custom exception class for timeout
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => message;
}
