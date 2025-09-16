/// API endpoint constants for the Django backend.
///
/// Contains all authentication-related endpoints and utility methods
/// for constructing complete URLs.
///
/// **IMPORTANT**: Update [baseUrl] with your actual Django backend URL
/// before running the application.
class ApiConstants {
  // TODO: Replace with your actual Django backend URL
  // Example: 'https://your-django-backend.com' or 'http://localhost:8000' for development
  static const String baseUrl = 'YOUR_DJANGO_API_BASE_URL';

  // Authentication endpoint paths
  static const String loginEndpoint = '/api/auth/login/';
  static const String logoutEndpoint = '/api/auth/logout/';
  static const String registerEndpoint = '/api/auth/register/';
  static const String refreshEndpoint = '/api/auth/refresh/';
  static const String tokenRefreshEndpoint = '/api/auth/token/refresh/';
  static const String profileEndpoint = '/api/auth/profile/';

  // Media endpoint paths
  static const String mediaEndpoint = '/api/media/';
  static const String collectionsEndpoint = '/api/media/collection/';

  // Complete URL getters - combine base URL with endpoint paths
  // Authentication URLs
  /// Complete URL for user login API
  static String get loginUrl => '$baseUrl$loginEndpoint';

  /// Complete URL for user logout API
  static String get logoutUrl => '$baseUrl$logoutEndpoint';

  /// Complete URL for user registration API
  static String get registerUrl => '$baseUrl$registerEndpoint';

  /// Complete URL for token refresh API
  static String get refreshUrl => '$baseUrl$refreshEndpoint';

  /// Complete URL for alternative token refresh API
  static String get tokenRefreshUrl => '$baseUrl$tokenRefreshEndpoint';

  /// Complete URL for user profile API
  static String get profileUrl => '$baseUrl$profileEndpoint';

  // Media URLs
  /// Complete URL for media API
  static String get mediaUrl => '$baseUrl$mediaEndpoint';

  /// Complete URL for collections API
  static String get collectionsUrl => '$baseUrl$collectionsEndpoint';

  /// Get URL for specific media item
  static String mediaByIdUrl(String id) => '$baseUrl$mediaEndpoint$id/';

  /// Get URL for specific collection
  static String collectionByIdUrl(String id) =>
      '$baseUrl$collectionsEndpoint$id/';

  /// Get URL for adding media to collection
  static String addToCollectionUrl(String mediaId) =>
      '$baseUrl$mediaEndpoint$mediaId/add-to-collection/';

  /// Get URL for removing media from collection
  static String removeFromCollectionUrl(String mediaId) =>
      '$baseUrl$mediaEndpoint$mediaId/remove-from-collection/';
}
