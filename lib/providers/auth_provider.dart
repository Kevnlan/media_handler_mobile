import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import '../data/services/auth_service.dart';
import '../data/models/auth_models.dart';
import '../data/models/user_model.dart';

/// AuthProvider manages authentication state for the entire application.
///
/// This class handles:
/// - User login and registration
/// - JWT token management and refresh
/// - Authentication state persistence
/// - User profile management
/// - Automatic token validation on app start
///
/// Uses Provider pattern for state management across the app.
class AuthProvider extends ChangeNotifier {
  /// Service for handling authentication API calls
  AuthService? _authService;

  /// Current authentication state
  bool _isAuthenticated = false;

  /// Loading state for async operations
  bool _isLoading = false;

  /// Initial loading state when app starts
  bool _isInitializing = true;

  /// Error message from the last failed operation
  String? _errorMessage;

  /// Currently authenticated user data
  User? _currentUser;

  /// Returns true if user is authenticated
  bool get isAuthenticated => _isAuthenticated;

  /// Returns true if an async operation is in progress
  bool get isLoading => _isLoading;

  /// Returns true if app is still initializing authentication state
  bool get isInitializing => _isInitializing;

  /// Returns the last error message, null if no error
  String? get errorMessage => _errorMessage;

  /// Returns current user data, null if not authenticated
  User? get currentUser => _currentUser;

  /// Constructor initializes the AuthService and checks authentication state
  AuthProvider() {
    // Initialize immediately to avoid the circular progress indicator getting stuck
    _initializeAuthService();
  }

  /// Initializes the AuthService with required dependencies and checks initial auth state
  Future<void> _initializeAuthService() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dio = Dio();
      _authService = AuthService(dio, prefs);
      await _checkInitialAuthState();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing auth service: $e');
      }
      // Even if there's an error, we need to set isInitializing to false
      _isAuthenticated = false;
      _currentUser = null;
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Checks initial authentication state when app starts
  ///
  /// Validates stored tokens and fetches fresh user profile if authenticated.
  /// Falls back to cached user data if API call fails.
  Future<void> _checkInitialAuthState() async {
    try {
      if (_authService == null) {
        // If authService is not initialized, we can't check auth state
        _isAuthenticated = false;
        _currentUser = null;
        return;
      }

      final isLoggedIn = await _authService!.isLoggedIn();
      if (isLoggedIn) {
        // Always fetch fresh user profile from API on app start
        try {
          _currentUser = await _authService!.fetchUserProfile();
        } catch (e) {
          if (kDebugMode) {
            print('Failed to fetch user profile from API: $e');
          }
          // If API fails, try to get cached user
          _currentUser = await _authService!.getCurrentUser();
        }
        _isAuthenticated = _currentUser != null;
      } else {
        _isAuthenticated = false;
        _currentUser = null;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking initial auth state: $e');
      }
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      // This is the critical part - ALWAYS set isInitializing to false
      _isInitializing = false;
      notifyListeners();
    }
  }

  /// Authenticates user with email and password
  ///
  /// Calls the login API endpoint and stores JWT tokens securely.
  /// Updates authentication state and user data on success.
  ///
  /// Parameters:
  /// - [email]: User's email address
  /// - [password]: User's password
  ///
  /// Throws: Updates [errorMessage] with error details on failure
  Future<void> login(String email, String password) async {
    if (_authService == null) {
      _errorMessage = 'Authentication service not initialized';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loginRequest = LoginRequest(email: email, password: password);
      final authResponse = await _authService!.login(loginRequest);

      _isAuthenticated = true;
      _currentUser = authResponse.user;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _isAuthenticated = false;
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Registers a new user account
  ///
  /// Creates new user account with provided information.
  /// Does NOT automatically log in - user should navigate to login page.
  ///
  /// Parameters:
  /// - [firstName]: User's first name (required)
  /// - [lastName]: User's last name (required)
  /// - [email]: User's email address (required)
  /// - [password]: User's password (required)
  /// - [username]: Optional username
  /// - [phoneNumber]: Optional phone number
  ///
  /// Returns: True if registration was successful
  /// Throws: Updates [errorMessage] with error details on failure
  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    String? username,
    String? phoneNumber,
  }) async {
    if (_authService == null) {
      _errorMessage = 'Authentication service not initialized';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final registerRequest = RegisterRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
        username: username,
        phoneNumber: phoneNumber,
      );

      await _authService!.register(registerRequest);

      // Clear error and return success, but don't log in automatically
      _errorMessage = null;
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logs out the current user
  ///
  /// Calls the logout API to invalidate tokens on server and clears
  /// local authentication state. Performs local logout even if server call fails.
  Future<void> logout() async {
    if (_authService == null) {
      // If authService is not initialized, just clear local state
      _isAuthenticated = false;
      _currentUser = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await _authService!.logout();
    } catch (e) {
      _errorMessage = 'Logout failed: ${e.toString()}';
    } finally {
      // Always clear local state regardless of API call result
      _isAuthenticated = false;
      _currentUser = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes current user profile from the API
  ///
  /// Fetches latest user data from the server and updates local state.
  /// Only works if user is currently authenticated.
  Future<void> refreshUserProfile() async {
    if (!_isAuthenticated || _authService == null) return;

    try {
      _currentUser = await _authService!.fetchUserProfile();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to refresh profile: ${e.toString()}';
      notifyListeners();
    }
  }

  /// Clears the current error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Manually reinitialize the auth service (useful for retry scenarios)
  Future<void> retryInitialization() async {
    _isInitializing = true;
    _errorMessage = null;
    notifyListeners();
    await _initializeAuthService();
  }
}
