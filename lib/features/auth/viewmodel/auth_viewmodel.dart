import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unimarket/features/auth/repository/auth_repository.dart';
import 'package:unimarket/models/user_model.dart';

/// Auth durumu enum'ı.
enum AuthStatus {
  initial, // Başlangıç — henüz kontrol yapılmadı
  loading, // İşlem devam ediyor
  authenticated, // Giriş yapılmış
  unauthenticated, // Giriş yapılmamış
  error, // Hata oluştu
}

/// Auth ViewModel
///
/// Kullanıcı kimlik doğrulama durumunu yönetir.
/// Provider ile widget ağacına sunulur.
/// Login, Register, Logout ve durumu dinleme işlemlerini içerir.
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository() {
    // Auth state değişikliklerini dinle
    _authStateSubscription = _authRepository.authStateChanges.listen(
      _onAuthStateChanged,
    );
  }

  // ── State ────────────────────────────────────────────────
  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  StreamSubscription<User?>? _authStateSubscription;

  // ── Getters ──────────────────────────────────────────────
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // ── Auth State Listener ──────────────────────────────────
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _user = null;
    } else {
      try {
        final userModel = await _authRepository.getUserProfile(
          firebaseUser.uid,
        );
        if (userModel != null) {
          _user = userModel;
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
          _user = null;
        }
      } catch (e) {
        _status = AuthStatus.authenticated;
        // Profil çekilemese bile auth durumu geçerli
      }
    }
    notifyListeners();
  }

  // ── E-posta ile Kayıt ────────────────────────────────────
  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
    String? university,
    String? department,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final userModel = await _authRepository.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
        university: university,
        department: department,
      );

      _user = userModel;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ── E-posta ile Giriş ────────────────────────────────────
  Future<bool> login({required String email, required String password}) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final userModel = await _authRepository.loginWithEmail(
        email: email,
        password: password,
      );

      _user = userModel;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  // ── Çıkış Yap ────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
      _user = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Çıkış yapılırken hata oluştu.';
      notifyListeners();
    }
  }

  // ── Şifre Sıfırlama ──────────────────────────────────────
  Future<bool> resetPassword(String email) async {
    try {
      _errorMessage = null;
      notifyListeners();

      await _authRepository.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  // ── Hata Mesajını Temizle ─────────────────────────────────
  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = _user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
