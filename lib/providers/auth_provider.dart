import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';


class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  User? _user;
  bool _isLoading = false;
  String? _errorMessage;


  // Getters
  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;


  AuthProvider() {
    _initializeAuth();
  }


  /// Initialize auth state listener
  void _initializeAuth() {
    _firebaseAuth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }


  /// Sign Up with email and password
  Future<bool> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();


      // Create user account
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );


      // Update display name
      await userCredential.user?.updateDisplayName(displayName);
      await userCredential.user?.reload();


      _user = _firebaseAuth.currentUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();


      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );


      _user = userCredential.user;
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  /// Logout
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();


      await _firebaseAuth.signOut();
      _user = null;
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout failed: $e';
      _isLoading = false;
      notifyListeners();
    }
  }


  /// Reset password
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();


      await _firebaseAuth.sendPasswordResetEmail(email: email);
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _getAuthErrorMessage(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'An unexpected error occurred';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }


  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }


  /// Helper method to get user-friendly error messages
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'Email is already registered.';
      case 'invalid-email':
        return 'Invalid email format.';
      case 'user-not-found':
        return 'User not found.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many login attempts. Try again later.';
      case 'user-disabled':
        return 'User account has been disabled.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}

