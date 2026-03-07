// ============================================================
// ⚠️  BU DOSYA PLACEHOLDER'DIR!
// ============================================================
//
// Firebase projenizi oluşturduktan sonra bu dosyayı aşağıdaki
// komut ile otomatik olarak yeniden oluşturun:
//
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// Bu komut Firebase projenize bağlı gerçek API anahtarlarını
// içeren dosyayı otomatik üretecektir.
//
// Bu placeholder sadece kodun derlenmesini sağlar.
// ============================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions henüz ${defaultTargetPlatform.name} '
          'platformu için yapılandırılmadı. '
          'Lütfen "flutterfire configure" komutunu çalıştırın.',
        );
    }
  }

  // ── Android ──────────────────────────────────────────────
  // Bu değerleri Firebase Console > Project Settings > Android app
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAKiCNuH6wmKwmSlhVs8jA1ZodnjhllCF0',
    appId: '1:415733352022:android:ba052bd7b8c773f2ec9df7',
    messagingSenderId: '415733352022',
    projectId: 'unimarket-mobile-project',
    storageBucket: 'unimarket-mobile-project.firebasestorage.app',
  );

  // ── iOS ──────────────────────────────────────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: 'YOUR_MESSAGING_SENDER_ID',
    projectId: 'YOUR_PROJECT_ID',
    storageBucket: 'YOUR_STORAGE_BUCKET',
    iosBundleId: 'com.example.unimarket',
  );
}
