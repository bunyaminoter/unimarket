import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Sohbet Odası Modeli
class ChatModel extends Equatable {
  final String id;

  /// Sohbetteki kullanıcıların ID'leri
  final List<String> participants;

  /// İlgili ilan (opsiyonel, hangi ilan üzerinden mesajlaşıldığı bilinsin diye)
  final String? productId;
  final String lastMessage;
  final String lastSenderId;
  final DateTime updatedAt;

  /// Okunmamış mesaj sayısı vb eklenebilir

  const ChatModel({
    required this.id,
    required this.participants,
    this.productId,
    required this.lastMessage,
    required this.lastSenderId,
    required this.updatedAt,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      productId: data['productId'],
      lastMessage: data['lastMessage'] ?? '',
      lastSenderId: data['lastSenderId'] ?? '',
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participants': participants,
      if (productId != null) 'productId': productId,
      'lastMessage': lastMessage,
      'lastSenderId': lastSenderId,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  @override
  List<Object?> get props => [
    id,
    participants,
    productId,
    lastMessage,
    lastSenderId,
    updatedAt,
  ];
}

/// Mesaj Modeli
class MessageModel extends Equatable {
  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;

  const MessageModel({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      sentAt: (data['sentAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'text': text,
      'sentAt': Timestamp.fromDate(sentAt),
    };
  }

  @override
  List<Object?> get props => [id, senderId, text, sentAt];
}
