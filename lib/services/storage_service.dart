import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// ImgBB Ücretsiz Yükleme Servisi (Önceden Firebase Storage kullanılıyordu)
///
/// Ürün fotoğraflarını ImgBB API üzerine tamamen ücretsiz yükler ve
/// indirme linklerini (URL) döndürür.
class StorageService {
  // TODO: Senin yollayacağın ImgBB API Anahtarı buraya eklenecek!
  static const String _imgBbApiKey = '41ee1e458aa39eed5794294804adcc34';

  // ── Tekil Fotoğraf Yükleme ────────────────────────────────
  /// Verilen dosyayı ImgBB sunucularına POST eder.
  Future<String> uploadFile({
    required File file,
    required String path, // ImgBB klasör mantığı desteklemiyor, yoksayılacak.
    ValueChanged<double>? onProgress,
  }) async {
    try {
      if (_imgBbApiKey.isEmpty ||
          _imgBbApiKey == 'BURAYA_IMGBB_API_KEY_GELECEK') {
        throw Exception(
          'ImgBB API Anahtarı bulunamadı! Lütfen sisteme ekleyin.',
        );
      }

      // ImgBB API Uç Noktası
      final uri = Uri.parse('https://api.imgbb.com/1/upload?key=$_imgBbApiKey');

      // Multipart Request (Format) oluşturulması
      final request = http.MultipartRequest('POST', uri);
      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        file.path,
      );

      request.files.add(multipartFile);

      // Yükleme başlangıcı
      if (onProgress != null) onProgress(0.1);

      // İsteği gönder
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Yükleme sonrası progress %100
      if (onProgress != null) onProgress(1.0);

      // Sonucu kontrol et
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        // Başarı durumunda ImgBB'ye dönen direkt resim linki (.jpg/.png)
        final bool success = jsonResponse['success'] ?? false;
        if (success) {
          final imageUrl = jsonResponse['data']['url'] as String;
          return imageUrl;
        } else {
          throw Exception('ImgBB API Hatası: Yükleme başarılamadı.');
        }
      } else {
        throw Exception('HTTP Hatası: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Fotoğraf yükleme hatası detay: $e');
      throw Exception('Fotoğraf yüklenirken hata oluştu: $e');
    }
  }

  // ── Çoklu Fotoğraf Yükleme ────────────────────────────────
  /// Birden fazla dosyayı tek tek sırayla yükler.
  Future<List<String>> uploadMultipleFiles({
    required List<File> files,
    required String basePath,
    ValueChanged<double>? onProgress,
  }) async {
    final urls = <String>[];
    for (int i = 0; i < files.length; i++) {
      final url = await uploadFile(
        file: files[i],
        path:
            basePath, // ImgBB klasör gerektirmez, sadece API için bekletiliyor
        onProgress: (fileProgress) {
          if (onProgress != null) {
            // Örn: Toplam 3 dosya var. 1. dosya yüklenirken %33 vb. ilerleme gösterimi.
            final totalProgress = (i + fileProgress) / files.length;
            onProgress(totalProgress);
          }
        },
      );
      urls.add(url);
    }
    return urls;
  }

  // ── Dosya Silme ───────────────────────────────────────────
  Future<void> deleteFile(String url) async {
    // ImgBB ücretsiz sürüm API anahtarıyla silme işlemi yapılamaz, token gereklidir.
    // Ancak sadece yükleme odaklı ilerleyeceğimiz için burayı boş bırakıyoruz.
    debugPrint('ImgBB üzerinden silme isteği atlandı: $url');
  }

  Future<void> deleteMultipleFiles(List<String> urls) async {
    for (final url in urls) {
      await deleteFile(url);
    }
  }
}
