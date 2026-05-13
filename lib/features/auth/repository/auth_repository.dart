import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:unimarket/models/user_model.dart';

/// Auth Repository
///
/// Firebase Auth ve Firestore üzerinden kimlik doğrulama ve
/// kullanıcı verisi işlemlerini yönetir.
/// MVVM mimarisinde ViewModel ile View arasındaki veri katmanıdır.
class AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Koleksiyon Referansı ─────────────────────────────────
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  // ── Auth State Stream ────────────────────────────────────
  /// Kullanıcı oturum durumu değişikliklerini dinler.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Şu an giriş yapmış kullanıcı.
  User? get currentUser => _auth.currentUser;

  /// Kullanıcı giriş yapmış mı?
  bool get isAuthenticated => _auth.currentUser != null;

  // ── E-posta / Şifre ile Kayıt ────────────────────────────
  /// Yeni kullanıcı kaydı oluşturur ve Firestore'a profil bilgilerini yazar.
  ///
  /// [email] — Kullanıcı e-posta adresi (öğrenci e-postası önerilir)
  /// [password] — En az 6 karakter
  /// [displayName] — Kullanıcının adı soyadı
  /// [university] — Üniversite adı (opsiyonel)
  /// [department] — Bölüm adı (opsiyonel)
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
    String? university,
    String? department,
  }) async {
    try {
      // 1. Firebase Auth'da kullanıcı oluştur
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Kullanıcı oluşturulamadı.');
      }

      // 2. Auth profilinde displayName güncelle
      await user.updateDisplayName(displayName.trim());

      // 3. E-posta doğrulama gönder
      if (!user.emailVerified) {
        await user.sendEmailVerification();
      }

      // 4. Firestore'a kullanıcı profilini kaydet
      final now = DateTime.now();
      final userModel = UserModel(
        uid: user.uid,
        email: email.trim(),
        displayName: displayName.trim(),
        university: university?.trim(),
        department: department?.trim(),
        createdAt: now,
        updatedAt: now,
        isEmailVerified: user.emailVerified,
      );

      await _usersCollection.doc(user.uid).set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Register Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e, stack) {
      debugPrint('General Register Error: $e\n$stack');
      throw Exception('Kayıt sırasında beklenmeyen bir hata oluştu.');
    }
  }

  // ── E-posta / Şifre ile Giriş ────────────────────────────
  /// Mevcut kullanıcı girişi yapar ve Firestore'dan profil bilgilerini çeker.
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw Exception('Giriş yapılamadı.');
      }

      // Firestore'dan kullanıcı profilini çek
      final userModel = await getUserProfile(user.uid);
      if (userModel == null) {
        throw Exception('Kullanıcı profili bulunamadı.');
      }

      return userModel;
    } on FirebaseAuthException catch (e) {
      debugPrint('Firebase Auth Login Error: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e, stack) {
      debugPrint('General Login Error: $e\n$stack');
      throw Exception('Giriş sırasında beklenmeyen bir hata oluştu.');
    }
  }

  // ── Çıkış Yap ────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ── Şifre Sıfırlama ──────────────────────────────────────
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // ── Kullanıcı Profili Okuma ───────────────────────────────
  /// Firestore'dan kullanıcı profilini döndürür.
  /// Eğer 'role' alanı yoksa (eski kullanıcı) otomatik olarak 'user' ekler.
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) return null;

    final data = doc.data();
    // Eski kullanıcılarda role alanı yoksa Firestore'a ekle (Sadece kendi profili ise veya adminse)
    if (data != null && !data.containsKey('role')) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && currentUser.uid == uid) {
        try {
          await _usersCollection.doc(uid).update({'role': 'user'});
        } catch (e) {
          debugPrint('Role güncellenemedi (normal): $e');
        }
      }
    }

    return UserModel.fromFirestore(doc);
  }

  // ── Kullanıcı Profili Güncelleme ──────────────────────────
  Future<void> updateUserProfile(UserModel user) async {
    final updatedUser = user.copyWith(updatedAt: DateTime.now());
    await _usersCollection.doc(user.uid).update(updatedUser.toFirestore());
  }

  // ── Firebase Auth Hata Yönetimi ───────────────────────────
  /// Firebase Auth hata kodlarını kullanıcı dostu Türkçe mesajlara çevirir.
  Exception _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return Exception('Bu e-posta adresi zaten kullanılıyor.');
      case 'invalid-email':
        return Exception('Geçersiz e-posta adresi.');
      case 'operation-not-allowed':
        return Exception('Bu giriş yöntemi devre dışı.');
      case 'weak-password':
        return Exception('Şifre çok zayıf. En az 6 karakter olmalı.');
      case 'user-disabled':
        return Exception('Bu hesap devre dışı bırakılmış.');
      case 'user-not-found':
        return Exception('Bu e-posta ile kayıtlı kullanıcı bulunamadı.');
      case 'wrong-password':
        return Exception('Yanlış şifre girdiniz.');
      case 'too-many-requests':
        return Exception('Çok fazla deneme yaptınız. Lütfen bekleyin.');
      case 'invalid-credential':
        return Exception('E-posta veya şifre hatalı.');
      default:
        return Exception('Bir hata oluştu: ${e.message}');
    }
  }
}
