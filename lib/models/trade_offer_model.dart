import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Takas durumları
enum TradeStatus { pending, accepted, rejected, completed, cancelled }

extension TradeStatusExtension on TradeStatus {
  String get name => toString().split('.').last;

  static TradeStatus fromString(String status) {
    switch (status) {
      case 'accepted':
        return TradeStatus.accepted;
      case 'rejected':
        return TradeStatus.rejected;
      case 'completed':
        return TradeStatus.completed;
      case 'cancelled':
        return TradeStatus.cancelled;
      case 'pending':
      default:
        return TradeStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case TradeStatus.pending:
        return 'Beklemede';
      case TradeStatus.accepted:
        return 'Kabul Edildi';
      case TradeStatus.rejected:
        return 'Reddedildi';
      case TradeStatus.completed:
        return 'Tamamlandı';
      case TradeStatus.cancelled:
        return 'İptal Edildi';
    }
  }
}

/// Takas Teklifi Modeli (Trade Offer)
///
/// Bir kullanıcının kendi ürününü, başka bir kullanıcının ürünüyle takas etmek
/// için gönderdiği teklif objesini temsil eder.
class TradeOfferModel extends Equatable {
  final String id;
  // İstediğimiz (Karşı Tarafın) Ürünü
  final String targetProductId;
  final String targetUserId;
  // Teklif Ettiğimiz (Kendi) Ürünümüz
  final String offererId;
  final String offeredProductId;

  final String? message;
  final TradeStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TradeOfferModel({
    required this.id,
    required this.targetProductId,
    required this.targetUserId,
    required this.offererId,
    required this.offeredProductId,
    this.message,
    this.status = TradeStatus.pending,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TradeOfferModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TradeOfferModel(
      id: doc.id,
      targetProductId: data['targetProductId'] ?? '',
      targetUserId: data['targetUserId'] ?? '',
      offererId: data['offererId'] ?? '',
      offeredProductId: data['offeredProductId'] ?? '',
      message: data['message'],
      status: TradeStatusExtension.fromString(data['status'] ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'targetProductId': targetProductId,
      'targetUserId': targetUserId,
      'offererId': offererId,
      'offeredProductId': offeredProductId,
      'message': message,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  TradeOfferModel copyWith({
    String? id,
    String? targetProductId,
    String? targetUserId,
    String? offererId,
    String? offeredProductId,
    String? message,
    TradeStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TradeOfferModel(
      id: id ?? this.id,
      targetProductId: targetProductId ?? this.targetProductId,
      targetUserId: targetUserId ?? this.targetUserId,
      offererId: offererId ?? this.offererId,
      offeredProductId: offeredProductId ?? this.offeredProductId,
      message: message ?? this.message,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    targetProductId,
    targetUserId,
    offererId,
    offeredProductId,
    message,
    status,
    createdAt,
    updatedAt,
  ];
}
