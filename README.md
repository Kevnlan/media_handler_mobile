# Media Handler Mobile

A comprehensive Flutter application for media file management with robust user authentication and real-time file processing. The app provides an intuitive interface for uploading, organizing, and managing various media types including images, videos, and audio files with advanced features like file size validation, image compression, and full-screen previews.

## 🌟 Features

### 🔐 Authentication System
- **Complete User Management**: Registration, login, logout with JWT token authentication
- **Session Persistence**: Secure token storage with automatic refresh functionality  
- **User Profile**: Comprehensive profile management with customizable fields
- **Form Validation**: Real-time validation for email format and password strength (8+ characters)
- **Auto-Login**: Seamless authentication after successful registration
- **Token Management**: Automatic token refresh on expiry with graceful error handling

### 📱 Modern Interface
- **Bottom Navigation**: Intuitive navigation between Home and Profile screens
- **Floating Action Button**: Quick access to media upload functionality
- **Responsive Design**: Adaptive UI supporting various screen sizes and orientations
- **Material Design 3**: Modern UI components with consistent theming
- **Loading States**: Comprehensive loading indicators and progress tracking
- **Error Handling**: User-friendly error messages with retry mechanisms

### 📁 Advanced Media Management
- **Multi-Media Support**: Images (JPEG, PNG, GIF, WebP), Videos (MP4, AVI, MOV), Audio (MP3, WAV, AAC, M4A)
- **File Size Validation**: Automatic validation with 9.8MB warning threshold and 10MB maximum limit
- **Image Compression**: Intelligent image compression for large files to optimize upload times
- **File Previews**: Rich previews with thumbnails for images and type indicators for other media
- **Full-Screen Viewing**: Zoomable, pannable full-screen image viewer with Hero animations
- **Progress Tracking**: Real-time upload progress with detailed status information
- **Batch Operations**: Select and upload multiple files simultaneously

### 📸 Media Capture & Selection
- **Camera Integration**: Direct photo capture with permission handling
- **Gallery Access**: Multi-select from device gallery with filtering options
- **Audio Recording**: Built-in audio recorder with playback preview
- **File Picker**: System file picker for documents and other file types
- **Permission Management**: Automatic permission requests for camera, storage, and microphone

### 🎨 Enhanced UI/UX
- **Interactive Previews**: Tap images for full-screen viewing with zoom capabilities
- **Audio Playback**: In-app audio preview with play/pause controls
- **File Organization**: Visual file cards with metadata display (name, size, type)
- **Drag & Drop**: Intuitive file management interface
- **Animations**: Smooth transitions and hero animations between screens
- **Dark Mode Support**: Adaptive theming for different user preferences

## 📁 Project Architecture

```
lib/
├── core/
│   ├── constants/
│   │   └── api_constants.dart      # API endpoints and configuration
│   └── network/
│       └── dio_factory.dart        # HTTP client configuration
├── data/
│   ├── models/
│   │   ├── auth_models.dart        # Authentication request/response models
│   │   ├── user_model.dart         # User data model with profile fields
│   │   ├── media_model.dart        # Media file model with metadata
│   │   ├── collection_model.dart   # Media collection model
│   │   └── pagination_model.dart   # Pagination wrapper for API responses
│   ├── services/
│   │   ├── auth_service.dart       # Authentication API service
│   │   └── media_service.dart      # Media management API service
│   └── repositories/
│       └── media.dart              # Media upload repository
├── providers/
│   ├── auth_provider.dart          # Authentication state management
│   ├── user_provider.dart          # User profile state management
│   └── media_provider.dart         # Media file state with upload tracking
└── views/
    └── screens/
        ├── auth/
        │   ├── login.dart          # Login screen with validation
        │   └── register.dart       # Registration with comprehensive form
        ├── home/
        │   ├── main_screen.dart    # Main navigation container
        │   ├── home_page.dart      # Home dashboard with media overview
        │   ├── file_picker_page.dart # Advanced file selection interface
        │   └── profile_page.dart   # User profile management
        └── media/
            ├── media_list_page.dart     # Media browsing with filtering
            ├── media_detail_page.dart   # Individual media view
            └── collection_page.dart     # Media collections management
```

## 🛠 Technology Stack

### Core Framework
- **Flutter SDK**: ^3.9.0 - Cross-platform development framework
- **Dart**: Modern programming language with null safety

### State Management  
- **Provider**: ^6.1.5 - Reactive state management for UI updates
- **ChangeNotifier**: Built-in state management for provider pattern

### Networking & API
- **Dio**: ^5.9.0 - Feature-rich HTTP client with interceptors
- **JWT Decode**: ^0.3.1 - JWT token parsing and validation
- **Shared Preferences**: ^2.2.2 - Secure local storage for tokens

### Media Handling
- **File Picker**: ^10.3.3 - Multi-platform file selection with filtering
- **Image Picker**: ^1.2.0 - Camera and gallery access
- **Flutter Image Compress**: ^2.4.0 - Intelligent image compression
- **Record**: ^6.1.1 - Audio recording with permission handling
- **Audioplayers**: ^6.5.1 - Audio playback and controls
- **Path Provider**: ^2.1.5 - File system path management

### Permissions & Security
- **Permission Handler**: ^12.0.1 - Runtime permission management
- **Secure token storage** with automatic refresh
- **Form validation** with real-time feedback

## 📋 Prerequisites

### Development Environment
- **Flutter SDK**: >=3.9.0 
- **Dart SDK**: >=3.0.0 (included with Flutter)
- **IDE**: Android Studio, VS Code, or IntelliJ IDEA
- **Git**: For version control

### Platform-Specific Requirements

#### Android Development
- **Android Studio**: Latest stable version
- **Android SDK**: API level 21+ (Android 5.0+)
- **Java Development Kit**: JDK 11 or higher
- **Android Emulator** or physical device for testing

#### iOS Development (macOS only)
- **Xcode**: 14.0 or higher
- **iOS SDK**: iOS 13.0 or higher
- **CocoaPods**: Dependency management for iOS
- **iOS Simulator** or physical device for testing

#### Web Development (Optional)
- **Chrome browser** for web debugging
- **Web server** for hosting (development)

## 🚀 Installation & Setup

### 1. Clone the Repository
```bash
git clone https://github.com/Kevnlan/media_handler_mobile.git
cd media_handler_mobile
```

### 2. Install Dependencies
```bash
# Install Flutter dependencies
flutter pub get

# For iOS (macOS only) - install CocoaPods dependencies
cd ios && pod install && cd ..
```

### 3. Environment Setup
```bash
# Verify Flutter installation
flutter doctor

# Check for any missing dependencies
flutter doctor --verbose
```

### 4. Configure Backend URL
1. Open `lib/core/constants/api_constants.dart`
2. Update the `baseUrl` constant:
   ```dart
   // For production
   static const String baseUrl = 'https://your-production-api.com';
   
   // For local development
   static const String baseUrl = 'http://localhost:8000';
   
   // For network testing (replace with your IP)
   static const String baseUrl = 'http://192.168.1.100:8000';
   ```

### 5. Run the Application

#### Development Mode
```bash
# Run on connected device/emulator
flutter run

# Run with hot reload enabled
flutter run --hot

# Run on specific device
flutter devices  # List available devices
flutter run -d <device-id>
```

#### Platform-Specific Commands
```bash
# Android
flutter run -d android

# iOS (macOS only)  
flutter run -d ios

# Web browser
flutter run -d web-server --web-port 8080

# Desktop (if enabled)
flutter run -d windows
flutter run -d macos
flutter run -d linux
```

## 🏗 Building for Production

### Android Builds

#### 1. APK (Direct Installation)
```bash
# Debug APK
flutter build apk --debug

# Release APK (smaller size)
flutter build apk --release

# Split APKs by architecture (recommended)
flutter build apk --split-per-abi --release
```

#### 2. App Bundle (Google Play Store)
```bash
# Release App Bundle (recommended for Play Store)
flutter build appbundle --release

# With custom build number and version
flutter build appbundle --build-name=1.0.1 --build-number=2
```

#### 3. Signing Configuration
Create `android/key.properties`:
```properties
storePassword=your-store-password
keyPassword=your-key-password  
keyAlias=your-key-alias
storeFile=your-keystore-file.jks
```

### iOS Builds (macOS only)

#### 1. Build iOS App
```bash
# Release build
flutter build ios --release

# With custom configuration
flutter build ios --release --no-codesign
```

#### 2. Archive for App Store
```bash
# Build and archive
flutter build ipa --release

# Custom export options
flutter build ipa --release --export-options-plist=ios/ExportOptions.plist
```

### Web Build
```bash
# Build for web
flutter build web --release

# With custom base href
flutter build web --base-href /media-handler/
```

## ⚙ Configuration Guide

### 1. API Configuration

#### Backend URL Setup
Update `lib/core/constants/api_constants.dart`:
```dart
class ApiConstants {
  // REQUIRED: Update with your backend URL
  static const String baseUrl = 'https://your-backend-api.com';
  
  // Development URLs
  // static const String baseUrl = 'http://localhost:8000';        // Local
  // static const String baseUrl = 'http://192.168.1.100:8000';  // Network
  // static const String baseUrl = 'https://staging-api.com';     // Staging
  
  // Authentication endpoints
  static const String loginEndpoint = '/api/auth/login/';
  static const String registerEndpoint = '/api/auth/register/';
  static const String refreshEndpoint = '/api/auth/refresh/';
  static const String profileEndpoint = '/api/auth/profile/';
  
  // Media endpoints
  static const String mediaEndpoint = '/api/media';
  static const String collectionsEndpoint = '/api/media/collection';
}
```

#### Required Backend Endpoints
Your Django/backend API must implement these endpoints:

| Method | Endpoint | Description | Authentication |
|--------|----------|-------------|----------------|
| `POST` | `/api/auth/login/` | User authentication | None |
| `POST` | `/api/auth/register/` | User registration | None |
| `POST` | `/api/auth/refresh/` | Token refresh | None |
| `POST` | `/api/auth/logout/` | User logout | Required |
| `GET` | `/api/auth/profile/` | User profile | Required |
| `GET` | `/api/media` | List media files | Required |
| `POST` | `/api/media` | Upload media file | Required |
| `GET` | `/api/media/{id}` | Get specific media | Required |
| `PUT`/`PATCH` | `/api/media/{id}` | Update media | Required |
| `DELETE` | `/api/media/{id}` | Delete media | Required |

#### API Request/Response Schemas

**Login Request:**
```json
{
  "email": "testuser@example.com",
  "password": "testpassword123"
}
```

**Login Response:**
```json
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzM3MjA2ODcxLCJpYXQiOjE3MzcyMDMyNzEsImp0aSI6IjVmYTIzNGE4NzY5MTQ1YjI4YzY5NWE0ZjNkMzRiOGIwIiwidXNlcl9pZCI6MX0.KmO_8OLoiCr6P8GHmG6FpLCOMKO8Jgj3XxYgWvL5VE0",
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTczNzI4OTY3MSwiaWF0IjoxNzM3MjAzMjcxLCJqdGkiOiI4YjU2YzNkZTQyMzE0YjU4OGY3ZWE2NzEyOTM0NWRmYiIsInVzZXJfaWQiOjF9.wE6n8GJjU3qO2tF5HhZgYs_9Xk3J2mK8pQ4rV7wN1lE",
  "user": {
    "id": 1,
    "first_name": "Test",
    "last_name": "User", 
    "email": "testuser@example.com",
    "username": "testuser",
    "phone_number": "+1234567890"
  }
}
```

**Register Request:**
```json
{
  "first_name": "Test",
  "last_name": "User",
  "email": "testuser@example.com", 
  "username": "testuser",
  "phone_number": "+1234567890",
  "password": "testpassword123"
}
```

**Media Upload Response:**
```json
{
  "id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "name": "test_image.jpg",
  "type": "image",
  "size": 1048576,
  "file_url": "https://api.example.com/media/uploads/test_image.jpg",
  "thumbnail_url": "https://api.example.com/media/thumbnails/test_image_thumb.jpg",
  "description": "Test image upload",
  "collection_id": null,
  "created_at": "2025-01-18T14:30:25.123456Z",
  "updated_at": "2025-01-18T14:30:25.123456Z"
}
```

### 2. Android Configuration

#### Application ID Setup
Update `android/app/build.gradle.kts`:
```kotlin
android {
    namespace = "com.yourcompany.media_handler"  // Change this
    
    defaultConfig {
        applicationId = "com.yourcompany.media_handler"  // Change this
        minSdk = 21  // Android 5.0+
        targetSdk = 34  // Latest Android
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }
}
```

#### Permissions Configuration
The app includes comprehensive permissions in `android/app/src/main/AndroidManifest.xml` for network access, media access, camera, and recording capabilities. All permissions are automatically configured in the project.

#### Signing Configuration (Production)
1. Generate a signing key:
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

2. Create `android/key.properties`:
   ```properties
   storePassword=your-store-password
   keyPassword=your-key-password
   keyAlias=upload
   storeFile=upload-keystore.jks
   ```

3. Update `android/app/build.gradle.kts`:
   ```kotlin
   android {
       signingConfigs {
           create("release") {
               keyAlias = keystoreProperties["keyAlias"] as String
               keyPassword = keystoreProperties["keyPassword"] as String
               storeFile = file(keystoreProperties["storeFile"] as String)
               storePassword = keystoreProperties["storePassword"] as String
           }
       }
       buildTypes {
           release {
               signingConfig = signingConfigs.getByName("release")
           }
       }
   }
   ```

### 3. iOS Configuration (macOS only)

#### Bundle Identifier Setup
Update `ios/Runner.xcodeproj/project.pbxproj` or use Xcode:
```
PRODUCT_BUNDLE_IDENTIFIER = com.yourcompany.mediahandler
```

#### Permissions Setup
Update `ios/Runner/Info.plist`:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture photos and videos</string>

<key>NSPhotoLibraryUsageDescription</key> 
<string>This app needs photo library access to select and upload media</string>

<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record audio</string>

<key>NSLocationWhenInUseUsageDescription</key>
<string>This app may use location for geotagging media files</string>
```



### 5. Environment Variables
Create a `.env` file for different environments:
```env
# Development
API_BASE_URL=http://localhost:8000
DEBUG_MODE=true

# Staging  
# API_BASE_URL=https://staging-api.yourapp.com
# DEBUG_MODE=false

# Production
# API_BASE_URL=https://api.yourapp.com  
# DEBUG_MODE=false
```

## 📱 Usage Guide

### 🚀 First Launch & Setup
1. **Initial Setup**
   - Launch the app and wait for the authentication check
   - The app automatically detects if you're logged in from previous sessions

2. **User Registration**
   - Tap **"Sign Up"** for new users
   - Fill in the registration form:
     ```
     Required Fields:
     ✓ First Name, Last Name
     ✓ Email address (valid format)
     ✓ Password (minimum 8 characters)
     
     Optional Fields:
     • Username (unique identifier)
     • Phone number (with country code)
     ```
   - Tap **"Register"** - you'll be automatically logged in

3. **User Login** 
   - Use your registered email and password
   - Enable **"Remember me"** for persistent sessions
   - Forgot password? Use the recovery link (if implemented)

### 🎯 Core Features

#### Navigation & Interface
- **Home Tab**: View recent media, collections, and quick actions
- **Profile Tab**: Manage account settings and user information  
- **Floating Action Button (+)**: Quick access to media upload
- **Search**: Find specific media files quickly
- **Filter**: Sort by media type, date, or collection

#### Media Upload Process
1. **Select Upload Method**:
   ```
   📷 Camera: Take new photos/videos
   🖼️ Gallery: Choose from existing media
   🎵 Audio: Record new audio or select files
   📁 Files: Browse and select any file type
   ```

2. **File Selection Features**:
   - **Multi-select**: Choose multiple files at once
   - **Preview**: See thumbnails and file information
   - **Size validation**: Automatic warnings for large files
   - **Type detection**: Automatic media type classification

3. **Upload Configuration**:
   - Add descriptions to each file
   - Assign to collections (optional)
   - Monitor upload progress in real-time
   - Handle errors with retry options

#### File Size Management
- **Warning Threshold**: 9.8MB - shows warning dialog
- **Maximum Limit**: 10MB - blocks upload with error message
- **Automatic Compression**: Images are compressed intelligently
- **Progress Tracking**: Real-time upload progress with speed metrics

#### Media Viewing & Management
- **List View**: Browse all media with filters and sorting
- **Detail View**: Full media information with metadata
- **Full-Screen View**: 
  - Tap any image for full-screen viewing
  - Pinch to zoom (0.5x to 4x)
  - Pan and rotate support
  - Share options and download

### 🔒 Authentication Features

#### Session Management
- **Auto-Login**: Seamless login after registration
- **Token Persistence**: Sessions survive app restarts
- **Auto-Refresh**: Tokens refresh automatically before expiry
- **Secure Storage**: Encrypted token storage using SharedPreferences

#### Security Features
- **JWT Validation**: Automatic token validation on startup
- **Secure Headers**: Bearer token authentication
- **Error Handling**: Graceful handling of authentication failures
- **Logout Protection**: Secure token cleanup on logout



## 🧪 Development & Testing

### Development Environment Setup
```bash
# Run with hot reload (recommended for development)
flutter run --hot

# Run with debug information
flutter run --debug --verbose

# Enable desktop support (if needed)
flutter config --enable-windows-desktop
flutter config --enable-macos-desktop  
flutter config --enable-linux-desktop
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/providers/auth_provider_test.dart

# Run tests with coverage
flutter test --coverage
```

### Debugging
- **Flutter Inspector**: Inspect widget hierarchy and properties
- **Network Tab**: Track HTTP requests and responses
- **Hot Reload**: Instant code changes during development

### Troubleshooting Common Issues

**Build Issues**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run
```

**API Connection Issues**
- Check backend server is running
- Verify API endpoints match expected schema
- Ensure CORS is configured correctly
- For local development:
  - Android Emulator: Use `10.0.2.2:8000`
  - iOS Simulator: Use `localhost:8000`
  - Physical Device: Use your computer's IP address

## 🔄 Backend Integration

### 📋 API Requirements

This Flutter app requires a Django REST API backend with specific endpoints and data models:

#### Required Endpoints
```python
# Authentication endpoints
POST /api/auth/register/
POST /api/auth/login/
POST /api/auth/refresh/
GET  /api/auth/user/

# Media endpoints
GET    /api/media/
POST   /api/media/
GET    /api/media/{id}/
PUT    /api/media/{id}/
DELETE /api/media/{id}/

# User profile endpoints
GET    /api/user/profile/
PUT    /api/user/profile/
```

#### Expected Data Models

**User Registration Request**
```json
{
  "email": "user@example.com",
  "password": "securepassword123",
  "password_confirm": "securepassword123"
}
```

**Authentication Response**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "user": {
    "id": 1,
    "email": "user@example.com",
    "first_name": "John",
    "last_name": "Doe"
  }
}
```

**Media Object Response**
```json
{
  "id": 1,
  "title": "My Photo",
  "description": "A beautiful sunset",
  "media_type": "image",
  "file_url": "https://api.example.com/media/uploads/photo.jpg",
  "thumbnail_url": "https://api.example.com/media/thumbnails/photo_thumb.jpg",
  "file_size": 2048576,
  "created_at": "2024-01-15T10:30:00Z",
  "user": 1
}
```

#### CORS Configuration
```python
# In Django settings.py
CORS_ALLOWED_ORIGINS = [
    "http://localhost:3000",
    "http://127.0.0.1:3000",
    "http://10.0.2.2:8000",  # Android emulator
]

CORS_ALLOW_ALL_ORIGINS = True  # Only for development
CORS_ALLOW_CREDENTIALS = True

CORS_ALLOW_HEADERS = [
    'accept',
    'accept-encoding',
    'authorization',
    'content-type',
    'dnt',
    'origin',
    'user-agent',
    'x-csrftoken',
    'x-requested-with',
]
```



## 🤝 Contributing

### 📝 Contribution Guidelines

We welcome contributions to improve this media handler app! Here's how to get started:

#### 🚀 Getting Started
1. **Fork the Repository**
   ```bash
   git clone https://github.com/your-username/media_handler.git
   cd media_handler
   ```

2. **Set Up Development Environment**
   ```bash
   flutter pub get
   flutter pub run build_runner build
   ```

3. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   git checkout -b fix/issue-description
   git checkout -b docs/documentation-update
   ```

#### 🧪 Development Workflow
```bash
# 1. Make your changes
# 2. Run tests
flutter test

# 3. Check code formatting
dart format lib/ test/
dart analyze

# 4. Test on multiple platforms
flutter run -d chrome    # Web testing
flutter run -d android   # Android testing
flutter run -d ios       # iOS testing (macOS only)

# 5. Commit changes
git add .
git commit -m "feat: add new feature description"
```

#### 📋 Code Standards
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful variable and function names
- Add comprehensive comments for complex logic
- Maintain consistent code formatting
- Write unit tests for new features
- Update documentation for API changes

#### 🔍 Pull Request Process
1. **Ensure CI Passes**: All tests and linting must pass
2. **Update Documentation**: Include relevant README updates
3. **Add Tests**: Cover new functionality with appropriate tests
4. **Follow Naming**: Use conventional commit messages
5. **Review Ready**: Ensure code is ready for review

#### 🐛 Bug Reports
When reporting bugs, please include:
- Flutter version (`flutter --version`)
- Device/Platform information
- Steps to reproduce
- Expected vs actual behavior
- Relevant error messages
- Screenshots (if UI related)

#### 💡 Feature Requests
For new features, please provide:
- Clear problem description
- Proposed solution approach
- Use case examples
- UI mockups (if applicable)
- Implementation considerations

### 🏷️ Commit Message Format
```bash
feat: add new media preview functionality
fix: resolve authentication token refresh issue
docs: update API integration guide
style: improve file picker UI layout
refactor: optimize media provider performance
test: add unit tests for media validation
chore: update dependencies and build scripts
```

## 📄 License

### MIT License

```
MIT License

Copyright (c) 2024 Media Handler Flutter App

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

---

## 🙏 Acknowledgments

- **Flutter Team** - For the amazing cross-platform framework
- **Provider Package** - For elegant state management solution  
- **Dio HTTP Client** - For robust networking capabilities
- **Image Compression Libraries** - For efficient media processing
- **Community Contributors** - For ongoing improvements and feedback

---

## 📞 Support & Contact

- 📧 **Email**: support@mediahandler.com
- 🐛 **Issues**: [GitHub Issues](https://github.com/your-username/media_handler/issues)
- 💬 **Discussions**: [GitHub Discussions](https://github.com/your-username/media_handler/discussions)
- 📖 **Wiki**: [Project Wiki](https://github.com/your-username/media_handler/wiki)

---

**Happy Coding! 🚀**
