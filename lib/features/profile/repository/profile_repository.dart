import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimarket/models/user_model.dart';

/// Profile Repository
///
/// Kullanıcı profili ile ilgili Firestore işlemlerini yönetir.
/// Auth'dan bağımsız olarak profil okuma, güncelleme ve istatistik işlemleri.
class ProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _firestore.collection('users');

  // ── Profil Okuma ──────────────────────────────────────────
  /// Kullanıcı profilini Firestore'dan çeker.
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  /// Kullanıcı profilini gerçek zamanlı dinler.
  Stream<UserModel?> watchUserProfile(String uid) {
    return _usersCollection.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  // ── Profil Güncelleme ─────────────────────────────────────
  /// Kullanıcı profilini günceller (kısmi güncelleme).
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? photoUrl,
    String? university,
    String? department,
    int? studentYear,
    String? phoneNumber,
    String? bio,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };

    if (displayName != null) updates['displayName'] = displayName.trim();
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    if (university != null) updates['university'] = university.trim();
    if (department != null) updates['department'] = department.trim();
    if (studentYear != null) updates['studentYear'] = studentYear;
    if (phoneNumber != null) updates['phoneNumber'] = phoneNumber.trim();
    if (bio != null) updates['bio'] = bio.trim();

    await _usersCollection.doc(uid).update(updates);
  }

  // ── İstatistik Güncelleme ─────────────────────────────────
  /// Satış sayısını artırır.
  Future<void> incrementSales(String uid) async {
    await _usersCollection.doc(uid).update({
      'totalSales': FieldValue.increment(1),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Alım sayısını artırır.
  Future<void> incrementPurchases(String uid) async {
    await _usersCollection.doc(uid).update({
      'totalPurchases': FieldValue.increment(1),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Takas sayısını artırır.
  Future<void> incrementTrades(String uid) async {
    await _usersCollection.doc(uid).update({
      'totalTrades': FieldValue.increment(1),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Kullanıcı puanını günceller.
  Future<void> updateRating(String uid, double newRating) async {
    await _usersCollection.doc(uid).update({
      'rating': newRating,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}
