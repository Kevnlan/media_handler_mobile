import 'package:flutter/material.dart';
import 'package:media_handler/providers/auth_provider.dart';
import 'package:media_handler/providers/user_provider.dart';
import 'package:media_handler/providers/media_provider.dart';
import 'package:media_handler/views/screens/auth/login.dart';
import 'package:media_handler/views/screens/home/main_screen.dart';
import 'package:provider/provider.dart';

/// Entry point of the Media Handler application.
///
/// Initializes the app with all necessary providers for state management.
void main() {
  runApp(const MyApp());
}

/// Root widget of the Media Handler application.
///
/// Sets up the Provider pattern for state management and handles
/// authentication flow by showing appropriate screens based on auth state.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // Initialize all providers for state management
      providers: [
        // Authentication state and JWT token management
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // User profile data and notifications
        ChangeNotifierProvider(create: (_) => UserProvider()),
        // Media file management and uploads
        ChangeNotifierProvider(create: (_) => MediaProvider()),
      ],
      child: MaterialApp(
        title: 'Media Handler',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            // Show splash screen while checking authentication state
            if (authProvider.isInitializing) {
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.account_circle, size: 100, color: Colors.blue),
                      SizedBox(height: 20),
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text(
                        'Media Handler',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Navigate to main screen if authenticated, login screen otherwise
            return authProvider.isAuthenticated ? MainScreen() : LoginPage();
          },
        ),
      ),
    );
  }
}
