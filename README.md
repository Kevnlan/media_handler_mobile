# Media Handler

A comprehensive Flutter application for handling media files and user authentication. The app provides a modern, intuitive interface for users to manage, upload, and organize various types of media files including images, videos, and documents.

## Features

### 🔐 Authentication
- **User Login/Registration**: Secure authentication system with email and password
- **Form Validation**: Real-time validation for user inputs
- **Error Handling**: User-friendly error messages and loading states
- **State Management**: Provider pattern for authentication state

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
- **Provider**: State management solution
- **File Picker**: Multi-platform file selection
- **Image Picker**: Camera and gallery image selection
- **Dio**: HTTP client for API calls
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

1. **Launch the app** - You'll be presented with the login screen
2. **Login/Register** - Use any email and a password with at least 6 characters
3. **Navigate** - Use the bottom navigation to switch between Home and Profile
4. **Select Files** - Tap the floating action button (+) to open the file picker
5. **Choose File Types** - Select from Photos & Videos, Documents, or All Files
6. **Upload** - Select files and tap the upload button to simulate file upload

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

1. **Dependencies not found**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Build issues**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

3. **Permission errors on Android**
   - Ensure permissions are added to AndroidManifest.xml
   - Grant permissions manually in device settings

4. **iOS build errors**
   - Run `cd ios && pod install`
   - Clean build folder in Xcode

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
