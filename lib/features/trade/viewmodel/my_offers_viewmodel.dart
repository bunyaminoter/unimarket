import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimarket/models/trade_offer_model.dart';
import 'package:unimarket/models/product_model.dart';
import 'package:unimarket/features/trade/repository/trade_repository.dart';
import 'package:unimarket/features/product/repository/product_repository.dart';

/// Her teklifi ürün bilgileriyle zenginleştiren wrapper
class TradeOfferWithProducts {
  final TradeOfferModel offer;
  final ProductModel? offeredProduct; // Teklif edilen ürün
  final ProductModel? targetProduct;  // Hedeflenen ürün

  const TradeOfferWithProducts({
    required this.offer,
    this.offeredProduct,
    this.targetProduct,
  });
}

class MyOffersViewModel extends ChangeNotifier {
  final TradeRepository _tradeRepo;
  final ProductRepository _productRepo;

  MyOffersViewModel({
    TradeRepository? tradeRepo,
    ProductRepository? productRepo,
  })  : _tradeRepo = tradeRepo ?? TradeRepository(),
        _productRepo = productRepo ?? ProductRepository();

  List<TradeOfferWithProducts> _incomingOffers = [];
  List<TradeOfferWithProducts> _sentOffers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TradeOfferWithProducts> get incomingOffers => _incomingOffers;
  List<TradeOfferWithProducts> get sentOffers => _sentOffers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadOffers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final incoming = await _tradeRepo.getIncomingOffers(user.uid);
      final sent = await _tradeRepo.getSentOffers(user.uid);

      _incomingOffers = await _enrichOffers(incoming);
      _sentOffers = await _enrichOffers(sent);
    } catch (e) {
      _errorMessage = 'Teklifler yüklenemedi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Offer listesini ürün bilgileriyle zenginleştirir
  Future<List<TradeOfferWithProducts>> _enrichOffers(
      List<TradeOfferModel> offers) async {
    final List<TradeOfferWithProducts> enriched = [];

    for (final offer in offers) {
      ProductModel? offeredProduct;
      ProductModel? targetProduct;

      try {
        offeredProduct = await _productRepo.getProduct(offer.offeredProductId);
      } catch (_) {}
      try {
        targetProduct = await _productRepo.getProduct(offer.targetProductId);
      } catch (_) {}

      enriched.add(TradeOfferWithProducts(
        offer: offer,
        offeredProduct: offeredProduct,
        targetProduct: targetProduct,
      ));
    }
    return enriched;
  }

  /// Teklifi kabul et
  Future<bool> acceptOffer(String offerId) async {
    try {
      await _tradeRepo.updateOfferStatus(offerId, TradeStatus.accepted);
      await loadOffers();
      return true;
    } catch (e) {
      _errorMessage = 'Teklif kabul edilemedi: $e';
      notifyListeners();
      return false;
    }
  }

  /// Teklifi reddet
  Future<bool> rejectOffer(String offerId) async {
    try {
      await _tradeRepo.updateOfferStatus(offerId, TradeStatus.rejected);
      await loadOffers();
      return true;
    } catch (e) {
      _errorMessage = 'Teklif reddedilemedi: $e';
      notifyListeners();
      return false;
    }
  }

  /// Gönderdiğim teklifi iptal et
  Future<bool> cancelOffer(String offerId) async {
    try {
      await _tradeRepo.updateOfferStatus(offerId, TradeStatus.cancelled);
      await loadOffers();
      return true;
    } catch (e) {
      _errorMessage = 'Teklif iptal edilemedi: $e';
      notifyListeners();
      return false;
    }
  }
}
