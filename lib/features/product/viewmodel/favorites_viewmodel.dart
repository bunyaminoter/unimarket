import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unimarket/models/product_model.dart';
import 'package:unimarket/features/product/repository/product_repository.dart';
import 'package:unimarket/features/product/model/product_category.dart';

class FavoritesViewModel extends ChangeNotifier {
  final ProductRepository _repository;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ProductModel> _favorites = [];
  Set<String> _favoriteIds = {};
  bool _isLoading = false;

  FavoritesViewModel({ProductRepository? repository})
    : _repository = repository ?? ProductRepository() {
    _loadFavoritesInitial();
  }

  List<ProductModel> get favorites => _favorites;
  Set<String> get favoriteIds => _favoriteIds;
  bool get isLoading => _isLoading;

  bool isFavorite(String productId) => _favoriteIds.contains(productId);

  Future<void> _loadFavoritesInitial() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await loadFavorites();
    }
  }

  Future<void> loadFavorites() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites')
          .get();
      _favoriteIds = snapshot.docs.map((d) => d.id).toSet();

      List<ProductModel> loadedFavs = [];
      for (var id in _favoriteIds) {
        final product = await _repository.getProduct(id);
        if (product != null && product.status == ProductStatus.active) {
          loadedFavs.add(product);
        }
      }
      _favorites = loadedFavs;
    } catch (e) {
      debugPrint("Favoriler yüklenirken hata: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(ProductModel product) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final isFav = isFavorite(product.id);
    final docRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(product.id);

    try {
      if (isFav) {
        // Çıkar
        await docRef.delete();
        _favoriteIds.remove(product.id);
        _favorites.removeWhere((p) => p.id == product.id);
        await _repository.updateFavoriteCount(product.id, false);
      } else {
        // Ekle
        await docRef.set({'addedAt': FieldValue.serverTimestamp()});
        _favoriteIds.add(product.id);
        _favorites.add(product);
        await _repository.updateFavoriteCount(product.id, true);
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Toggle favori hatası: $e");
    }
  }
}
