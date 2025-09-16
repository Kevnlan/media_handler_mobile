# Media Handler - Code Documentation

## Architecture Overview

The Media Handler app follows a clean architecture pattern with clear separation of concerns:

### 📁 Project Structure

```
lib/
├── core/
│   └── constants/
│       └── api_constants.dart      # API endpoint configurations
├── data/
│   ├── models/
│   │   ├── auth_models.dart        # Authentication request/response models
│   │   ├── user_model.dart         # User data model
│   │   └── media_model.dart        # Media data model
│   └── services/
│       ├── auth_service.dart       # Authentication API service
│       └── media_service.dart      # Media management API service
├── providers/
│   ├── auth_provider.dart          # Authentication state management
│   ├── user_provider.dart          # User data state management
│   └── media_provider.dart         # Media data state management
├── views/
│   └── screens/
│       ├── auth/
│       │   ├── login.dart          # Login screen
│       │   └── register.dart       # Registration screen
│       ├── home/
│       │   ├── main_screen.dart    # Main navigation screen
│       │   ├── home_page.dart      # Home screen
│       │   ├── profile_page.dart   # User profile screen
│       │   └── file_picker_page.dart # File selection screen
│       └── media/
│           ├── media_list_page.dart    # Media listing screen
│           └── media_detail_page.dart  # Media detail screen
└── main.dart                       # App entry point
```

## 🏗️ Architecture Layers

### 1. Presentation Layer (Views)
- **Screens**: UI components built with Flutter widgets
- **State Management**: Provider pattern for reactive UI updates
- **Navigation**: MaterialApp routing between screens

### 2. Business Logic Layer (Providers)
- **AuthProvider**: Manages authentication state and user sessions
- **UserProvider**: Handles user data and profile management
- **MediaProvider**: Manages media files and collections

### 3. Data Layer (Models & Services)
- **Models**: Data classes for API communication and local storage
- **Services**: HTTP client wrappers for API communication
- **Constants**: Configuration and endpoint definitions

## 🔑 Key Components

### Authentication System

#### AuthProvider
```dart
/// Central authentication state manager
/// Features:
/// - JWT token management with auto-refresh
/// - Login/logout/registration flows
/// - Session persistence across app restarts
/// - Automatic token validation on startup
```

#### AuthService
```dart
/// API service for authentication operations
/// Features:
/// - Dio HTTP client with interceptors
/// - Automatic Bearer token injection
/// - 401 error handling with token refresh
/// - Secure token storage using SharedPreferences
```

#### User Model
```dart
/// Data model matching Django CustomUser
/// Fields: id, firstName, lastName, email, username, phoneNumber
/// Methods: JSON serialization, copyWith for immutable updates
```

### State Management Pattern

The app uses the Provider pattern for state management:

```dart
// Provider setup in main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => MediaProvider()),
  ],
  child: MaterialApp(...)
)

// Usage in widgets
Consumer<AuthProvider>(
  builder: (context, authProvider, child) {
    if (authProvider.isAuthenticated) {
      return MainScreen();
    }
    return LoginPage();
  },
)
```

## 🔒 Security Features

### JWT Token Management
- **Automatic Token Refresh**: Handles expired tokens transparently
- **Secure Storage**: Uses SharedPreferences for token persistence
- **Bearer Authentication**: Automatically adds tokens to API requests
- **Token Validation**: Checks token expiry on app startup

### API Security
- **Automatic Logout**: Clears tokens on authentication failures
- **Request Interceptors**: Handles 401 errors gracefully
- **Error Handling**: Provides user-friendly error messages

## 🌐 API Integration

### Endpoint Configuration
```dart
// Update in lib/core/constants/api_constants.dart
static const String baseUrl = 'https://your-backend.com';
```

### Required Backend Endpoints
- `POST /api/auth/login/` - User authentication
- `POST /api/auth/logout/` - Token invalidation  
- `POST /api/auth/register/` - User registration
- `POST /api/auth/refresh/` - Token refresh
- `GET /api/auth/profile/` - User profile data

### Expected API Schemas

#### Authentication Response
```json
{
  "access": "jwt_access_token",
  "refresh": "jwt_refresh_token", 
  "user": {
    "id": 3,
    "first_name": "John",
    "last_name": "Doe",
    "email": "user@example.com",
    "username": "johndoe",
    "phone_number": "0900111222"
  }
}
```

## 📱 UI/UX Features

### Navigation Flow
1. **Splash Screen**: Shows while checking authentication state
2. **Login/Register**: Authentication forms with validation
3. **Main App**: Bottom navigation between Home and Profile
4. **File Management**: Media upload and organization

### Error Handling
- **Network Errors**: User-friendly error messages
- **Validation**: Form field validation with visual feedback  
- **Retry Logic**: Automatic retry on token refresh
- **Graceful Degradation**: Fallback to cached data when API fails

## 🔧 Development Guidelines

### Code Style
- **Documentation**: Comprehensive inline documentation
- **Naming**: Descriptive variable and method names
- **Comments**: Explain complex business logic
- **Error Handling**: Always handle exceptions gracefully

### Testing Strategy
- **Unit Tests**: Provider logic and model serialization
- **Widget Tests**: UI component behavior
- **Integration Tests**: End-to-end authentication flows

### Performance Considerations
- **State Management**: Only rebuild widgets that need updates
- **API Caching**: Cache user data to reduce API calls
- **Token Refresh**: Minimize refresh requests with proper validation
- **Image Loading**: Lazy loading for media thumbnails

## 🚀 Deployment

### Environment Configuration
1. Update `ApiConstants.baseUrl` with production URL
2. Configure build variants for different environments
3. Set up proper error reporting and analytics
4. Test authentication flows thoroughly

### Build Commands
```bash
# Debug build
flutter build apk --debug

# Release build  
flutter build apk --release

# iOS release (macOS only)
flutter build ios --release
```

## 📋 Maintenance

### Regular Tasks
- **Dependency Updates**: Keep packages up to date
- **Security Audits**: Review authentication implementation
- **Performance Monitoring**: Track app performance metrics
- **User Feedback**: Monitor authentication success rates

### Troubleshooting
- **Token Issues**: Check JWT format and expiry
- **API Errors**: Verify backend endpoints and responses
- **State Problems**: Ensure providers are properly configured
- **Build Issues**: Clean and regenerate dependencies
