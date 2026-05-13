import 'package:equatable/equatable.dart';

/// Ürün Kategorileri
class ProductCategory extends Equatable {
  final String id;
  final String label;
  final String emoji;

  const ProductCategory({
    required this.id,
    required this.label,
    required this.emoji,
  });

  /// Görüntülenen metin (emoji + etiket).
  String get displayName => '$emoji $label';
  
  /// Geriye dönük uyumluluk için (enum name).
  String get name => id;

  static const ProductCategory other = ProductCategory(id: 'other', label: 'Diğer', emoji: '📦');

  static List<ProductCategory> values = [
    const ProductCategory(id: 'books', label: 'Kitaplar', emoji: '📚'),
    const ProductCategory(id: 'electronics', label: 'Elektronik', emoji: '💻'),
    const ProductCategory(id: 'clothing', label: 'Giyim', emoji: '👕'),
    const ProductCategory(id: 'homeGoods', label: 'Ev Eşyası', emoji: '🏠'),
    const ProductCategory(id: 'stationery', label: 'Kırtasiye', emoji: '📝'),
    const ProductCategory(id: 'hobby', label: 'Hobi', emoji: '🎮'),
    const ProductCategory(id: 'sports', label: 'Spor', emoji: '⚽'),
    const ProductCategory(id: 'deneme', label: 'Deneme', emoji: '😎'),
    other,
  ];

  /// Firestore'dan string ile eşleşme.
  static ProductCategory fromString(String value) {
    return values.firstWhere(
      (c) => c.id == value,
      orElse: () => other,
    );
  }

  factory ProductCategory.fromMap(Map<String, dynamic> data, String docId) {
    return ProductCategory(
      id: docId,
      label: data['label'] ?? '',
      emoji: data['emoji'] ?? '📦',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'label': label,
      'emoji': emoji,
    };
  }

  @override
  List<Object?> get props => [id, label, emoji];
}

/// Ürün Durumu (fiziksel kondisyon)
enum ProductCondition {
  brandNew('Sıfır'),
  likeNew('Çok İyi'),
  good('İyi'),
  fair('Orta');

  final String label;
  const ProductCondition(this.label);

  static ProductCondition fromString(String value) {
    return ProductCondition.values.firstWhere(
      (c) => c.name == value,
      orElse: () => ProductCondition.good,
    );
  }
}

/// Ürün Satış Durumu
enum ProductStatus {
  active('Aktif'),
  sold('Satıldı'),
  reserved('Rezerve');

  final String label;
  const ProductStatus(this.label);

  static ProductStatus fromString(String value) {
    return ProductStatus.values.firstWhere(
      (s) => s.name == value,
      orElse: () => ProductStatus.active,
    );
  }
}
