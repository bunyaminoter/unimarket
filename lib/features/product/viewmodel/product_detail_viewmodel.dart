import 'package:flutter/material.dart';
import 'package:unimarket/models/product_model.dart';
import 'package:unimarket/features/product/repository/product_repository.dart';

class ProductDetailViewModel extends ChangeNotifier {
  final ProductRepository _repository;

  ProductDetailViewModel({ProductRepository? repository})
    : _repository = repository ?? ProductRepository();

  ProductModel? _product;
  bool _isLoading = false;
  String? _errorMessage;

  // Initializing with an existing model from the list ensures instantaneous display
  void initProduct(ProductModel product) {
    _product = product;
    notifyListeners();
    // Arkaplanda Görüntülenme (View) Sayısını Artır
    _incrementViewCount(product.id);
  }

  ProductModel? get product => _product;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Ürün detaylarını güncel haliyle Firestore'dan çek (Örn: satıldı mı vs)
  Future<void> loadProductDetails(String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final freshProduct = await _repository.getProduct(productId);
      if (freshProduct != null) {
        _product = freshProduct;
      }
    } catch (e) {
      _errorMessage = 'Ürün detayları yüklenemedi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _incrementViewCount(String productId) async {
    try {
      await _repository.incrementViewCount(productId);
      // Local state'i de 1 arttıralım
      if (_product != null && _product!.id == productId) {
        _product = _product!.copyWith(viewCount: _product!.viewCount + 1);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Görüntülenme stat artırılamadı: $e');
    }
  }

  /// Favoriye (kaydedilenlere) ekle çıkar
  Future<void> toggleFavorite() async {
    if (_product == null) return;
    try {
      // Normalde User'ın kendi favori listesinde de tutulmalı (Faz kısıtlamasına göre opsiyonel)
      // Şimdilik sadece sayacı 1 arttır/azalt simülasyonu yapıyoruz
      await _repository.updateFavoriteCount(_product!.id, true);
      _product = _product!.copyWith(favoriteCount: _product!.favoriteCount + 1);
      notifyListeners();
    } catch (e) {
      debugPrint('Favori eklenemedi: $e');
    }
  }
}
