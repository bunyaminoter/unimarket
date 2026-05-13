import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/constants/app_sizes.dart';
import 'package:unimarket/features/admin/viewmodel/admin_viewmodel.dart';

/// Admin Dashboard Sekmesi
class AdminDashboardTab extends StatefulWidget {
  const AdminDashboardTab({super.key});

  @override
  State<AdminDashboardTab> createState() => _AdminDashboardTabState();
}

class _AdminDashboardTabState extends State<AdminDashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminViewModel>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminViewModel>(
      builder: (context, vm, _) {
        if (vm.isDashboardLoading && vm.stats.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final stats = vm.stats;

        return RefreshIndicator(
          onRefresh: vm.loadDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSizes.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Genel Bakış', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSizes.md),

                // İstatistik kartları
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    _StatCard(
                      icon: Icons.people_rounded,
                      label: 'Toplam Kullanıcı',
                      value: '${stats['totalUsers'] ?? 0}',
                      color: AppColors.primary,
                    ),
                    _StatCard(
                      icon: Icons.person_pin_rounded,
                      label: 'Aktif Kullanıcı (7 gün)',
                      value: '${stats['activeUsers'] ?? 0}',
                      color: AppColors.success,
                    ),
                    _StatCard(
                      icon: Icons.inventory_2_rounded,
                      label: 'Toplam Ürün',
                      value: '${stats['totalProducts'] ?? 0}',
                      color: AppColors.secondary,
                    ),
                    _StatCard(
                      icon: Icons.person_add_rounded,
                      label: 'Bugünkü Kayıtlar',
                      value: '${stats['todayRegistrations'] ?? 0}',
                      color: AppColors.accent,
                    ),
                  ],
                ),

                const SizedBox(height: AppSizes.lg),

                // En popüler kategori
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSizes.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('📊 En Popüler Kategori', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        stats['topCategory'] ?? 'Henüz veri yok',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSizes.md),

                // Kategori Dağılımı
                if (stats['categoryDistribution'] != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSizes.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('📦 Kategori Dağılımı', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16)),
                        const SizedBox(height: 12),
                        ...(stats['categoryDistribution'] as Map<String, int>).entries.map((entry) {
                          final total = (stats['totalProducts'] as int?) ?? 1;
                          final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(entry.key, style: GoogleFonts.poppins(fontSize: 13)),
                                    Text('${entry.value} (%${percentage.toStringAsFixed(0)})',
                                        style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: percentage / 100,
                                    backgroundColor: Colors.grey.shade200,
                                    color: AppColors.primary,
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.md),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
