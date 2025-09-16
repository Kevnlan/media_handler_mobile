class ApiConstants {
  // TODO: Replace with your actual Django backend URL
  // Example: 'https://your-django-backend.com' or 'http://localhost:8000' for development
  static const String baseUrl = 'YOUR_DJANGO_API_BASE_URL';

  // Authentication endpoints
  static const String loginEndpoint = '/api/auth/login/';
  static const String logoutEndpoint = '/api/auth/logout/';
  static const String registerEndpoint = '/api/auth/register/';
  static const String refreshEndpoint = '/api/auth/refresh/';
  static const String tokenRefreshEndpoint = '/api/auth/token/refresh/';
  static const String profileEndpoint = '/api/auth/profile/';

  // Complete URLs
  static String get loginUrl => '$baseUrl$loginEndpoint';
  static String get logoutUrl => '$baseUrl$logoutEndpoint';
  static String get registerUrl => '$baseUrl$registerEndpoint';
  static String get refreshUrl => '$baseUrl$refreshEndpoint';
  static String get tokenRefreshUrl => '$baseUrl$tokenRefreshEndpoint';
  static String get profileUrl => '$baseUrl$profileEndpoint';
}
