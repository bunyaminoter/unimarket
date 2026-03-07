import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unimarket/models/product_model.dart';
import 'package:unimarket/features/product/model/product_category.dart';

/// Hive üzerinden lokal önbellekleme (Caching) servisi.
/// 
/// Offline-first deneyimi sunmak için ürünleri uygulama 
/// içine kaydeder ve internet olmasa bile anında yüklenmesini sağlar.
class HiveService {
  static const String _productsBoxName = 'products_box';

  /// Hive'ı başlatır ve gerekli kutuları açar. (main.dart'ta çağrılmalıdır)
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_productsBoxName);
  }

  /// Ürünleri lokal veritabanına (caching) kaydeder.
  static Future<void> cacheProducts(List<ProductModel> products, {ProductCategory? category}) async {
    try {
      final box = Hive.box(_productsBoxName);
      // Kategoriye özel anahtar oluştur (Örn: products_all, products_books)
      final key = category != null ? 'products_${category.name}' : 'products_all';
      
      final jsonList = products.map((p) => p.toJson()).toList();
      await box.put(key, jsonEncode(jsonList));
    } catch (e) {
      debugPrint('Hive cache error: $e');
    }
  }

  /// Lokalden verileri okur (Önceden önbelleklenmiş ürünleri getirir).
  static List<ProductModel> getCachedProducts({ProductCategory? category}) {
    try {
      final box = Hive.box(_productsBoxName);
      final key = category != null ? 'products_${category.name}' : 'products_all';
      
      final String? jsonString = box.get(key);
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((map) {
          final data = map as Map<String, dynamic>;
          final id = data['id'] ?? '';
          return ProductModel.fromMap(data, id);
        }).toList();
      }
    } catch (e) {
      debugPrint('Hive read error: $e');
    }
    return [];
  }
}
