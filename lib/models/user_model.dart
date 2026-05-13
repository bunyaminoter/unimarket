import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// UniMarket Kullanıcı Modeli
///
/// Firestore `users` koleksiyonuna karşılık gelir.
/// Öğrenci e-postası, üniversite bilgisi, istatistikler ve profil bilgilerini içerir.
///
/// Firestore Yapısı:
/// ```
/// users/{uid}
///   ├── email: string
///   ├── displayName: string
///   ├── photoUrl: string?
///   ├── university: string?
///   ├── department: string?
///   ├── studentYear: int?
///   ├── phoneNumber: string?
///   ├── bio: string?
///   ├── role: string (user/admin)
///   ├── createdAt: timestamp
///   ├── updatedAt: timestamp
///   ├── isEmailVerified: bool
///   ├── rating: double
///   ├── totalSales: int
///   ├── totalPurchases: int
///   └── totalTrades: int
/// ```
class UserModel extends Equatable {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String? university;
  final String? department;
  final int? studentYear;
  final String? phoneNumber;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final double rating;
  final int totalSales;
  final int totalPurchases;
  final int totalTrades;
  final String role;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.university,
    this.department,
    this.studentYear,
    this.phoneNumber,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
    this.isEmailVerified = false,
    this.rating = 0.0,
    this.totalSales = 0,
    this.totalPurchases = 0,
    this.totalTrades = 0,
    this.role = 'user',
  });

  /// Firestore'dan UserModel oluşturur.
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'],
      university: data['university'],
      department: data['department'],
      studentYear: data['studentYear'],
      phoneNumber: data['phoneNumber'],
      bio: data['bio'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isEmailVerified: data['isEmailVerified'] ?? false,
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalSales: data['totalSales'] ?? 0,
      totalPurchases: data['totalPurchases'] ?? 0,
      totalTrades: data['totalTrades'] ?? 0,
      role: data['role'] ?? 'user',
    );
  }

  /// UserModel'ı Firestore-uyumlu Map'e çevirir.
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'university': university,
      'department': department,
      'studentYear': studentYear,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isEmailVerified': isEmailVerified,
      'rating': rating,
      'totalSales': totalSales,
      'totalPurchases': totalPurchases,
      'totalTrades': totalTrades,
      'role': role,
    };
  }

  /// Belirli alanları güncellenmiş yeni bir kopya oluşturur.
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? university,
    String? department,
    int? studentYear,
    String? phoneNumber,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    double? rating,
    int? totalSales,
    int? totalPurchases,
    int? totalTrades,
    String? role,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      university: university ?? this.university,
      department: department ?? this.department,
      studentYear: studentYear ?? this.studentYear,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      rating: rating ?? this.rating,
      totalSales: totalSales ?? this.totalSales,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      totalTrades: totalTrades ?? this.totalTrades,
      role: role ?? this.role,
    );
  }

  /// Kullanıcının admin olup olmadığını kontrol eder.
  bool get isAdmin => role == 'admin';

  /// E-postanın .edu uzantılı (öğrenci) olup olmadığını kontrol eder.
  bool get isStudentEmail {
    final lower = email.toLowerCase();
    return lower.endsWith('.edu') ||
        lower.endsWith('.edu.tr') ||
        lower.contains('.edu.');
  }

  /// Kullanıcının profilinin tamamlanıp tamamlanmadığını kontrol eder.
  bool get isProfileComplete {
    return displayName.isNotEmpty &&
        university != null &&
        university!.isNotEmpty &&
        department != null &&
        department!.isNotEmpty;
  }

  /// Kullanıcının baş harflerini döndürür (avatar için).
  String get initials {
    if (displayName.isEmpty) return '?';
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  @override
  List<Object?> get props => [
    uid,
    email,
    displayName,
    photoUrl,
    university,
    department,
    studentYear,
    phoneNumber,
    bio,
    createdAt,
    updatedAt,
    isEmailVerified,
    rating,
    totalSales,
    totalPurchases,
    totalTrades,
    role,
  ];

  @override
  String toString() =>
      'UserModel(uid: $uid, email: $email, name: $displayName)';
}
