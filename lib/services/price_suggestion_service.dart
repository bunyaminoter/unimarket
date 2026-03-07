import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Fiyat Önerisi Servisi (REST API Entegrasyonu)
///
/// Kullanıcının girdiği ürün başlığını alır, DummyJSON API'sine istek atar,
/// dönen benzer ürünlerin fiyat ortalamasını TL bazında tahmini olarak hesaplar.
class PriceSuggestionService {
  // Sabit bir dolar kuru (Dummy hesaplama için)
  static const double _usdToTryRate = 33.5;

  /// Ürün başlığına göre tahmini piyasa ortalaması fiyatını TL olarak döndürür.
  Future<double?> fetchSuggestedPrice(String query) async {
    if (query.trim().isEmpty || query.length < 3) return null;

    try {
      // DummyJSON Public API (Arama ucu)
      final uri = Uri.parse('https://dummyjson.com/products/search?q=${Uri.encodeComponent(query)}');

      // 10 saniyelik timeout süresi koyuyoruz
      final response = await http.get(uri).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('API yanıt vermedi (Timeout).');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> products = data['products'] ?? [];

        if (products.isEmpty) {
          // Eğer API'de bu kelimeyle ürün yoksa null dön. UI "bulunamadı" diyecek.
          return null;
        }

        // Bulunan ürünlerin fiyatlarının (USD) ortalamasını al
        double totalPriceUsd = 0;
        for (var product in products) {
          // DummyJSON price alanını double veya int dönebilir
          final price = (product['price'] as num).toDouble();
          totalPriceUsd += price;
        }

        final averagePriceUsd = totalPriceUsd / products.length;
        
        // TL'ye çevir ve yuvarla (Örn: 245.67 -> 245.0)
        final averagePriceTry = (averagePriceUsd * _usdToTryRate).roundToDouble();

        return averagePriceTry;
      } else {
        throw Exception('API Hatası: HTTP ${response.statusCode}');
      }
    } on TimeoutException catch (_) {
      debugPrint('Fiyat önerisi timeout hatası.');
      throw Exception('Bağlantı zaman aşımına uğradı. İnternetinizi kontrol edin.');
    } catch (e) {
      debugPrint('Fiyat önerisi alınırken hata: $e');
      throw Exception('Piyasa fiyatı alınamadı, daha sonra tekrar deneyin.');
    }
  }
}
