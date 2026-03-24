import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimarket/models/chat_model.dart';
import 'package:unimarket/services/crypto_service.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _chatsCollection =>
      _firestore.collection('chats');

  /// İki kullanıcı arasında önceden var olan sohbet odasını veya varsa ürün için
  /// olan odayı getir. Yoksa null döner.
  Future<String?> findExistingChat(
    String currentUserId,
    String targetUserId, {
    String? productId,
  }) async {
    // Sadece currentUserId'nin olduğu odaları al (index gerektirmez, client-side filtreleme yapalım)
    final snapshot = await _chatsCollection
        .where('participants', arrayContains: currentUserId)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final participants = List<String>.from(data['participants'] ?? []);
      if (participants.contains(targetUserId)) {
        // Eğer ürüne özel sohbeti de daraltmak istiyorsan:
        if (productId != null) {
          if (data['productId'] == productId) {
            return doc
                .id; // İki kullanıcının o ürünle ilgili spesifik sohbeti bulunduğunda dön
          }
        } else {
          return doc.id; // Herhangi bir sohbeti
        }
      }
    }
    return null;
  }

  /// Aktif kullanıcının tüm sohbetlerini getirir ve lastMessage'yi çözer
  Stream<List<ChatModel>> watchUserChats(String currentUserId) {
    return _chatsCollection
        .where('participants', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) {
          final docs = snapshot.docs.map((doc) {
            final chat = ChatModel.fromFirestore(doc);
            final decryptedLastMessage = CryptoService.decryptMessage(
              chat.lastMessage,
              chat.id,
            );

            return ChatModel(
              id: chat.id,
              participants: chat.participants,
              productId: chat.productId,
              lastMessage: decryptedLastMessage,
              lastSenderId: chat.lastSenderId,
              updatedAt: chat.updatedAt,
            );
          }).toList();

          // Index gereksiniminden kaçınmak için sıralamayı client (istemci) tarafında yapıyoruz:
          docs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          return docs;
        });
  }

  /// Yeni bir chat oluşturur
  Future<String> createChat(
    String currentUserId,
    String targetUserId, {
    String? productId,
    String? initialMessage,
  }) async {
    final now = DateTime.now();

    // Mesaj ile başlanıyorsa varsayılan mesajı ata, yoksa boş başlasın
    final messageText = initialMessage ?? 'Sohbet başlatıldı';

    // Başlangıç mesajını o chat id'si ile şifrele. Önce belgeyi id ile oluşturalım, sonra güncelleyelim.
    final chatRef = await _chatsCollection.add({
      'participants': [currentUserId, targetUserId],
      'productId': productId,
      'lastMessage': '', // Geçici
      'lastSenderId': currentUserId,
      'updatedAt': Timestamp.fromDate(now),
    });

    final chatId = chatRef.id;
    final encryptedMessageText = CryptoService.encryptMessage(
      messageText,
      chatId,
    );

    await chatRef.update({'lastMessage': encryptedMessageText});

    if (initialMessage != null) {
      // Eğer ilk mesaj varsa hemen gönderme olarak ekleyelim
      await sendMessage(chatId, currentUserId, initialMessage);
    }
    return chatId;
  }

  /// Belirli bir sohbete mesaj gönderir
  Future<void> sendMessage(String chatId, String senderId, String text) async {
    final now = DateTime.now();

    final encryptedText = CryptoService.encryptMessage(text, chatId);

    final messageModel = MessageModel(
      id: '',
      senderId: senderId,
      text: encryptedText,
      sentAt: now,
    );

    // Messages subcollection
    await _chatsCollection
        .doc(chatId)
        .collection('messages')
        .add(messageModel.toFirestore());

    // ChatModel'i de güncelle (lastMessage)
    await _chatsCollection.doc(chatId).update({
      'lastMessage': encryptedText,
      'lastSenderId': senderId,
      'updatedAt': Timestamp.fromDate(now),
    });
  }

  /// Mesajları canlı dinler
  Stream<List<MessageModel>> watchMessages(String chatId) {
    return _chatsCollection
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: true) // En yeniler en üstte
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final message = MessageModel.fromFirestore(doc);
            final decryptedText = CryptoService.decryptMessage(
              message.text,
              chatId,
            );
            return MessageModel(
              id: message.id,
              senderId: message.senderId,
              text: decryptedText,
              sentAt: message.sentAt,
            );
          }).toList();
        });
  }
}
