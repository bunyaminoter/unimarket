import 'package:flutter/material.dart';
import 'package:unimarket/features/product/model/product_category.dart';
import 'package:unimarket/features/product/repository/product_repository.dart';
import 'package:unimarket/models/product_model.dart';

/// Home ViewModel
///
/// Ana sayfadaki ürün listeleme, kategori filtreleme ve yenileme
/// işlemlerini yönetir.
class HomeViewModel extends ChangeNotifier {
  final ProductRepository _repository;

  HomeViewModel({ProductRepository? repository})
      : _repository = repository ?? ProductRepository();

  // ── State ────────────────────────────────────────────────
  List<ProductModel> _products = [];
  ProductCategory? _selectedCategory;
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;

  // ── Getters ──────────────────────────────────────────────
  List<ProductModel> get products => _products;
  ProductCategory? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  bool get hasProducts => _products.isNotEmpty;

  // ── Ürünleri Yükle ────────────────────────────────────────
  /// İlk yükleme veya kategori değişikliğinde çağrılır.
  Future<void> loadProducts() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _products = await _repository.getProducts(
        category: _selectedCategory,
        limit: 20,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Ürünler yüklenirken hata oluştu.';
      notifyListeners();
    }
  }

  /// Pull-to-refresh ile yenileme.
  Future<void> refreshProducts() async {
    try {
      _isRefreshing = true;
      notifyListeners();

      _products = await _repository.getProducts(
        category: _selectedCategory,
        limit: 20,
      );

      _isRefreshing = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _isRefreshing = false;
      _errorMessage = 'Yenilenirken hata oluştu.';
      notifyListeners();
    }
  }

  // ── Kategori Filtreleme ───────────────────────────────────
  /// Kategori seçer ve ürünleri yeniden yükler.
  void selectCategory(ProductCategory? category) {
    // Aynı kategoriye tıklanırsa filtreyi kaldır
    if (_selectedCategory == category) {
      _selectedCategory = null;
    } else {
      _selectedCategory = category;
    }
    notifyListeners();
    loadProducts();
  }

  // ── Hata Temizleme ────────────────────────────────────────
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
