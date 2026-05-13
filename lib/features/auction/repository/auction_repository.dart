import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:unimarket/features/product/model/product_category.dart';
import 'package:unimarket/models/auction_bid_model.dart';

/// Auction Repository
///
/// Açık artırma işlemlerini yönetir.
/// Teklif verme, teklifleri listeleme ve açık artırma sonlandırma.
class AuctionRepository {
  final FirebaseFirestore _firestore;

  AuctionRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _productsCollection =>
      _firestore.collection('products');

  /// Ürünün bids alt koleksiyonuna referans.
  CollectionReference<Map<String, dynamic>> _bidsCollection(String productId) =>
      _productsCollection.doc(productId).collection('bids');

  // ── Teklif Verme (Transaction ile Atomik) ────────────────
  /// Yeni teklif verir. Transaction kullanarak yarış koşullarını önler.
  /// Teklifin mevcut en yüksek tekliften büyük olmasını garanti eder.
  Future<void> placeBid({
    required String productId,
    required String bidderId,
    required String bidderName,
    required double amount,
  }) async {
    await _firestore.runTransaction((transaction) async {
      final productDoc = _productsCollection.doc(productId);
      final productSnapshot = await transaction.get(productDoc);

      if (!productSnapshot.exists) {
        throw Exception('Ürün bulunamadı.');
      }

      final productData = productSnapshot.data()!;

      // Açık artırma kontrolü
      final isAuction = productData['isAuction'] ?? false;
      if (!isAuction) {
        throw Exception('Bu ürün açık artırmada değil.');
      }

      // Süre kontrolü
      final auctionEndTime =
          (productData['auctionEndTime'] as Timestamp?)?.toDate();
      if (auctionEndTime == null || DateTime.now().isAfter(auctionEndTime)) {
        throw Exception('Açık artırma süresi dolmuş.');
      }

      // Satıcının kendi ürününe teklif vermesini engelle
      final sellerId = productData['sellerId'] ?? '';
      if (sellerId == bidderId) {
        throw Exception('Kendi ürününüze teklif veremezsiniz.');
      }

      // Minimum teklif kontrolü
      final currentHighest =
          (productData['highestBid'] as num?)?.toDouble() ??
          (productData['price'] as num).toDouble();
      final basePrice = (productData['price'] as num).toDouble();

      // İlk teklif taban fiyatına eşit veya büyük olmalı
      // Sonraki teklifler mevcut en yüksekten büyük olmalı
      final hasExistingBid = productData['highestBid'] != null;
      final minAmount = hasExistingBid ? currentHighest + 1 : basePrice;

      if (amount < minAmount) {
        throw Exception(
          'Teklif en az ₺${minAmount.toStringAsFixed(0)} olmalıdır.',
        );
      }

      // Bids koleksiyonuna ekle
      final bidDoc = _bidsCollection(productId).doc();
      transaction.set(bidDoc, {
        'bidderId': bidderId,
        'bidderName': bidderName,
        'amount': amount,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });

      // Product dökümanını güncelle
      transaction.update(productDoc, {
        'highestBid': amount,
        'highestBidderId': bidderId,
        'highestBidderName': bidderName,
        'bidCount': FieldValue.increment(1),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    });
  }

  // ── Teklifleri Listeleme ──────────────────────────────────
  /// Bir ürünün tüm tekliflerini en yüksekten düşüğe sıralar.
  Future<List<AuctionBidModel>> getBids(String productId) async {
    final snapshot = await _bidsCollection(productId)
        .orderBy('amount', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => AuctionBidModel.fromFirestore(doc))
        .toList();
  }

  /// Teklifleri gerçek zamanlı dinler.
  Stream<List<AuctionBidModel>> watchBids(String productId) {
    return _bidsCollection(productId)
        .orderBy('amount', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AuctionBidModel.fromFirestore(doc))
              .toList();
        });
  }

  // ── Açık Artırma Sonlandırma ──────────────────────────────
  /// Süresi dolan açık artırmayı sonlandırır.
  /// Teklif varsa → ürünü 'sold' olarak işaretler.
  /// Teklif yoksa → auctionEnded: true, normal satışa devam.
  Future<void> finalizeAuction(String productId) async {
    try {
      final productDoc =
          await _productsCollection.doc(productId).get();
      if (!productDoc.exists) return;

      final data = productDoc.data()!;
      final highestBid = (data['highestBid'] as num?)?.toDouble();
      final bidCount = data['bidCount'] ?? 0;

      if (bidCount > 0 && highestBid != null) {
        // Teklif gelmiş → satıldı olarak işaretle
        await _productsCollection.doc(productId).update({
          'status': ProductStatus.sold.name,
          'auctionEnded': true,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      } else {
        // Teklif gelmemiş → normal satışa devam
        await _productsCollection.doc(productId).update({
          'auctionEnded': true,
          'updatedAt': Timestamp.fromDate(DateTime.now()),
        });
      }
    } catch (e) {
      debugPrint('Açık artırma sonlandırma hatası: $e');
    }
  }

  // ── Süresi Dolan Açık Artırmaları Toplu Kontrol ───────────
  /// Süresi dolmuş ama henüz sonlandırılmamış açık artırmaları bulur.
  Future<void> checkAndFinalizeExpiredAuctions() async {
    try {
      final snapshot = await _productsCollection
          .where('isAuction', isEqualTo: true)
          .where('auctionEnded', isEqualTo: false)
          .where('status', isEqualTo: ProductStatus.active.name)
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final auctionEndTime =
            (data['auctionEndTime'] as Timestamp?)?.toDate();
        if (auctionEndTime != null && DateTime.now().isAfter(auctionEndTime)) {
          await finalizeAuction(doc.id);
        }
      }
    } catch (e) {
      debugPrint('Süresi dolan açık artırma kontrolü hatası: $e');
    }
  }
}
