import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimarket/models/trade_offer_model.dart';
import 'package:unimarket/models/product_model.dart';

class TradeRepository {
  final FirebaseFirestore _firestore;

  TradeRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _offersCollection =>
      _firestore.collection('trade_offers');

  /// Yeni bir takas teklifi oluşturur
  Future<String> createTradeOffer(TradeOfferModel offer) async {
    final docRef = await _offersCollection.add(offer.toFirestore());
    return docRef.id;
  }

  /// Belirli bir kullanıcının kendi ürünlerinden hangilerini teklif edebileceğini çeker.
  Future<List<ProductModel>> getMyTradeEligibleProducts(String userId) async {
    // Sadece statüsü active ve isTradeEligible olanlar getirilir.
    final snapshot = await _firestore
        .collection('products')
        .where('sellerId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .where('isTradeEligible', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
  }

  /// Gelen Teklifleri Listeler (Kullanıcının Sahip Olduğu Ürünlere Yapılan Teklifler)
  Future<List<TradeOfferModel>> getIncomingOffers(String userId) async {
    final snapshot = await _offersCollection
        .where('targetUserId', isEqualTo: userId)
        .get();

    final docs = snapshot.docs
        .map((doc) => TradeOfferModel.fromFirestore(doc))
        .toList();
    docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return docs;
  }

  /// Gönderilen Teklifleri Listeler (Ben başkasına teklif)
  Future<List<TradeOfferModel>> getSentOffers(String userId) async {
    final snapshot = await _offersCollection
        .where('offererId', isEqualTo: userId)
        .get();

    final docs = snapshot.docs
        .map((doc) => TradeOfferModel.fromFirestore(doc))
        .toList();
    docs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return docs;
  }

  /// Teklif durumunu günceller (kabul / red / iptal)
  Future<void> updateOfferStatus(String offerId, TradeStatus status) async {
    await _offersCollection.doc(offerId).update({
      'status': status.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }
}
