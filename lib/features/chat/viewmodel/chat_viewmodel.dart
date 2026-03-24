import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unimarket/features/auth/repository/auth_repository.dart';
import 'package:unimarket/features/chat/repository/chat_repository.dart';
import 'package:unimarket/models/chat_model.dart';
import 'package:unimarket/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatListViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository;
  final AuthRepository _authRepository;

  ChatListViewModel({
    ChatRepository? chatRepository,
    AuthRepository? authRepository,
  }) : _chatRepository = chatRepository ?? ChatRepository(),
       _authRepository = authRepository ?? AuthRepository();

  List<ChatModel> _chats = [];
  Map<String, UserModel> _userCache = {}; // UID -> User
  StreamSubscription? _chatsSub;
  bool _isLoading = false;

  List<ChatModel> get chats => _chats;
  bool get isLoading => _isLoading;

  void startListening() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    _chatsSub?.cancel();
    _chatsSub = _chatRepository.watchUserChats(user.uid).listen((
      chatList,
    ) async {
      _chats = chatList;

      // Eksik profil bilgilerini getir
      for (var chat in chatList) {
        final theOtherGuyId = chat.participants.firstWhere(
          (p) => p != user.uid,
          orElse: () => '',
        );
        if (theOtherGuyId.isNotEmpty &&
            !_userCache.containsKey(theOtherGuyId)) {
          final profile = await _authRepository.getUserProfile(theOtherGuyId);
          if (profile != null) {
            _userCache[theOtherGuyId] = profile;
          }
        }
      }

      _isLoading = false;
      notifyListeners();
    });
  }

  UserModel? getOtherParticipantUser(String chatId) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;

    final chat = _chats.firstWhere(
      (c) => c.id == chatId,
      orElse: () => ChatModel(
        id: '',
        participants: const [],
        lastMessage: '',
        lastSenderId: '',
        updatedAt: DateTime.now(),
      ),
    );
    if (chat.id.isEmpty) return null;

    final theOtherGuyId = chat.participants.firstWhere(
      (p) => p != user.uid,
      orElse: () => '',
    );
    return _userCache[theOtherGuyId];
  }

  @override
  void dispose() {
    _chatsSub?.cancel();
    super.dispose();
  }
}

class ChatDetailViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository;

  ChatDetailViewModel({ChatRepository? chatRepository})
    : _chatRepository = chatRepository ?? ChatRepository();

  List<MessageModel> _messages = [];
  StreamSubscription? _messagesSub;
  String? _currentChatId;

  List<MessageModel> get messages => _messages;

  void listenToMessages(String chatId) {
    _currentChatId = chatId;
    _messagesSub?.cancel();
    _messagesSub = _chatRepository.watchMessages(chatId).listen((msgs) {
      _messages = msgs;
      notifyListeners();
    });
  }

  Future<void> sendMessage(String text) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _currentChatId == null || text.trim().isEmpty) return;

    await _chatRepository.sendMessage(_currentChatId!, user.uid, text.trim());
  }

  Future<String> startOrGetChat(
    String targetUserId, {
    String? productId,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("Giriş yapmalısınız");

    final existingChatId = await _chatRepository.findExistingChat(
      user.uid,
      targetUserId,
      productId: productId,
    );
    if (existingChatId != null) {
      return existingChatId;
    }

    // Yoksa oluştur
    return await _chatRepository.createChat(
      user.uid,
      targetUserId,
      productId: productId,
    );
  }

  @override
  void dispose() {
    _messagesSub?.cancel();
    super.dispose();
  }
}
