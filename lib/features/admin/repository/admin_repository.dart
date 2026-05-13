import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimarket/models/user_model.dart';
import 'package:unimarket/models/product_model.dart';
import 'package:unimarket/features/product/model/product_category.dart';

/// Admin Repository
///
/// Admin paneli için Firestore işlemlerini yönetir.
/// Kullanıcı yönetimi, ürün yönetimi ve istatistikler.
class AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _productsCol =>
      _firestore.collection('products');
  CollectionReference<Map<String, dynamic>> get _categoriesCol =>
      _firestore.collection('categories');

  // ── Dashboard İstatistikleri ──────────────────────────────
  Future<Map<String, dynamic>> getDashboardStats() async {
    final usersSnap = await _usersCol.get();
    final productsSnap = await _productsCol.get();

    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final todayStart = DateTime(now.year, now.month, now.day);

    int activeUsers = 0;
    int todayRegistrations = 0;
    for (final doc in usersSnap.docs) {
      final data = doc.data();
      final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate();
      final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
      if (updatedAt != null && updatedAt.isAfter(sevenDaysAgo)) activeUsers++;
      if (createdAt != null && createdAt.isAfter(todayStart)) todayRegistrations++;
    }

    // Kategori dağılımı
    final Map<String, int> categoryCount = {};
    for (final doc in productsSnap.docs) {
      final cat = doc.data()['category'] ?? 'other';
      categoryCount[cat] = (categoryCount[cat] ?? 0) + 1;
    }
    String topCategory = 'Yok';
    if (categoryCount.isNotEmpty) {
      final top = categoryCount.entries.reduce((a, b) => a.value > b.value ? a : b);
      topCategory = ProductCategory.fromString(top.key).displayName;
    }

    return {
      'totalUsers': usersSnap.size,
      'activeUsers': activeUsers,
      'totalProducts': productsSnap.size,
      'todayRegistrations': todayRegistrations,
      'topCategory': topCategory,
      'categoryDistribution': categoryCount,
    };
  }

  // ── Kullanıcı Yönetimi ────────────────────────────────────
  Future<List<UserModel>> getAllUsers() async {
    final snap = await _usersCol.orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => UserModel.fromFirestore(d)).toList();
  }

  Future<List<UserModel>> searchUsers(String query) async {
    final all = await getAllUsers();
    final q = query.toLowerCase();
    return all.where((u) =>
      u.email.toLowerCase().contains(q) ||
      u.displayName.toLowerCase().contains(q)
    ).toList();
  }

  Future<void> updateUserRole(String uid, String newRole) async {
    await _usersCol.doc(uid).update({
      'role': newRole,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> deleteUser(String uid) async {
    await _usersCol.doc(uid).delete();
  }

  // ── Ürün Yönetimi ────────────────────────────────────────
  Future<List<ProductModel>> getAllProducts() async {
    final snap = await _productsCol.orderBy('createdAt', descending: true).get();
    return snap.docs.map((d) => ProductModel.fromFirestore(d)).toList();
  }

  Future<void> deleteProduct(String productId) async {
    await _productsCol.doc(productId).delete();
  }

  Future<void> updateProductStatus(String productId, ProductStatus status) async {
    await _productsCol.doc(productId).update({
      'status': status.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ── Kategori Yönetimi ──────────────────────────────────────
  Future<List<ProductCategory>> getCategories() async {
    final snap = await _categoriesCol.get();
    if (snap.docs.isEmpty) {
      // Return default values if Firestore is empty
      return ProductCategory.values;
    }
    return snap.docs.map((d) => ProductCategory.fromMap(d.data(), d.id)).toList();
  }

  Future<void> addCategory(ProductCategory category) async {
    // If ID already exists, don't override unless intentional. Using set with merge or just set
    final doc = await _categoriesCol.doc(category.id).get();
    if (doc.exists) {
      throw Exception('Bu kategori IDsi zaten mevcut.');
    }
    await _categoriesCol.doc(category.id).set(category.toMap());
  }

  Future<void> updateCategory(ProductCategory category) async {
    await _categoriesCol.doc(category.id).update(category.toMap());
  }

  Future<void> deleteCategory(String categoryId) async {
    // Data integrity check: prevent deletion of categories associated with products
    final productsSnap = await _productsCol.where('category', isEqualTo: categoryId).limit(1).get();
    if (productsSnap.docs.isNotEmpty) {
      throw Exception('Kategoriyi silmeden önce Ürün olmadığından emin olunuz.');
    }
    await _categoriesCol.doc(categoryId).delete();
  }

  // ── Bildirim Sistemi ─────────────────────────────────────
  Future<void> sendNotification({
    required String title,
    required String body,
    String? targetRole,
  }) async {
    await _firestore.collection('notifications').add({
      'title': title,
      'body': body,
      'targetRole': targetRole,
      'createdAt': Timestamp.fromDate(DateTime.now()),
      'read': false,
    });
  }
}
