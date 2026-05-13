import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/features/product/viewmodel/my_products_viewmodel.dart';
import 'package:unimarket/services/image_picker_service.dart';
import 'package:unimarket/models/product_model.dart';
import 'package:unimarket/features/product/model/product_category.dart';
import 'dart:io';

class EditProductBottomSheet extends StatefulWidget {
  final ProductModel product;

  const EditProductBottomSheet({super.key, required this.product});

  @override
  State<EditProductBottomSheet> createState() => _EditProductBottomSheetState();
}

class _EditProductBottomSheetState extends State<EditProductBottomSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _priceController;
  final ImagePickerService _imagePickerService = ImagePickerService();

  bool _isTradeEligible = false;
  File? _newImageFile;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product.title);
    _descController = TextEditingController(text: widget.product.description);
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    _isTradeEligible = widget.product.isTradeEligible;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickNewImage() async {
    final file = await _imagePickerService.showImageSourcePicker(context);
    if (file != null) {
      if (mounted) {
        setState(() {
          _newImageFile = file;
        });
      }
    }
  }

  Future<void> _handleUpdate() async {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();
    final priceText = _priceController.text.trim();

    if (title.isEmpty || desc.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lütfen tüm alanları doldurun.',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Geçerli bir fiyat girin.',
            style: GoogleFonts.poppins(),
          ),
        ),
      );
      return;
    }

    final updatedProduct = widget.product.copyWith(
      title: title,
      description: desc,
      price: price,
      isTradeEligible: _isTradeEligible,
    );

    final vm = context.read<MyProductsViewModel>();
    final success = await vm.updateProductDetails(
      updatedProduct,
      newImageFile: _newImageFile,
    );

    if (success && mounted) {
      Navigator.pop(context, true); // True döndürerek başarılı olduğunu belirt
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'İlanınız başarıyla güncellendi.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    // Silme işlemi onayı
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'İlanı Sil',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bu ilanı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Sil', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final vm = context.read<MyProductsViewModel>();
    final success = await vm.deleteProduct(widget.product.id);

    if (success && mounted) {
      Navigator.pop(
        context,
        'deleted',
      ); // Silindiğini belirtmek için özel bayrak döndür
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'İlanınız tamamen silindi.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _handleMarkAsSold() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Satıldı Olarak İşaretle',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bu ürünü satıldı olarak işaretlemek istediğinize emin misiniz? Ürün artık satışta listelenmeyecek.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'İptal',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: Text('Evet, Satıldı', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    final vm = context.read<MyProductsViewModel>();
    final updatedProduct = widget.product.copyWith(
      status: ProductStatus.sold,
    );
    final success = await vm.updateProductDetails(updatedProduct);

    if (success && mounted) {
      Navigator.pop(context, 'sold');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ürün satıldı olarak işaretlendi.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSizes.md,
        right: AppSizes.md,
        top: AppSizes.md,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSizes.md),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'İlanımı Yönet',
                    style: GoogleFonts.poppins(
                      fontSize: AppSizes.fontLg,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.error,
                    ),
                    onPressed: _handleDelete,
                    tooltip: 'İlanı Sil',
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.md),

              // Resim Güncelleme Alanı
              Center(
                child: GestureDetector(
                  onTap: _pickNewImage,
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                      border: Border.all(
                        color: Colors.grey.shade300,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: _newImageFile != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppSizes.radiusLg,
                            ),
                            child: Image.file(
                              _newImageFile!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : (widget.product.primaryImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                    AppSizes.radiusLg,
                                  ),
                                  child: Image.network(
                                    widget.product.primaryImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_a_photo,
                                      size: 32,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(height: AppSizes.xs),
                                    Text(
                                      'Resmi Güncelle',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                )),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.lg),

              TextField(
                controller: _titleController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  labelText: 'Başlık',
                  labelStyle: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              TextField(
                controller: _descController,
                style: GoogleFonts.poppins(),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Açıklama',
                  labelStyle: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),
              TextField(
                controller: _priceController,
                style: GoogleFonts.poppins(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Fiyat (₺)',
                  labelStyle: GoogleFonts.poppins(
                    color: AppColors.textSecondary,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                  ),
                ),
              ),
              const SizedBox(height: AppSizes.md),

              // Takas Seçeneği
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Takasa Açık',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Bu ürün için takas teklifleri alınabilsin mi?',
                  style: GoogleFonts.poppins(
                    fontSize: AppSizes.fontXs,
                    color: AppColors.textSecondary,
                  ),
                ),
                activeTrackColor: AppColors.success.withValues(alpha: 0.5),
                value: _isTradeEligible,
                onChanged: (val) {
                  setState(() {
                    _isTradeEligible = val;
                  });
                },
              ),

              const SizedBox(height: AppSizes.md),

              // Satıldı Olarak İşaretle Butonu
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _handleMarkAsSold,
                  icon: const Icon(Icons.check_circle_outline, color: AppColors.success),
                  label: Text(
                    'Satıldı Olarak İşaretle',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.success, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSizes.md),

              Consumer<MyProductsViewModel>(
                builder: (context, vm, child) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: vm.isLoading ? null : _handleUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            AppSizes.radiusLg,
                          ),
                        ),
                      ),
                      child: vm.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              'Değişiklikleri Kaydet',
                              style: GoogleFonts.poppins(
                                fontSize: AppSizes.fontMd,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSizes.md),
            ],
          ),
        ),
      ),
    );
  }
}
