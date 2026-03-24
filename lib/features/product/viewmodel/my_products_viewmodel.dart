import 'package:flutter/material.dart';
import 'package:unimarket/features/product/repository/product_repository.dart';
import 'package:unimarket/services/storage_service.dart';
import 'package:unimarket/models/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

class MyProductsViewModel extends ChangeNotifier {
  final ProductRepository _repository;
  final StorageService _storageService;

  List<ProductModel> _myProducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get myProducts => _myProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  MyProductsViewModel({
    ProductRepository? repository,
    StorageService? storageService,
  }) : _repository = repository ?? ProductRepository(),
       _storageService = storageService ?? StorageService();

  Future<void> loadMyProducts() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = 'Giriş yapılmamış.';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _myProducts = await _repository.getUserProducts(user.uid);

      // En yeni ilanlar en üstte olsun
      _myProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'İlanlar yüklenirken bir hata oluştu.';
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.deleteProduct(productId);
      _myProducts.removeWhere((p) => p.id == productId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'İlan silinirken hata oluştu.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProductDetails(
    ProductModel product, {
    File? newImageFile,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      ProductModel updatedProduct = product;

      // Resim güncellendiyse (veya eklendiyse) storage'a yükle
      if (newImageFile != null) {
        final List<String> imageUrls = await _storageService
            .uploadMultipleFiles(
              files: [newImageFile],
              basePath: 'products/${product.sellerId}',
            );

        if (imageUrls.isNotEmpty) {
          final updatedImages = List<String>.from(product.images);
          if (updatedImages.isNotEmpty) {
            updatedImages[0] = imageUrls.first; // Varolan ilk resmi güncelle
          } else {
            updatedImages.add(imageUrls.first); // Yoksa ekle
          }

          updatedProduct = product.copyWith(images: updatedImages);
        }
      }

      await _repository.updateProduct(updatedProduct);

      // Listeyi güncelle
      final index = _myProducts.indexWhere((p) => p.id == updatedProduct.id);
      if (index != -1) {
        _myProducts[index] = updatedProduct;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'İlan güncellenirken hata: $e';
      notifyListeners();
      return false;
    }
  }
}
