import 'package:flutter/material.dart';

import '../data/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  List<String> _notifications = [
    'Welcome to the app!',
    'Your profile has been updated',
    'New features available',
  ];

  User? get currentUser => _currentUser;
  List<String> get notifications => _notifications;

  void setUser(User user) {
    _currentUser = user;
    notifyListeners();
  }

  void updateProfile({
    String? firstName,
    String? lastName,
    String? email,
    String? username,
    String? phoneNumber,
  }) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        firstName: firstName ?? _currentUser!.firstName,
        lastName: lastName ?? _currentUser!.lastName,
        email: email ?? _currentUser!.email,
        username: username,
        phoneNumber: phoneNumber,
      );
      notifyListeners();
    }
  }

  void clearUser() {
    _currentUser = null;
    notifyListeners();
  }

  void addNotification(String notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void removeNotification(int index) {
    if (index >= 0 && index < _notifications.length) {
      _notifications.removeAt(index);
      notifyListeners();
    }
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}
