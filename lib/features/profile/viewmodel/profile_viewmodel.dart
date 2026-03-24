import 'package:flutter/material.dart';
import 'package:unimarket/features/profile/repository/profile_repository.dart';
import 'package:unimarket/models/user_model.dart';

/// Profile ViewModel
///
/// Kullanıcı profil bilgilerini yönetir.
/// Profil okuma, güncelleme ve stream-based dinleme işlemleri.
class ProfileViewModel extends ChangeNotifier {
  final ProfileRepository _repository;

  ProfileViewModel({ProfileRepository? repository})
    : _repository = repository ?? ProfileRepository();

  // ── State ────────────────────────────────────────────────
  UserModel? _user;
  bool _isLoading = false;
  bool _isEditing = false;
  String? _errorMessage;

  // ── Getters ──────────────────────────────────────────────
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isEditing => _isEditing;
  String? get errorMessage => _errorMessage;

  // ── Profil Yükleme ───────────────────────────────────────
  /// Kullanıcı profilini Firestore'dan yükler.
  Future<void> loadProfile(String uid) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _user = await _repository.getUserProfile(uid);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Profil yüklenirken hata oluştu.';
      notifyListeners();
    }
  }

  /// Kullanıcı profilini UserModel ile direkt set eder.
  void setUser(UserModel? user) {
    _user = user;
    notifyListeners();
  }

  // ── Profil Güncelleme ─────────────────────────────────────
  Future<bool> updateProfile({
    required String uid,
    String? displayName,
    String? photoUrl,
    String? university,
    String? department,
    int? studentYear,
    String? phoneNumber,
    String? bio,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _repository.updateProfile(
        uid: uid,
        displayName: displayName,
        photoUrl: photoUrl,
        university: university,
        department: department,
        studentYear: studentYear,
        phoneNumber: phoneNumber,
        bio: bio,
      );

      // Profili yeniden yükle
      await loadProfile(uid);

      _isEditing = false;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Profil güncellenirken hata oluştu.';
      notifyListeners();
      return false;
    }
  }

  // ── Düzenleme Modu ────────────────────────────────────────
  void toggleEditing() {
    _isEditing = !_isEditing;
    notifyListeners();
  }

  void cancelEditing() {
    _isEditing = false;
    notifyListeners();
  }

  // ── Hata Temizleme ────────────────────────────────────────
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
