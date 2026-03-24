import 'dart:async';
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
  bool _showOnlyTradeable = false;
  String _searchQuery = '';
  String? _errorMessage;

  // ── Getters ──────────────────────────────────────────────
  List<ProductModel> get products {
    if (_searchQuery.isEmpty) return _products;
    return _products
        .where(
          (p) => p.title.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  ProductCategory? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  bool get isRefreshing => _isRefreshing;
  String? get errorMessage => _errorMessage;
  bool get hasProducts => products.isNotEmpty;
  bool get showOnlyTradeable => _showOnlyTradeable;
  String get searchQuery => _searchQuery;

  StreamSubscription<List<ProductModel>>? _productsSubscription;

  @override
  void dispose() {
    _productsSubscription?.cancel();
    super.dispose();
  }

  // ── Ürünleri Yükle ────────────────────────────────────────
  /// İlk yükleme veya kategori değişikliğinde çağrılır. (Offline-First)
  void loadProducts() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _productsSubscription?.cancel();
    _productsSubscription = _repository
        .getProductsOfflineFirst(
          category: _selectedCategory,
          isTradeEligible: _showOnlyTradeable ? true : null,
          limit: 20,
        )
        .listen(
          (productList) {
            _products = productList;
            _isLoading = false;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            _errorMessage = 'Ürünler yüklenirken hata oluştu.';
            notifyListeners();
          },
        );
  }

  /// Pull-to-refresh ile yenileme.
  Future<void> refreshProducts() async {
    try {
      _isRefreshing = true;
      notifyListeners();

      // Refresh anında sadece internetten çeker (doğrudan getProducts)
      _products = await _repository.getProducts(
        category: _selectedCategory,
        isTradeEligible: _showOnlyTradeable ? true : null,
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

  // ── Takas Filtreleme ──────────────────────────────────────
  /// Takasa açık ürünleri filtreleme modunu açar / kapatır
  void toggleTradeableFilter() {
    _showOnlyTradeable = !_showOnlyTradeable;
    notifyListeners();
    loadProducts();
  }

  // ── Arama ─────────────────────────────────────────────────
  /// Ürün ismine göre arama yapar.
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // ── Hata Temizleme ────────────────────────────────────────
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
