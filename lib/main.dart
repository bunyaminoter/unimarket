import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unimarket/app.dart';
import 'package:unimarket/firebase_options.dart';

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

// Firebase başlat (Duplicate App hatasını önlemek için kontrol eklendi)
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint("Firebase başlatma hatası: $e");
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
