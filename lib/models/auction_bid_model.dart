import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Açık Artırma Teklif Modeli
///
/// Firestore: `products/{productId}/bids/{bidId}`
class AuctionBidModel extends Equatable {
  final String bidId;
  final String bidderId;
  final String bidderName;
  final double amount;
  final DateTime createdAt;

  const AuctionBidModel({
    required this.bidId,
    required this.bidderId,
    required this.bidderName,
    required this.amount,
    required this.createdAt,
  });

  /// Firestore'dan AuctionBidModel oluşturur.
  factory AuctionBidModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuctionBidModel(
      bidId: doc.id,
      bidderId: data['bidderId'] ?? '',
      bidderName: data['bidderName'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Firestore-uyumlu Map'e çevirir.
  Map<String, dynamic> toFirestore() {
    return {
      'bidderId': bidderId,
      'bidderName': bidderName,
      'amount': amount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Fiyatı formatlanmış string olarak döndürür.
  String get formattedAmount =>
      '₺${amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2)}';

  @override
  List<Object?> get props => [bidId, bidderId, bidderName, amount, createdAt];

  @override
  String toString() =>
      'AuctionBidModel(bidId: $bidId, bidder: $bidderName, amount: $formattedAmount)';
}
