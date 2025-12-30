import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  UserModel? get currentUser => _currentUser;

  Future<void> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock Logic
    UserRole role = UserRole.mother;
    String name = "Fatima Ali";

    if (email.contains("teacher")) {
      role = UserRole.teacher;
      name = "Ms. Huda";
    } else if (email.contains("admin")) {
      role = UserRole.admin;
      name = "Director Sarah";
    }

    _currentUser = UserModel(
      id: "123",
      email: email,
      name: name,
      role: role,
    );
    _isAuthenticated = true;
    notifyListeners();
  }

  Future<void> register(
      String email, String password, String name, UserRole role) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = UserModel(
      id: "456",
      email: email,
      name: name,
      role: role,
    );
    _isAuthenticated = true;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }
}
