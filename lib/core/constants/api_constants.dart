/// API endpoint constants for the Django backend.
///
/// Contains all authentication-related endpoints and utility methods
/// for constructing complete URLs.
///
/// **IMPORTANT**: Update [baseUrl] with your actual Django backend URL
/// before running the application.
class ApiConstants {
  // Example: 'https://your-django-backend.com' or 'http://localhost:8000' for development
  static const String baseUrl = 'http://192.168.100.9:3000';

  // Authentication endpoint paths
  static const String loginEndpoint = '/api/auth/login/';
  static const String logoutEndpoint = '/api/auth/logout/';
  static const String registerEndpoint = '/api/auth/register/';
  static const String refreshEndpoint = '/api/auth/refresh/';
  static const String tokenRefreshEndpoint = '/api/auth/token/refresh/';
  static const String profileEndpoint = '/api/auth/profile/';

  // Media endpoint paths
  static const String mediaEndpoint = '/api/media';
  static const String collectionsEndpoint = '/api/media/collection';

  // Complete URL getters - combine base URL with endpoint paths
  // Authentication URLs
  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get logoutUrl => '$baseUrl$logoutEndpoint';
  static String get registerUrl => '$baseUrl$registerEndpoint';
  static String get refreshUrl => '$baseUrl$refreshEndpoint';
  static String get tokenRefreshUrl => '$baseUrl$tokenRefreshEndpoint';
  static String get profileUrl => '$baseUrl$profileEndpoint';

  // Media URLs
  static String get mediaUrl => '$baseUrl$mediaEndpoint'; // List/create, no trailing slash
  static String get collectionsUrl => '$baseUrl$collectionsEndpoint'; // List/create, no trailing slash

  /// Get URL for a specific media item by ID (needs trailing slash)
  static String mediaByIdUrl(String id) => '$baseUrl$mediaEndpoint/$id';

  /// Get URL for a specific collection by ID (needs trailing slash)
  static String collectionByIdUrl(String id) => '$baseUrl$collectionsEndpoint/$id';

  /// Add media to a collection by media ID (needs trailing slash)
  static String addToCollectionUrl(String mediaId) =>
      '$baseUrl$mediaEndpoint/$mediaId/add-to-collection';

  /// Remove media from a collection by media ID (needs trailing slash)
  static String removeFromCollectionUrl(String mediaId) =>
      '$baseUrl$mediaEndpoint/$mediaId/remove-from-collection';
}

