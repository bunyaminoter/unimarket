import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/features/admin/repository/admin_repository.dart';
import 'package:unimarket/features/product/model/product_category.dart';

class AdminCategoriesTab extends StatefulWidget {
  const AdminCategoriesTab({super.key});

  @override
  State<AdminCategoriesTab> createState() => _AdminCategoriesTabState();
}

class _AdminCategoriesTabState extends State<AdminCategoriesTab> {
  final AdminRepository _repository = AdminRepository();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<ProductCategory> _categories = [];
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  List<ProductCategory> get _filteredCategories {
    if (_searchQuery.trim().isEmpty) return _categories;
    final query = _searchQuery.trim().toLowerCase();
    return _categories.where((cat) {
      return cat.label.toLowerCase().contains(query) || 
             cat.id.toLowerCase().contains(query);
    }).toList();
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final dbCategories = await _repository.getCategories();
      
      // Her zaman 'other' kategorisi bulunmalı (dropdown çökmemesi için)
      if (!dbCategories.any((c) => c.id == 'other')) {
        dbCategories.add(ProductCategory.other);
      }

      // App genelindeki listeyi doğrudan Firestore'a eşitle
      ProductCategory.values = dbCategories;
      
      if (mounted) {
        setState(() {
          _categories = dbCategories;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddDialog() {
    final idController = TextEditingController();
    final labelController = TextEditingController();
    final emojiController = TextEditingController(text: '📦');

    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Yeni Kategori Ekle', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: InputDecoration(
                labelText: 'Kategori ID (örn: furniture)',
                labelStyle: GoogleFonts.poppins(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: labelController,
              decoration: InputDecoration(
                labelText: 'Başlık (örn: Mobilya)',
                labelStyle: GoogleFonts.poppins(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: emojiController,
              decoration: InputDecoration(
                labelText: 'Emoji (örn: 🛋️)',
                labelStyle: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: Text('İptal', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newCat = ProductCategory(
                id: idController.text.trim(),
                label: labelController.text.trim(),
                emoji: emojiController.text.trim(),
              );
              
              if (newCat.id.isNotEmpty && newCat.label.isNotEmpty) {
                Navigator.pop(c);
                setState(() => _isLoading = true);
                try {
                  await _repository.addCategory(newCat);
                  await _loadCategories();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Kategori eklendi.', style: GoogleFonts.poppins()),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Hata: $e', style: GoogleFonts.poppins()),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    setState(() => _isLoading = false);
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('Ekle', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _deleteCategory(ProductCategory category) async {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text('Kategoriyi Sil', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('${category.label} kategorisini silmek istediğinize emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(c);
              setState(() => _isLoading = true);
              try {
                await _repository.deleteCategory(category.id);
                await _loadCategories();
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString(), style: GoogleFonts.poppins()),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  setState(() => _isLoading = false);
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Yeni Kategori', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSizes.md),
                  child: Column(
                    children: [
                      // Arama Kutusu
                      TextField(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _searchQuery = value),
                        decoration: InputDecoration(
                          hintText: 'Kategori ara (isim veya ID)...',
                          hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 14),
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded, color: AppColors.textSecondary),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSizes.sm),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Bulunan: ${_filteredCategories.length} Kategori',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _filteredCategories.isEmpty
                      ? Center(
                          child: Text(
                            'Kategori bulunamadı.',
                            style: GoogleFonts.poppins(color: AppColors.textHint),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                          itemCount: _filteredCategories.length,
                          itemBuilder: (context, index) {
                            final cat = _filteredCategories[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 1,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(cat.emoji, style: const TextStyle(fontSize: 24)),
                          ),
                          title: Text(
                            cat.label,
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                          subtitle: Text(
                            'ID: ${cat.id}',
                            style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textHint),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: AppColors.error),
                            onPressed: () => _deleteCategory(cat),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
