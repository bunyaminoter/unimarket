import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:typed_data';

/// Mesajların şifrelenmesi ve çözülmesi için AES tabanlı servis
class CryptoService {
  /// Her sohbet odasına (chatId) özel bir anahtar türetir.
  /// (Uygulamaya özel bir gizli tuz (salt) ile birleştirerek SHA-256 hash alır)
  static encrypt.Key _getKey(String chatId) {
    const internalSalt = "UniMarket_E2EE_Secret_Salt_2026";
    final bytes = utf8.encode(chatId + internalSalt);
    // SHA-256, tam olarak 256 bit (32 byte) döndürür ki bu da AES-256 için idealdir.
    final digest = sha256.convert(bytes);
    return encrypt.Key(Uint8List.fromList(digest.bytes));
  }

  /// Mesajı şifreler
  static String encryptMessage(String plainText, String chatId) {
    try {
      final key = _getKey(chatId);
      final iv = encrypt.IV.fromLength(16); // 16 byte rasgele IV
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );

      final encrypted = encrypter.encrypt(plainText, iv: iv);
      // IV ile şifreli metni birlikte saklamamız lazım. Format: IV(base64):Encrypted(base64)
      return '${iv.base64}:${encrypted.base64}';
    } catch (e) {
      return plainText; // Hata durumunda plainText dönebiliriz veya boş string
    }
  }

  /// Şifrelenmiş mesajı çözer
  static String decryptMessage(String encryptedContent, String chatId) {
    try {
      if (!encryptedContent.contains(':')) {
        return encryptedContent; // Eski şifrelenmemiş metinler ise aynen dön
      }

      final parts = encryptedContent.split(':');
      if (parts.length != 2) return encryptedContent;

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encryptedText = encrypt.Encrypted.fromBase64(parts[1]);

      final key = _getKey(chatId);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc),
      );

      return encrypter.decrypt(encryptedText, iv: iv);
    } catch (e) {
      return '*(Şifreli Mesaj)*'; // Çözülemediyse hata mesajı göster
    }
  }
}
