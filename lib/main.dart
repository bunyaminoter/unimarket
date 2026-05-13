import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:unimarket/app.dart';
import 'package:unimarket/features/product/model/product_category.dart';
import 'package:unimarket/firebase_options.dart';
import 'package:unimarket/services/hive_service.dart';

/// UniMarket Uygulama Giriş Noktası
///
/// Uygulama başlatılırken:
/// 1. Flutter widget binding'leri başlatılır
/// 2. Firebase başlatılır
/// 3. Status bar stili ayarlanır
/// 4. Ekran yönü kısıtlanır
/// 5. UniMarketApp widget'ı çalıştırılır
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Global Hata Yakalayıcı (Flutter Katmanı)
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint('=== FATAL FLUTTER ERROR ===');
    debugPrint(details.exceptionAsString());
    debugPrint(details.stack?.toString());
  };

  // Global Hata Yakalayıcı (Platform / Async Katmanı)
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('=== FATAL PLATFORM ERROR ===');
    debugPrint(error.toString());
    debugPrint(stack.toString());
    return true; // Hatanın daha fazla yayılmasını önle
  };

  // Hive Başlat (Offline-First cache)
  try {
    await HiveService.init();
  } catch (e, stack) {
    debugPrint("Hive başlatma hatası: $e\n$stack");
  }

  // Firebase başlat (Duplicate App hatasını önlemek için kontrol eklendi)
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    
    // Uygulama başlarken dinamik kategorileri yükle
    try {
      final snap = await FirebaseFirestore.instance.collection('categories').get();
      if (snap.docs.isNotEmpty) {
        final dbCats = snap.docs.map((d) => ProductCategory.fromMap(d.data(), d.id)).toList();
        
        // Dropdown hatasını önlemek için 'other' kategorisinin var olduğundan emin ol
        if (!dbCats.any((c) => c.id == 'other')) {
          dbCats.add(ProductCategory.other);
        }
        
        ProductCategory.values = dbCats;
      }
    } catch (_) {}
  } catch (e, stack) {
    debugPrint("FATAL ERROR: Firebase başlatma hatası: $e\n$stack");
    // Firebase initialization başarısızsa uygulama devam etmesin
    return;
  }

  // Status bar stilini ayarla
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Ekran yönü kısıtlaması (sadece dikey)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const UniMarketApp());
}
