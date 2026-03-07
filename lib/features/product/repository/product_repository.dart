import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimarket/features/product/model/product_category.dart';
import 'package:unimarket/models/product_model.dart';

/// Product Repository
///
/// Firestore `products` koleksiyonu üzerinde CRUD işlemleri.
/// Filtreleme, sıralama ve sayfalama destekler.
class ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _productsCollection =>
      _firestore.collection('products');

  // ── Ürün Oluşturma ────────────────────────────────────────
  /// Yeni ürün oluşturur ve oluşturulan document ID'sini döndürür.
  Future<String> createProduct(ProductModel product) async {
    final docRef = await _productsCollection.add(product.toFirestore());
    return docRef.id;
  }

  // ── Ürün Okuma (Tekil) ────────────────────────────────────
  /// Belirli bir ürünü ID ile çeker.
  Future<ProductModel?> getProduct(String productId) async {
    final doc = await _productsCollection.doc(productId).get();
    if (!doc.exists) return null;
    return ProductModel.fromFirestore(doc);
  }

  /// Belirli bir ürünü gerçek zamanlı dinler.
  Stream<ProductModel?> watchProduct(String productId) {
    return _productsCollection.doc(productId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return ProductModel.fromFirestore(doc);
    });
  }

  // ── Ürün Listeleme ────────────────────────────────────────
  /// Aktif ürünleri en yeniden en eskiye sıralı şekilde çeker.
  /// Sayfalama için [limit] ve [lastDocument] parametreleri kullanılır.
  Future<List<ProductModel>> getProducts({
    int limit = 20,
    DocumentSnapshot? lastDocument,
    ProductCategory? category,
    String? sellerId,
  }) async {
    Query<Map<String, dynamic>> query = _productsCollection
        .where('status', isEqualTo: ProductStatus.active.name);

    // Kategori filtresi
    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }

    // Satıcı filtresi
    if (sellerId != null) {
      query = query.where('sellerId', isEqualTo: sellerId);
    }

    // Sayfalama (cursor-based)
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    query = query.limit(limit);

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();
  }

  /// Aktif ürünleri gerçek zamanlı stream olarak dinler.
  Stream<List<ProductModel>> watchProducts({
    int limit = 20,
    ProductCategory? category,
  }) {
    Query<Map<String, dynamic>> query = _productsCollection
        .where('status', isEqualTo: ProductStatus.active.name)
        .limit(limit);

    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Belirli bir kullanıcının ürünlerini çeker.
  Future<List<ProductModel>> getUserProducts(String userId) async {
    final snapshot = await _productsCollection
        .where('sellerId', isEqualTo: userId)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();
  }

  // ── Ürün Güncelleme ───────────────────────────────────────
  /// Ürünü günceller.
  Future<void> updateProduct(ProductModel product) async {
    final updatedProduct = product.copyWith(updatedAt: DateTime.now());
    await _productsCollection
        .doc(product.id)
        .update(updatedProduct.toFirestore());
  }

  /// Ürün durumunu günceller (aktif, satıldı, rezerve).
  Future<void> updateProductStatus(
      String productId, ProductStatus status) async {
    await _productsCollection.doc(productId).update({
      'status': status.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ── Ürün Silme ────────────────────────────────────────────
  Future<void> deleteProduct(String productId) async {
    await _productsCollection.doc(productId).delete();
  }

  // ── İstatistik Güncelleme ─────────────────────────────────
  /// Görüntülenme sayısını artırır.
  Future<void> incrementViewCount(String productId) async {
    await _productsCollection.doc(productId).update({
      'viewCount': FieldValue.increment(1),
    });
  }

  /// Favori sayısını artırır/azaltır.
  Future<void> updateFavoriteCount(String productId, bool increment) async {
    await _productsCollection.doc(productId).update({
      'favoriteCount': FieldValue.increment(increment ? 1 : -1),
    });
  }

  // ── Arama ─────────────────────────────────────────────────
  /// Başlığa göre ürün arar (basit prefix arama).
  Future<List<ProductModel>> searchProducts(String query) async {
    if (query.isEmpty) return [];

    final snapshot = await _productsCollection
        .where('status', isEqualTo: ProductStatus.active.name)
        .orderBy('title')
        .startAt([query])
        .endAt(['$query\uf8ff'])
        .limit(20)
        .get();

    return snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList();
  }
}
