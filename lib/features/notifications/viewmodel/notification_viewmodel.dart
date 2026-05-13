import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Bildirim modeli
class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String? targetRole;
  final DateTime createdAt;
  final bool read;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    this.targetRole,
    required this.createdAt,
    this.read = false,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      targetRole: data['targetRole'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] ?? false,
    );
  }
}

/// Bildirim ViewModel
class NotificationViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore;

  NotificationViewModel({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  Future<void> loadNotifications({String? userRole}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .get();

      _notifications = snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .where((n) {
            // Hedef role yoksa (herkes) veya kullanıcının rolüyle eşleşiyorsa göster
            if (n.targetRole == null || n.targetRole!.isEmpty) return true;
            return n.targetRole == userRole;
          })
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }
}
