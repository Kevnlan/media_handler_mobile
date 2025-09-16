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

  void updateProfile(String name, String email) {
    if (_currentUser != null) {
      _currentUser = User(
        id: _currentUser!.id,
        name: name,
        email: email,
      );
      notifyListeners();
    }
  }

  void addNotification(String notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}