import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:unimarket/features/product/model/product_category.dart';

/// UniMarket Ürün Modeli
///
/// Firestore `products` koleksiyonuna karşılık gelir.
///
/// Firestore Yapısı:
/// ```
/// products/{productId}
///   ├── title: string
///   ├── description: string
///   ├── price: double
///   ├── category: string (enum name)
///   ├── condition: string (enum name)
///   ├── images: [string] (Firebase Storage URL'leri)
///   ├── sellerId: string
///   ├── sellerName: string
///   ├── sellerPhotoUrl: string?
///   ├── isTradeEligible: bool
///   ├── tradeDescription: string?
///   ├── location: string?
///   ├── status: string (active/sold/reserved)
///   ├── viewCount: int
///   ├── favoriteCount: int
///   ├── createdAt: timestamp
///   └── updatedAt: timestamp
/// ```
class ProductModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final double price;
  final ProductCategory category;
  final ProductCondition condition;
  final List<String> images;
  final String sellerId;
  final String sellerName;
  final String? sellerPhotoUrl;
  final bool isTradeEligible;
  final String? tradeDescription;
  final String? location;
  final ProductStatus status;
  final int viewCount;
  final int favoriteCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.condition = ProductCondition.good,
    required this.images,
    required this.sellerId,
    required this.sellerName,
    this.sellerPhotoUrl,
    this.isTradeEligible = false,
    this.tradeDescription,
    this.location,
    this.status = ProductStatus.active,
    this.viewCount = 0,
    this.favoriteCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Map üzerinden model oluşturur (Hive/Lokal Cache kullanımı için)
  factory ProductModel.fromMap(Map<String, dynamic> data, String docId) {
    return ProductModel(
      id: docId,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      category: ProductCategory.fromString(data['category'] ?? 'other'),
      condition: ProductCondition.fromString(data['condition'] ?? 'good'),
      images: List<String>.from(data['images'] ?? []),
      sellerId: data['sellerId'] ?? '',
      sellerName: data['sellerName'] ?? '',
      sellerPhotoUrl: data['sellerPhotoUrl'],
      isTradeEligible: data['isTradeEligible'] ?? false,
      tradeDescription: data['tradeDescription'],
      location: data['location'],
      status: ProductStatus.fromString(data['status'] ?? 'active'),
      viewCount: data['viewCount'] ?? 0,
      favoriteCount: data['favoriteCount'] ?? 0,
      createdAt: data['createdAt'] is String 
        ? DateTime.parse(data['createdAt']) 
        : (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt'] is String 
        ? DateTime.parse(data['updatedAt']) 
        : (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Firestore'dan ProductModel oluşturur.
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ProductModel.fromMap(data, doc.id);
  }

  /// Lokal depo (Hive) için JSON nesnesi oluşturur
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category.name,
      'condition': condition.name,
      'images': images,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhotoUrl': sellerPhotoUrl,
      'isTradeEligible': isTradeEligible,
      'tradeDescription': tradeDescription,
      'location': location,
      'status': status.name,
      'viewCount': viewCount,
      'favoriteCount': favoriteCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Firestore-uyumlu Map'e çevirir.
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'category': category.name,
      'condition': condition.name,
      'images': images,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerPhotoUrl': sellerPhotoUrl,
      'isTradeEligible': isTradeEligible,
      'tradeDescription': tradeDescription,
      'location': location,
      'status': status.name,
      'viewCount': viewCount,
      'favoriteCount': favoriteCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Belirli alanları güncellenmiş yeni kopya.
  ProductModel copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    ProductCategory? category,
    ProductCondition? condition,
    List<String>? images,
    String? sellerId,
    String? sellerName,
    String? sellerPhotoUrl,
    bool? isTradeEligible,
    String? tradeDescription,
    String? location,
    ProductStatus? status,
    int? viewCount,
    int? favoriteCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      condition: condition ?? this.condition,
      images: images ?? this.images,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerPhotoUrl: sellerPhotoUrl ?? this.sellerPhotoUrl,
      isTradeEligible: isTradeEligible ?? this.isTradeEligible,
      tradeDescription: tradeDescription ?? this.tradeDescription,
      location: location ?? this.location,
      status: status ?? this.status,
      viewCount: viewCount ?? this.viewCount,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Fiyatı formatlanmış string olarak döndürür.
  String get formattedPrice => '₺${price.toStringAsFixed(price.truncateToDouble() == price ? 0 : 2)}';

  /// İlk fotoğrafı döndürür (yoksa null).
  String? get primaryImage => images.isNotEmpty ? images.first : null;

  /// Ürünün aktif olup olmadığını kontrol eder.
  bool get isActive => status == ProductStatus.active;

  @override
  List<Object?> get props => [
        id, title, description, price, category, condition,
        images, sellerId, sellerName, sellerPhotoUrl,
        isTradeEligible, tradeDescription, location, status,
        viewCount, favoriteCount, createdAt, updatedAt,
      ];

  @override
  String toString() => 'ProductModel(id: $id, title: $title, price: $formattedPrice)';
}
