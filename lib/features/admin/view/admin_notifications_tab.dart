import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/features/admin/viewmodel/admin_viewmodel.dart';

/// Admin Bildirim Gönderme Sekmesi
class AdminNotificationsTab extends StatefulWidget {
  const AdminNotificationsTab({super.key});

  @override
  State<AdminNotificationsTab> createState() => _AdminNotificationsTabState();
}

class _AdminNotificationsTabState extends State<AdminNotificationsTab> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  String _targetRole = 'all'; // all, user, admin

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _sendNotification() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Başlık ve içerik zorunludur.'), backgroundColor: AppColors.error),
      );
      return;
    }

    final vm = context.read<AdminViewModel>();
    final success = await vm.sendNotification(
      title: title,
      body: body,
      targetRole: _targetRole == 'all' ? null : _targetRole,
    );

    if (mounted) {
      if (success) {
        _titleController.clear();
        _bodyController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bildirim gönderildi!'), backgroundColor: AppColors.success),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(vm.errorMessage ?? 'Hata'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSizes.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📢 Bildirim Gönder', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSizes.md),

          // Hedef kitle
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Hedef Kitle', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: Text('Herkes', style: GoogleFonts.poppins(fontSize: 13)),
                      selected: _targetRole == 'all',
                      selectedColor: AppColors.primary.withValues(alpha: 0.2),
                      onSelected: (_) => setState(() => _targetRole = 'all'),
                    ),
                    ChoiceChip(
                      label: Text('Kullanıcılar', style: GoogleFonts.poppins(fontSize: 13)),
                      selected: _targetRole == 'user',
                      selectedColor: AppColors.success.withValues(alpha: 0.2),
                      onSelected: (_) => setState(() => _targetRole = 'user'),
                    ),
                    ChoiceChip(
                      label: Text('Adminler', style: GoogleFonts.poppins(fontSize: 13)),
                      selected: _targetRole == 'admin',
                      selectedColor: AppColors.secondary.withValues(alpha: 0.2),
                      onSelected: (_) => setState(() => _targetRole = 'admin'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.md),

          // Bildirim formu
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bildirim İçeriği', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 12),
                TextField(
                  controller: _titleController,
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    labelText: 'Başlık',
                    hintText: 'Bildirim başlığı',
                    filled: true,
                    fillColor: const Color(0xFFF0F2F5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _bodyController,
                  style: GoogleFonts.poppins(),
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'İçerik',
                    hintText: 'Bildirim detayı...',
                    filled: true,
                    fillColor: const Color(0xFFF0F2F5),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _sendNotification,
                    icon: const Icon(Icons.send_rounded),
                    label: Text('Bildirimi Gönder', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSizes.lg),

          // Sistem Duyuruları
          Container(
            padding: const EdgeInsets.all(AppSizes.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('⚡ Hızlı Duyurular', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 8),
                _QuickAction(
                  icon: Icons.build_rounded,
                  label: 'Bakım Duyurusu',
                  onTap: () {
                    _titleController.text = '🔧 Planlı Bakım';
                    _bodyController.text = 'Sistem bakımı nedeniyle kısa süreli kesinti yaşanabilir.';
                  },
                ),
                _QuickAction(
                  icon: Icons.system_update_rounded,
                  label: 'Güncelleme Duyurusu',
                  onTap: () {
                    _titleController.text = '🚀 Yeni Güncelleme';
                    _bodyController.text = 'UniMarket yeni özelliklerle güncellendi! Detaylar için uygulamayı kontrol edin.';
                  },
                ),
                _QuickAction(
                  icon: Icons.celebration_rounded,
                  label: 'Hoş Geldiniz',
                  onTap: () {
                    _titleController.text = '🎉 Hoş Geldiniz!';
                    _bodyController.text = 'UniMarket ailesine hoş geldiniz! Ürünlerinizi hemen listelemeye başlayabilirsiniz.';
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.secondary),
      title: Text(label, style: GoogleFonts.poppins(fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textHint),
      onTap: onTap,
    );
  }
}
