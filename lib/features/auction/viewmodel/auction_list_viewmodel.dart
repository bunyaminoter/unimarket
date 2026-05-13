import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:unimarket/features/product/model/product_category.dart';
import 'package:unimarket/models/product_model.dart';

/// Açık Artırma Listesi ViewModel
///
/// Sadece açık artırmadaki aktif ürünleri listeler.
class AuctionListViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  AuctionListViewModel({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  List<ProductModel> _auctionProducts = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get auctionProducts => _auctionProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAuctionProducts() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final snapshot = await _firestore
          .collection('products')
          .where('isAuction', isEqualTo: true)
          .where('status', isEqualTo: ProductStatus.active.name)
          .get();

      _auctionProducts = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      // En yeni olanlar en üstte
      _auctionProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Açık artırmalar yüklenirken hata oluştu.';
      notifyListeners();
    }
  }
}
