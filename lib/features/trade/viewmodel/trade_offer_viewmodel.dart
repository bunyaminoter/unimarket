import 'package:flutter/material.dart';
import 'package:unimarket/models/product_model.dart';
import 'package:unimarket/models/trade_offer_model.dart';
import 'package:unimarket/features/trade/repository/trade_repository.dart';

class TradeOfferViewModel extends ChangeNotifier {
  final TradeRepository _repository;

  TradeOfferViewModel({TradeRepository? repository})
    : _repository = repository ?? TradeRepository();

  bool _isLoading = false;
  String? _errorMessage;
  List<ProductModel> _myEligibleProducts = [];
  ProductModel? _selectedProduct;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<ProductModel> get myEligibleProducts => _myEligibleProducts;
  ProductModel? get selectedProduct => _selectedProduct;

  /// Kullanıcının takas edebileceği (Aktif ve isTradeEligible==true) ilanlarını getir
  Future<void> fetchMyEligibleProducts(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myEligibleProducts = await _repository.getMyTradeEligibleProducts(
        userId,
      );
    } catch (e) {
      _errorMessage = 'Takas edilebilir ürünleriniz yüklenemedi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectProduct(ProductModel product) {
    if (_selectedProduct == product) {
      _selectedProduct = null;
    } else {
      _selectedProduct = product;
    }
    notifyListeners();
  }

  /// Takas Teklifini Gönder
  Future<bool> sendTradeOffer({
    required String offererId,
    required ProductModel targetProduct,
    String? message,
  }) async {
    if (_selectedProduct == null) {
      _errorMessage = 'Lütfen kendi ilanlarınızdan birini seçin!';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final now = DateTime.now();
      final offer = TradeOfferModel(
        id: '', // Firestore oluşturacak
        targetProductId: targetProduct.id,
        targetUserId: targetProduct.sellerId,
        offererId: offererId,
        offeredProductId: _selectedProduct!.id,
        message: message?.trim(),
        status: TradeStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      await _repository.createTradeOffer(offer);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Teklif gönderilirken hata oluştu: $e';
      notifyListeners();
      return false;
    }
  }
}
