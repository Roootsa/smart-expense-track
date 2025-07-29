import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:smart_expense_tracker/models/user_model.dart';
import 'package:smart_expense_tracker/services/auth_service.dart';

enum AuthStatus { uninitialized, authenticated, authenticating, unauthenticated }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  UserModel? _userModel;
  AuthStatus _status = AuthStatus.uninitialized;

  AuthProvider() {
    _authService.user.listen(_onAuthStateChanged);
  }

  // Getters
  AuthStatus get status => _status;
  User? get user => _user;
  UserModel? get userModel => _userModel;

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _user = null;
      _userModel = null;
    } else {
      _user = firebaseUser;
      // Ambil detail user dari Firestore
      _userModel = await _authService.getUserModel(firebaseUser.uid);
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  // --- FUNGSI UTAMA ---
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _authService.signIn(email, password);
      // AuthWrapper di main.dart akan otomatis handle navigasi
    } catch (e) {
      // Melempar error agar bisa ditangkap oleh UI (SnackBar)
      rethrow;
    }
  }

  Future<void> signUpWithEmail(String email, String password, String displayName) async {
    try {
      await _authService.signUp(email, password, displayName);
      // AuthWrapper di main.dart akan otomatis handle navigasi
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile(String displayName) async {
    try {
      await _authService.updateProfile(displayName);
      // Setelah berhasil, perbarui data user model secara lokal agar UI langsung berubah
      _userModel = await _authService.getUserModel(user!.uid);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }


  Future<void> signOut() async {
    await _authService.signOut();
  }
}