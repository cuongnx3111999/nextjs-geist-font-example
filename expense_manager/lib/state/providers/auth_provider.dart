import 'package:flutter/foundation.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  // Initialize the provider
  Future<void> initializeApp() async {
    _setLoading(true);
    try {
      // Listen to auth state changes
      _authService.user.listen((user) {
        _user = user;
        notifyListeners();
      });
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Sign in with email and password
  Future<void> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();
    
    try {
      _user = await _authService.signInWithEmailAndPassword(email, password);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Register with email and password
  Future<void> register(String email, String password, {String? displayName}) async {
    _setLoading(true);
    _clearError();
    
    try {
      _user = await _authService.registerWithEmailAndPassword(
        email, 
        password,
        displayName: displayName,
      );
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Update profile
  Future<void> updateProfile({String? displayName}) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.updateProfile(displayName: displayName);
      if (displayName != null && _user != null) {
        _user = _user!.copyWith(displayName: displayName);
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _authService.changePassword(currentPassword, newPassword);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
