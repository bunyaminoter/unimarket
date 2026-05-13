import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/features/admin/viewmodel/admin_viewmodel.dart';
import 'package:unimarket/features/product/model/product_category.dart';
import 'package:unimarket/models/product_model.dart';

/// Admin Ürün Yönetimi Sekmesi
class AdminProductsTab extends StatefulWidget {
  const AdminProductsTab({super.key});

  @override
  State<AdminProductsTab> createState() => _AdminProductsTabState();
}

class _AdminProductsTabState extends State<AdminProductsTab> {
  ProductCategory? _selectedCategory;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showDeleteDialog(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Ürünü Sil', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text(
          '"${product.title}" kalıcı olarak silinecek. Emin misiniz?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text('İptal', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(c);
              if (context.mounted) {
                final success = await context.read<AdminViewModel>().deleteProduct(product.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(success ? 'Ürün silindi.' : 'Hata oluştu.'),
                      backgroundColor: success ? AppColors.success : AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Sil', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, vm, _) {
        var products = vm.products;

        // Kategori filtre
        if (_selectedCategory != null) {
          products = products.where((p) => p.category == _selectedCategory).toList();
        }

        // Arama filtre
        if (_searchQuery.isNotEmpty) {
          final q = _searchQuery.toLowerCase();
          products = products.where((p) =>
            p.title.toLowerCase().contains(q) ||
            p.sellerName.toLowerCase().contains(q)
          ).toList();
        }

        return Column(
          children: [
            // Arama kutusu
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSizes.md, AppSizes.md, AppSizes.md, 0),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  hintText: 'Ürün veya satıcı ara...',
                  hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
                onChanged: (q) => setState(() => _searchQuery = q),
              ),
            ),

            // Kategori filtre
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.md, vertical: 8),
                children: [
                  _FilterChip(
                    label: 'Tümü',
                    isSelected: _selectedCategory == null,
                    onTap: () => setState(() => _selectedCategory = null),
                  ),
                  ...ProductCategory.values.map((cat) => _FilterChip(
                    label: cat.displayName,
                    isSelected: _selectedCategory == cat,
                    onTap: () => setState(() => _selectedCategory = cat),
                  )),
                ],
              ),
            ),

            // Sonuç sayısı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('${products.length} ürün', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
              ),
            ),
            const SizedBox(height: 4),

            // Ürün listesi
            Expanded(
              child: vm.isProductsLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : products.isEmpty
                      ? Center(
                          child: Text('Ürün bulunamadı.', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                          itemCount: products.length,
                          itemBuilder: (context, index) {
                            final product = products[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 1,
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                leading: Container(
                                  width: 48, height: 48,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: AppColors.primary.withValues(alpha: 0.08),
                                    image: product.primaryImage != null
                                        ? DecorationImage(image: NetworkImage(product.primaryImage!), fit: BoxFit.cover)
                                        : null,
                                  ),
                                  child: product.primaryImage == null
                                      ? const Icon(Icons.image_outlined, color: AppColors.primary)
                                      : null,
                                ),
                                title: Text(
                                  product.title,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${product.formattedPrice} • ${product.sellerName}',
                                  style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                  tooltip: 'Sil',
                                  onPressed: () => _showDeleteDialog(context, product),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
          ),
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
