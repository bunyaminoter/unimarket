import 'package:flutter/material.dart';
import 'package:unimarket/features/admin/repository/admin_repository.dart';
import 'package:unimarket/features/product/model/product_category.dart';
import 'package:unimarket/models/user_model.dart';
import 'package:unimarket/models/product_model.dart';

/// Admin Panel ViewModel
class AdminViewModel extends ChangeNotifier {
  final AdminRepository _repository;

  AdminViewModel({AdminRepository? repository})
    : _repository = repository ?? AdminRepository();

  // ── State ────────────────────────────────────────────────
  // Her sekme için ayrı loading flag'i
  bool _isDashboardLoading = false;
  bool _isUsersLoading = false;
  bool _isProductsLoading = false;
  bool _isCategoriesLoading = false;

  String? _errorMessage;
  Map<String, dynamic> _stats = {};
  List<UserModel> _users = [];
  List<ProductModel> _products = [];
  List<ProductCategory> _categories = [];
  int _selectedTabIndex = 0;

  // ── Getters ──────────────────────────────────────────────
  // Geriye dönük uyumluluk: herhangi biri yükleniyorsa true
  bool get isLoading => _isDashboardLoading || _isUsersLoading || _isProductsLoading || _isCategoriesLoading;

  bool get isDashboardLoading => _isDashboardLoading;
  bool get isUsersLoading => _isUsersLoading;
  bool get isProductsLoading => _isProductsLoading;
  bool get isCategoriesLoading => _isCategoriesLoading;

  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get stats => _stats;
  List<UserModel> get users => _users;
  List<ProductModel> get products => _products;
  List<ProductCategory> get categories => _categories;
  int get selectedTabIndex => _selectedTabIndex;

  void setTab(int index) {
    _selectedTabIndex = index;
    notifyListeners();
  }

  // ── Dashboard ────────────────────────────────────────────
  Future<void> loadDashboard() async {
    try {
      _isDashboardLoading = true;
      _errorMessage = null;
      notifyListeners();

      _stats = await _repository.getDashboardStats();

      _isDashboardLoading = false;
      notifyListeners();
    } catch (e) {
      _isDashboardLoading = false;
      _errorMessage = 'İstatistikler yüklenirken hata oluştu.';
      notifyListeners();
    }
  }

  // ── Kullanıcılar ─────────────────────────────────────────
  Future<void> loadUsers() async {
    try {
      _isUsersLoading = true;
      notifyListeners();

      _users = await _repository.getAllUsers();

      _isUsersLoading = false;
      notifyListeners();
    } catch (e) {
      _isUsersLoading = false;
      _errorMessage = 'Kullanıcılar yüklenirken hata oluştu.';
      notifyListeners();
    }
  }

  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      await loadUsers();
      return;
    }
    try {
      _users = await _repository.searchUsers(query);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Arama sırasında hata oluştu.';
      notifyListeners();
    }
  }

  Future<bool> updateUserRole(String uid, String newRole) async {
    try {
      await _repository.updateUserRole(uid, newRole);
      final index = _users.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _users[index] = _users[index].copyWith(role: newRole);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Rol güncellenirken hata oluştu.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String uid) async {
    try {
      await _repository.deleteUser(uid);
      _users.removeWhere((u) => u.uid == uid);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Kullanıcı silinirken hata oluştu.';
      notifyListeners();
      return false;
    }
  }

  // ── Ürünler ──────────────────────────────────────────────
  Future<void> loadProducts() async {
    try {
      _isProductsLoading = true;
      notifyListeners();

      _products = await _repository.getAllProducts();

      _isProductsLoading = false;
      notifyListeners();
    } catch (e) {
      _isProductsLoading = false;
      _errorMessage = 'Ürünler yüklenirken hata oluştu.';
      notifyListeners();
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _repository.deleteProduct(productId);
      _products.removeWhere((p) => p.id == productId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Ürün silinirken hata oluştu.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProductStatus(String productId, ProductStatus status) async {
    try {
      await _repository.updateProductStatus(productId, status);
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = _products[index].copyWith(status: status);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Ürün durumu güncellenirken hata oluştu.';
      notifyListeners();
      return false;
    }
  }

  // Kategori yönetimi silindiği için eski metotlar kaldırıldı.

  // ── Bildirim ─────────────────────────────────────────────
  Future<bool> sendNotification({
    required String title,
    required String body,
    String? targetRole,
  }) async {
    try {
      await _repository.sendNotification(
        title: title,
        body: body,
        targetRole: targetRole,
      );
      return true;
    } catch (e) {
      _errorMessage = 'Bildirim gönderilirken hata oluştu.';
      notifyListeners();
      return false;
    }
  }
}
