import 'dart:io';
import 'package:flutter/material.dart';
import 'package:unimarket/features/product/model/product_category.dart';
import 'package:unimarket/features/product/repository/product_repository.dart';
import 'package:unimarket/models/product_model.dart';
import 'package:unimarket/services/storage_service.dart';
import 'package:unimarket/services/price_suggestion_service.dart';

/// Add Product ViewModel
///
/// Ürün ekleme formunun state yönetimini sağlar.
/// Fotoğraf seçimi, form validasyonu ve Firestore'a kayıt işlemlerini yönetir.
class AddProductViewModel extends ChangeNotifier {
  final ProductRepository _repository;
  final StorageService _storageService;
  final PriceSuggestionService _priceSuggestionService;

  AddProductViewModel({
    ProductRepository? repository,
    StorageService? storageService,
    PriceSuggestionService? priceSuggestionService,
  })  : _repository = repository ?? ProductRepository(),
        _storageService = storageService ?? StorageService(),
        _priceSuggestionService = priceSuggestionService ?? PriceSuggestionService();

  // ── State ────────────────────────────────────────────────
  List<File> _selectedImages = [];
  ProductCategory _selectedCategory = ProductCategory.other;
  ProductCondition _selectedCondition = ProductCondition.good;
  bool _isTradeEligible = false;
  bool _isLoading = false;
  double _uploadProgress = 0.0;
  String? _errorMessage;

  // Fiyat Önerisi State
  bool _isSuggestingPrice = false;
  double? _suggestedPrice;
  String? _suggestedPriceError;

  // ── Getters ──────────────────────────────────────────────
  List<File> get selectedImages => _selectedImages;
  ProductCategory get selectedCategory => _selectedCategory;
  ProductCondition get selectedCondition => _selectedCondition;
  bool get isTradeEligible => _isTradeEligible;
  bool get isLoading => _isLoading;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;
  bool get hasImages => _selectedImages.isNotEmpty;
  int get maxImages => 5;
  bool get canAddMoreImages => _selectedImages.length < maxImages;

  bool get isSuggestingPrice => _isSuggestingPrice;
  double? get suggestedPrice => _suggestedPrice;
  String? get suggestedPriceError => _suggestedPriceError;

  // ── Fotoğraf Yönetimi ────────────────────────────────────
  void addImage(File image) {
    if (_selectedImages.length >= maxImages) return;
    _selectedImages = [..._selectedImages, image];
    notifyListeners();
  }

  void addImages(List<File> images) {
    final remaining = maxImages - _selectedImages.length;
    final toAdd = images.take(remaining).toList();
    _selectedImages = [..._selectedImages, ...toAdd];
    notifyListeners();
  }

  void removeImage(int index) {
    if (index >= 0 && index < _selectedImages.length) {
      _selectedImages = List.from(_selectedImages)..removeAt(index);
      notifyListeners();
    }
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final images = List<File>.from(_selectedImages);
    final item = images.removeAt(oldIndex);
    images.insert(newIndex, item);
    _selectedImages = images;
    notifyListeners();
  }

  // ── Kategori & Durum ──────────────────────────────────────
  void setCategory(ProductCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setCondition(ProductCondition condition) {
    _selectedCondition = condition;
    notifyListeners();
  }

  void setTradeEligible(bool value) {
    _isTradeEligible = value;
    notifyListeners();
  }

  // ── Fiyat Önerisi ─────────────────────────────────────────
  Future<void> fetchSuggestedPrice(String title) async {
    if (title.trim().length < 3) return;

    _isSuggestingPrice = true;
    _suggestedPriceError = null;
    _suggestedPrice = null;
    notifyListeners();

    try {
      final price = await _priceSuggestionService.fetchSuggestedPrice(title);
      _suggestedPrice = price; // null da olabilir (bulunamadı)
      if (price == null) {
        _suggestedPriceError = 'Bu ürün için piyasa fiyatı bulunamadı.';
      }
    } catch (e) {
      _suggestedPriceError = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isSuggestingPrice = false;
      notifyListeners();
    }
  }

  // ── Ürün Kaydetme ─────────────────────────────────────────
  /// Ürünü oluşturur: fotoğrafları Storage'a yükler, ardından Firestore'a kaydeder.
  Future<bool> saveProduct({
    required String title,
    required String description,
    required double price,
    required String sellerId,
    required String sellerName,
    String? sellerPhotoUrl,
    String? tradeDescription,
    String? location,
  }) async {
    try {
      _isLoading = true;
      _uploadProgress = 0.0;
      _errorMessage = null;
      notifyListeners();

      // 1. Fotoğrafları Firebase Storage'a yükle
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        imageUrls = await _storageService.uploadMultipleFiles(
          files: _selectedImages,
          basePath: 'products/$sellerId',
          onProgress: (progress) {
            _uploadProgress = progress;
            notifyListeners();
          },
        );
      }

      // 2. Firestore'a ürün bilgilerini kaydet
      final now = DateTime.now();
      final product = ProductModel(
        id: '', // Firestore otomatik ID oluşturacak
        title: title.trim(),
        description: description.trim(),
        price: price,
        category: _selectedCategory,
        condition: _selectedCondition,
        images: imageUrls,
        sellerId: sellerId,
        sellerName: sellerName,
        sellerPhotoUrl: sellerPhotoUrl,
        isTradeEligible: _isTradeEligible,
        tradeDescription: tradeDescription?.trim(),
        location: location?.trim(),
        createdAt: now,
        updatedAt: now,
      );

      await _repository.createProduct(product);

      _isLoading = false;
      _uploadProgress = 1.0;
      notifyListeners();

      // Formu sıfırla
      resetForm();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Ürün kaydedilirken hata oluştu: ${e.toString().replaceAll("Exception: ", "")}';
      notifyListeners();
      return false;
    }
  }

  // ── Form Sıfırlama ────────────────────────────────────────
  void resetForm() {
    _selectedImages = [];
    _selectedCategory = ProductCategory.other;
    _selectedCondition = ProductCondition.good;
    _isTradeEligible = false;
    _uploadProgress = 0.0;
    _errorMessage = null;
    _suggestedPrice = null;
    _suggestedPriceError = null;
    _isSuggestingPrice = false;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
