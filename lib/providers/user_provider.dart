import 'package:flutter/material.dart';
import '../data/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  User? _currentUser;
  
  User? get currentUser => _currentUser;
  
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
}
