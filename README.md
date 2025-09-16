# Media Handler

A comprehensive Flutter application for handling media files and user authentication. The app provides a modern, intuitive interface for users to manage, upload, and organize various types of media files including images, videos, and documents.

## Features

### 🔐 Authentication
- **User Registration**: Complete registration with first name, last name, email, password, optional username and phone
- **User Login**: Secure login with email and password
- **JWT Token Management**: Automatic token storage and refresh using SharedPreferences
- **Session Persistence**: Remember login state across app restarts
- **Token Validation**: Automatic token expiry checking and refresh
- **Form Validation**: Enhanced validation for email format and password strength (8+ characters)
- **Error Handling**: Comprehensive error handling with user-friendly messages
- **Auto-Login**: Automatic login after successful registration

### 📱 Main Interface
- **Bottom Navigation**: Easy navigation between Home and Profile screens
- **Floating Action Button**: Quick access to file selection functionality
- **Responsive Design**: Adaptive UI that works across different screen sizes

### 📁 File Management
- **Multi-File Selection**: Choose multiple files at once
- **File Type Filtering**: 
  - Photos & Videos (Images and media files)
  - Documents (PDF, DOC, DOCX, TXT)
  - All Files (Any file type)
- **File Preview**: Visual file icons based on file type
- **File Information**: Display file names and sizes
- **Upload Simulation**: Mock upload functionality with progress indication

### 🎨 UI/UX Features
- **Material Design**: Clean, modern interface following Material Design guidelines
- **Loading States**: Visual feedback during operations
- **Error Handling**: Comprehensive error handling with user feedback
- **Accessibility**: Proper labeling and navigation support

## Project Structure

```
lib/
├── core/                    # Core utilities and constants
├── data/
│   ├── models/             # Data models (User, etc.)
│   └── repositories/       # Data access layer
├── providers/              # State management (Provider pattern)
│   ├── auth_provider.dart  # Authentication state
│   ├── home_provider.dart  # Home screen state
│   ├── media_provider.dart # Media handling state
│   └── user_provider.dart  # User data state
└── views/
    ├── screens/
    │   ├── auth/           # Authentication screens
    │   │   ├── login.dart  # Login page
    │   │   └── register.dart # Registration page
    │   └── home/           # Main application screens
    │       ├── home_page.dart      # Home screen
    │       ├── main_screen.dart    # Main navigation
    │       ├── profile_page.dart   # User profile
    │       └── file_picker_page.dart # File selection
    └── widgets/            # Reusable UI components
```

## Technologies Used

- **Flutter**: Cross-platform mobile development framework
- **Provider**: State management solution for authentication and user state
- **Dio**: HTTP client for API communication with automatic token management
- **SharedPreferences**: Local storage for authentication tokens and user data
- **JWT Decode**: JWT token parsing and validation
- **File Picker**: Multi-platform file selection
- **Image Picker**: Camera and gallery image selection
- **Path Provider**: File system path utilities

## Prerequisites

Before running this application, make sure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>=3.9.0)
- [Dart SDK](https://dart.dev/get-dart) (comes with Flutter)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)

For Android development:
- Android SDK
- Android Emulator or physical Android device

For iOS development (macOS only):
- Xcode
- iOS Simulator or physical iOS device

## Installation & Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/Kevnlan/media_handler_mobile.git
   cd media_handler_mobile
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Verify Flutter installation**
   ```bash
   flutter doctor
   ```
   Ensure all required components are installed and configured.

4. **Run the application**
   
   For development (debug mode):
   ```bash
   flutter run
   ```
   
   For specific platforms:
   ```bash
   # Android
   flutter run -d android
   
   # iOS (macOS only)
   flutter run -d ios
   
   # Web
   flutter run -d web
   ```

## Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (recommended for Play Store)
```bash
flutter build appbundle --release
```

### iOS (macOS only)
```bash
flutter build ios --release
```

## Configuration

### API Configuration

Before running the app, you need to configure your Django backend URL:

1. Open `lib/core/constants/api_constants.dart`
2. Replace `YOUR_DJANGO_API_BASE_URL` with your actual Django backend URL
   ```dart
   static const String baseUrl = 'https://your-django-backend.com';
   // For local development use: 'http://localhost:8000'
   ```

3. Make sure your Django backend has the following endpoints:
   - `POST /api/auth/login/` - User login  
   - `POST /api/auth/logout/` - User logout
   - `POST /api/auth/register/` - User registration
   - `POST /api/auth/refresh/` - Token refresh
   - `GET /api/auth/profile/` - User profile

#### Expected API Schemas

**Login Request:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Register Request:**
```json
{
  "first_name": "John",
  "last_name": "Doe",
  "email": "user@example.com",
  "username": "johndoe",
  "phone_number": "0900111222", 
  "password": "password123"
}
```

**Profile Response:**
```json
{
  "id": 3,
  "first_name": "John",
  "last_name": "Doe",
  "email": "user@example.com",
  "username": "johndoe",
  "phone_number": "0900111222"
}
```

### Backend Model Compatibility

The app is designed to work with the following Django CustomUser model:
```python
class CustomUser(AbstractBaseUser, PermissionsMixin):
    first_name = models.CharField(max_length=50)
    last_name = models.CharField(max_length=50) 
    email = models.EmailField(unique=True)
    username = models.CharField(max_length=50, blank=True, null=True, unique=True)
    phone_number = models.CharField(max_length=15, blank=True, null=True, unique=True)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    date_joined = models.DateTimeField(auto_now_add=True)
```

### File Permissions

The app requires certain permissions to access files and media:

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.CAMERA" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to select images</string>
```

## Usage

### First Time Setup
1. **Launch the app** - You'll see a splash screen while the app checks for existing authentication
2. **Register** - If you're a new user, tap "Sign Up" and fill in:
   - First Name and Last Name (required)
   - Email address (required)
   - Username (optional)
   - Phone number (optional) 
   - Password (minimum 8 characters)
3. **Auto-Login** - After successful registration, you'll be automatically logged in

### Regular Usage
1. **Login** - Use your registered email and password
2. **Session Persistence** - The app remembers your login; you won't need to log in again unless:
   - You manually log out
   - Your authentication token expires
   - You clear app data
3. **Navigate** - Use the bottom navigation to switch between Home and Profile
4. **Select Files** - Tap the floating action button (+) to open the file picker
5. **Choose File Types** - Select from Photos & Videos, Documents, or All Files
6. **Upload** - Select files and tap the upload button

### Authentication Features
- **Token Auto-Refresh**: Expired tokens are automatically refreshed in the background
- **Logout**: Access logout from the profile screen (when implemented)
- **Password Requirements**: Minimum 8 characters with proper email validation

## Development

### Running Tests
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

### Code Analysis
```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/
```

### Debugging
- Use Flutter Inspector in your IDE for widget debugging
- Use `print()` statements or debugger breakpoints
- Check console logs for detailed error information

## Troubleshooting

### Common Issues

1. **ProviderNotFoundException Error**
   ```
   Error: Could not find the correct Provider<AuthProvider> above this Consumer<AuthProvider> Widget
   ```
   **Solution**: The app is already configured with `MultiProvider` in `main.dart`. If you see this error:
   - Perform a hot restart (not hot reload)
   - Ensure you haven't accidentally removed the provider setup
   - Check that all providers are properly imported

2. **Dependencies not found**
   ```bash
   flutter clean
   flutter pub get
   ```

3. **Build issues**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

4. **Permission errors on Android**
   - Ensure permissions are added to AndroidManifest.xml
   - Grant permissions manually in device settings

5. **iOS build errors**
   - Run `cd ios && pod install`
   - Clean build folder in Xcode

6. **Authentication API Errors**
   ```
   DioException: Connection refused / Network error
   ```
   **Solution**:
   - Ensure your Django backend is running
   - Check the API base URL in `auth_service.dart`
   - Verify your API endpoints match the expected format
   - Check network permissions for your device/emulator

7. **Token Validation Issues**
   **Solution**:
   - Clear app data or reinstall the app to clear stored tokens
   - Check that your Django backend returns proper JWT tokens
   - Verify token refresh endpoint is working correctly

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

If you encounter any issues or have questions:
- Create an issue on GitHub
- Check the [Flutter documentation](https://flutter.dev/docs)
- Visit [Flutter community](https://flutter.dev/community) for help

---

**Happy coding! 🚀**
