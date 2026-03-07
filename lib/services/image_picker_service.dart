import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Image Picker Servisi
///
/// Kamera ve galeri erişimi ile fotoğraf seçme işlemlerini yönetir.
/// Fotoğraf boyut sınırlaması ve kalite optimizasyonu destekler.
class ImagePickerService {
  final ImagePicker _picker;

  ImagePickerService({ImagePicker? picker})
      : _picker = picker ?? ImagePicker();

  // ── Tekil Fotoğraf Seçme ──────────────────────────────────
  /// Galeriden tek fotoğraf seçer.
  Future<File?> pickFromGallery({
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 80,
  }) async {
    try {
      final xFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      if (xFile == null) return null;
      return File(xFile.path);
    } catch (e) {
      debugPrint('Galeri erişim hatası: $e');
      return null;
    }
  }

  /// Kameradan fotoğraf çeker.
  Future<File?> pickFromCamera({
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 80,
  }) async {
    try {
      final xFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      if (xFile == null) return null;
      return File(xFile.path);
    } catch (e) {
      debugPrint('Kamera erişim hatası: $e');
      return null;
    }
  }

  // ── Çoklu Fotoğraf Seçme ──────────────────────────────────
  /// Galeriden birden fazla fotoğraf seçer.
  Future<List<File>> pickMultipleFromGallery({
    double maxWidth = 1024,
    double maxHeight = 1024,
    int imageQuality = 80,
    int maxImages = 5,
  }) async {
    try {
      final xFiles = await _picker.pickMultiImage(
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );
      // Maksimum fotoğraf sayısını sınırla
      final limited = xFiles.take(maxImages).toList();
      return limited.map((xFile) => File(xFile.path)).toList();
    } catch (e) {
      debugPrint('Çoklu galeri erişim hatası: $e');
      return [];
    }
  }

  // ── Kaynak Seçim Dialoğu ──────────────────────────────────
  /// Kullanıcıya kamera/galeri seçimi sunan bottom sheet gösterir.
  /// Seçilen dosyayı döndürür (null = iptal).
  Future<File?> showImageSourcePicker(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tutamak çizgisi
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.camera_alt_rounded,
                      color: Colors.blue.shade700),
                ),
                title: const Text('Kamera'),
                subtitle: const Text('Yeni fotoğraf çek'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.photo_library_rounded,
                      color: Colors.purple.shade700),
                ),
                title: const Text('Galeri'),
                subtitle: const Text('Mevcut fotoğraflardan seç'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null) return null;

    if (source == ImageSource.camera) {
      return pickFromCamera();
    } else {
      return pickFromGallery();
    }
  }
}
