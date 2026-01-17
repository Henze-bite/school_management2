import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

class AuthProvider extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  User? _currentUser;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String _errorMessage = '';

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Simple login (in production, use backend authentication)
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Validate credentials
      if (username.isEmpty || password.isEmpty) {
        _errorMessage = 'Username and password cannot be empty';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create a demo user (in production, verify against backend)
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        username: username,
        email: '$username@school.edu',
        role: username.toLowerCase().contains('admin') ? 'admin' : 'teacher',
      );

      await _dbService.insertUser(user);
      _currentUser = user;
      _isLoggedIn = true;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _isLoggedIn = false;
    _errorMessage = '';
    notifyListeners();
  }

  Future<void> updateProfile(User user) async {
    try {
      await _dbService.updateUser(user);
      _currentUser = user;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update profile: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
