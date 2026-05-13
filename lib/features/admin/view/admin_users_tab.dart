import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/features/admin/viewmodel/admin_viewmodel.dart';
import 'package:unimarket/models/user_model.dart';

/// Admin Kullanıcı Yönetimi Sekmesi
class AdminUsersTab extends StatefulWidget {
  const AdminUsersTab({super.key});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadUsers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showUserActions(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
              // Kullanıcı bilgisi
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(user.initials, style: GoogleFonts.poppins(fontWeight: FontWeight.w700, color: AppColors.primary)),
                ),
                title: Text(user.displayName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(user.email, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: user.isAdmin ? AppColors.primary.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.isAdmin ? 'Admin' : 'User',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: user.isAdmin ? AppColors.primary : AppColors.success,
                    ),
                  ),
                ),
              ),
              const Divider(),
              // Rol Değiştir
              ListTile(
                leading: Icon(Icons.swap_horiz_rounded, color: AppColors.secondary),
                title: Text(
                  user.isAdmin ? 'User Rolüne Geçir' : 'Admin Rolüne Geçir',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                ),
                onTap: () async {
                  Navigator.pop(ctx);
                  final newRole = user.isAdmin ? 'user' : 'admin';
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: Text('Rol Değiştir', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      content: Text(
                        '${user.displayName} kullanıcısının rolü "$newRole" olarak güncellenecek. Onaylıyor musunuz?',
                        style: GoogleFonts.poppins(),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('İptal')),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(c, true),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                          child: Text('Onayla', style: GoogleFonts.poppins(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    final success = await context.read<AdminViewModel>().updateUserRole(user.uid, newRole);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Rol güncellendi.' : 'Hata oluştu.'),
                          backgroundColor: success ? AppColors.success : AppColors.error,
                        ),
                      );
                    }
                  }
                },
              ),
              // Kullanıcı Sil
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: Text('Kullanıcıyı Sil', style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: AppColors.error)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: Text('Kullanıcıyı Sil', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      content: Text('${user.displayName} kalıcı olarak silinecek. Emin misiniz?', style: GoogleFonts.poppins()),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('İptal')),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(c, true),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          child: Text('Sil', style: GoogleFonts.poppins(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true && context.mounted) {
                    await context.read<AdminViewModel>().deleteUser(user.uid);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, vm, _) {
        return Column(
          children: [
            // Arama
            Padding(
              padding: const EdgeInsets.all(AppSizes.md),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(),
                decoration: InputDecoration(
                  hintText: 'Kullanıcı ara (isim veya e-posta)...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                ),
                onChanged: (q) => vm.searchUsers(q),
              ),
            ),
            // Sonuç sayısı
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
              child: Row(
                children: [
                  Text('${vm.users.length} kullanıcı', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Liste
            Expanded(
              child: vm.isUsersLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: AppSizes.md),
                      itemCount: vm.users.length,
                      itemBuilder: (context, index) {
                        final user = vm.users[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: user.isAdmin
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : AppColors.success.withValues(alpha: 0.15),
                              child: Text(user.initials,
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700,
                                      color: user.isAdmin ? AppColors.primary : AppColors.success, fontSize: 13)),
                            ),
                            title: Text(user.displayName, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                            subtitle: Text(user.email, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: user.isAdmin ? AppColors.primary.withValues(alpha: 0.1) : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                user.isAdmin ? '👑 Admin' : 'User',
                                style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600,
                                    color: user.isAdmin ? AppColors.primary : AppColors.textSecondary),
                              ),
                            ),
                            onTap: () => _showUserActions(context, user),
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
