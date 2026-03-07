import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:unimarket/features/auth/widgets/auth_gradient_button.dart';
import 'package:unimarket/features/auth/widgets/auth_text_field.dart';
import 'package:unimarket/features/product/model/product_category.dart';
import 'package:unimarket/features/product/viewmodel/add_product_viewmodel.dart';
import 'package:unimarket/services/image_picker_service.dart';

/// Ürün Ekleme Ekranı
///
/// Fotoğraflar, başlık, fiyat, kategori, durum ve takas seçeneği.
class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _tradeDescController = TextEditingController();
  
  // ImagePicker instance
  final _pickerService = ImagePickerService();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _tradeDescController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context, AddProductViewModel vm) async {
    final file = await _pickerService.showImageSourcePicker(context);
    if (file != null) {
      vm.addImage(file);
    }
  }

  void _handleSubmit() async {
    final vm = context.read<AddProductViewModel>();
    
    // Fotoğraf kontrolü
    if (!vm.hasImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lütfen en az bir fotoğraf ekleyin.', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      // Satıcı bilgilerini al
      final user = context.read<AuthViewModel>().user;
      if (user == null) return;

      final success = await vm.saveProduct(
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        sellerId: user.uid,
        sellerName: user.displayName,
        sellerPhotoUrl: user.photoUrl,
        tradeDescription: vm.isTradeEligible ? _tradeDescController.text : null,
        location: user.university, // Varsayılan konum olarak üniversiteyi kullan
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('İlan başarıyla oluşturuldu!', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop(); // Önceki ekrana (Home) dön
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni İlan Ver'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Consumer<AddProductViewModel>(
        builder: (context, vm, child) {
          
          // Yükleme sırasında engelleme overlay'i
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Fotoğraflar ─────────────────────────────
                      _SectionTitle(title: 'Fotoğraflar', isRequired: true),
                      const SizedBox(height: AppSizes.sm),
                      _ImagePickerRow(vm: vm, onPick: () => _pickImage(context, vm)),
                      
                      const SizedBox(height: AppSizes.xl),

                      // ── Temel Bilgiler ────────────────────────
                      _SectionTitle(title: 'Temel Bilgiler', isRequired: true),
                      const SizedBox(height: AppSizes.md),
                      
                      AuthTextField(
                        controller: _titleController,
                        hintText: 'Ürün Başlığı (örn: iPhone 11 128GB)',
                        prefixIcon: Icons.title_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Başlık zorunludur.';
                          if (value.trim().length < 5) return 'En az 5 karakter olmalı.';
                          if (value.trim().length > 50) return 'En fazla 50 karakter olabilir.';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.md),
                      
                      AuthTextField(
                        controller: _priceController,
                        hintText: 'Fiyat (₺)',
                        prefixIcon: Icons.payments_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Fiyat zorunludur.';
                          if (double.tryParse(value) == null) return 'Geçerli bir rakam girin.';
                          if (double.parse(value) < 0) return 'Fiyat 0\'dan küçük olamaz.';
                          return null;
                        },
                      ),
                      const SizedBox(height: AppSizes.md),
                      
                      AuthTextField(
                        controller: _descriptionController,
                        hintText: 'Ürün Açıklaması',
                        prefixIcon: Icons.description_outlined,
                        maxLines: 4,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Açıklama zorunludur.';
                          if (value.trim().length < 20) return 'En az 20 karakter detay verin.';
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: AppSizes.xl),

                      // ── Detaylar ───────────────────────────────
                      _SectionTitle(title: 'Detaylar', isRequired: true),
                      const SizedBox(height: AppSizes.md),
                      
                      // Kategori Seçici
                      DropdownButtonFormField<ProductCategory>(
                        decoration: _dropdownDecoration('Kategori', Icons.category_rounded),
                        initialValue: vm.selectedCategory,
                        items: ProductCategory.values.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(cat.displayName, style: GoogleFonts.poppins()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) vm.setCategory(val);
                        },
                      ),
                      const SizedBox(height: AppSizes.md),

                      // Durum Seçici
                      DropdownButtonFormField<ProductCondition>(
                        decoration: _dropdownDecoration('Fiziksel Durum', Icons.info_outline_rounded),
                        initialValue: vm.selectedCondition,
                        items: ProductCondition.values.map((cond) {
                          return DropdownMenuItem(
                            value: cond,
                            child: Text(cond.label, style: GoogleFonts.poppins()),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) vm.setCondition(val);
                        },
                      ),
                      
                      const SizedBox(height: AppSizes.xl),

                      // ── Takas Seçeneği ─────────────────────────
                      Container(
                        padding: const EdgeInsets.all(AppSizes.sm),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                        ),
                        child: Column(
                          children: [
                            SwitchListTile(
                              title: Text('Takasa Açık', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                              subtitle: Text('Bu ürünü başka bir eşya ile takas edebilirim.', style: GoogleFonts.poppins(fontSize: AppSizes.fontXs)),
                              value: vm.isTradeEligible,
                              activeThumbColor: AppColors.success,
                              activeTrackColor: AppColors.success.withValues(alpha: 0.3),
                              onChanged: vm.setTradeEligible,
                              contentPadding: EdgeInsets.zero,
                            ),
                            if (vm.isTradeEligible) ...[
                              const SizedBox(height: AppSizes.sm),
                              AuthTextField(
                                controller: _tradeDescController,
                                hintText: 'Ne tür eşyalarla takas düşünürsünüz?',
                                prefixIcon: Icons.swap_horiz_rounded,
                                maxLines: 2,
                                validator: (value) {
                                  if (vm.isTradeEligible && (value == null || value.trim().isEmpty)) {
                                    return 'Takas beklentinizi yazın.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: AppSizes.xxl),

                      // ── Hata Mesajı ───────────────────────────
                      if (vm.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.md),
                          child: Text(
                            vm.errorMessage!,
                            style: GoogleFonts.poppins(color: AppColors.error, fontSize: AppSizes.fontSm),
                          ),
                        ),

                      // ── Kaydet Butonu ─────────────────────────
                      AuthGradientButton(
                        text: 'İlanı Yayınla',
                        onPressed: vm.isLoading ? () {} : _handleSubmit,
                        isLoading: vm.isLoading,
                        icon: Icons.rocket_launch_rounded,
                      ),
                      
                      const SizedBox(height: 100), // Klavye için boşluk
                    ],
                  ),
                ),
              ),

              // Yükleme Overlay'i (İlerleme çubuğu ile)
              if (vm.isLoading)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSizes.lg),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(color: AppColors.primary),
                          const SizedBox(height: AppSizes.md),
                          Text(
                            'İlan Yükleniyor...',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: AppSizes.sm),
                          SizedBox(
                            width: 200,
                            child: LinearProgressIndicator(
                              value: vm.uploadProgress,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                            ),
                          ),
                          const SizedBox(height: AppSizes.xs),
                          Text(
                            '%${(vm.uploadProgress * 100).toInt()}',
                            style: GoogleFonts.poppins(fontSize: AppSizes.fontXs, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  InputDecoration _dropdownDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.textHint, size: AppSizes.iconMd),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }
}

// ── Yardımcı Widget'lar ────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isRequired;

  const _SectionTitle({required this.title, this.isRequired = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: AppSizes.fontLg,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 4),
          Text('*', style: TextStyle(color: AppColors.error, fontSize: AppSizes.fontLg)),
        ],
      ],
    );
  }
}

class _ImagePickerRow extends StatelessWidget {
  final AddProductViewModel vm;
  final VoidCallback onPick;

  const _ImagePickerRow({required this.vm, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              if (vm.canAddMoreImages)
                GestureDetector(
                  onTap: onPick,
                  child: Container(
                    width: 90,
                    height: 90,
                    margin: const EdgeInsets.only(right: AppSizes.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
                        const SizedBox(height: 4),
                        Text('Ekle', style: GoogleFonts.poppins(fontSize: AppSizes.fontXs, color: AppColors.primary)),
                      ],
                    ),
                  ),
                ),
              ...vm.selectedImages.asMap().entries.map((entry) {
                final isFirst = entry.key == 0;
                return Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      margin: const EdgeInsets.only(right: AppSizes.sm),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                        border: isFirst ? Border.all(color: AppColors.primary, width: 2) : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMd - (isFirst ? 2 : 0)),
                        child: Image.file(entry.value, fit: BoxFit.cover),
                      ),
                    ),
                    // Sil butonu
                    Positioned(
                      top: 4,
                      right: AppSizes.sm + 4,
                      child: GestureDetector(
                        onTap: () => vm.removeImage(entry.key),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
                          child: const Icon(Icons.close_rounded, color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                    // Kapak Rozeti
                    if (isFirst)
                      Positioned(
                        bottom: 4,
                        left: 4,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                          child: Text('Kapak', style: GoogleFonts.poppins(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'En fazla ${vm.maxImages} fotoğraf ekleyebilirsiniz. İlk fotoğraf kapak olur.',
          style: GoogleFonts.poppins(fontSize: AppSizes.fontXs, color: AppColors.textHint),
        ),
      ],
    );
  }
}
