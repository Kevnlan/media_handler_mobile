// Auth Provider
import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));
      
      // Simple validation - replace with real authentication
      if (email.isNotEmpty && password.length >= 6) {
        _isAuthenticated = true;
        _errorMessage = null;
      } else {
        _errorMessage = 'Invalid credentials';
      }
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(Duration(seconds: 2));
      
      // Simple validation - replace with real registration
      if (name.isNotEmpty && email.isNotEmpty && password.length >= 6) {
        _isAuthenticated = true;
        _errorMessage = null;
      } else {
        _errorMessage = 'Registration failed';
      }
    } catch (e) {
      _errorMessage = 'Registration failed: ${e.toString()}';
    }

    _isLoading = false;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}