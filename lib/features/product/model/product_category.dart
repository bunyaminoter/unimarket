/// Ürün Kategorileri
enum ProductCategory {
  books('Kitaplar', '📚'),
  electronics('Elektronik', '💻'),
  clothing('Giyim', '👕'),
  homeGoods('Ev Eşyası', '🏠'),
  stationery('Kırtasiye', '📝'),
  hobby('Hobi', '🎮'),
  sports('Spor', '⚽'),
  other('Diğer', '📦');

  final String label;
  final String emoji;
  const ProductCategory(this.label, this.emoji);

  /// Görüntülenen metin (emoji + etiket).
  String get displayName => '$emoji $label';

  /// Firestore'dan string ile eşleşme.
  static ProductCategory fromString(String value) {
    return ProductCategory.values.firstWhere(
      (c) => c.name == value,
      orElse: () => ProductCategory.other,
    );
  }
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
