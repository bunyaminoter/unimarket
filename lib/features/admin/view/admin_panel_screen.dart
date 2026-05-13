import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:unimarket/core/constants/app_colors.dart';
import 'package:unimarket/core/router/app_router.dart';
import 'package:unimarket/features/admin/viewmodel/admin_viewmodel.dart';
import 'package:unimarket/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:unimarket/features/admin/view/admin_dashboard_tab.dart';
import 'package:unimarket/features/admin/view/admin_users_tab.dart';
import 'package:unimarket/features/admin/view/admin_products_tab.dart';
import 'package:unimarket/features/admin/view/admin_categories_tab.dart';
import 'package:unimarket/features/admin/view/admin_notifications_tab.dart';

/// Admin Panel Ana Sayfası
class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  static const _tabs = [
    Tab(icon: Icon(Icons.dashboard_rounded), text: 'Dashboard'),
    Tab(icon: Icon(Icons.people_rounded), text: 'Kullanıcılar'),
    Tab(icon: Icon(Icons.inventory_2_rounded), text: 'Ürünler'),
    Tab(icon: Icon(Icons.category_rounded), text: 'Kategoriler'),
    Tab(icon: Icon(Icons.notifications_rounded), text: 'Bildirimler'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authVM = context.read<AuthViewModel>();
      if (!authVM.isAdmin) {
        context.go(AppRoutes.home);
        return;
      }
      context.read<AdminViewModel>().loadDashboard();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Text('Admin Panel', style: GoogleFonts.poppins(fontWeight: FontWeight.w700, fontSize: 18, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70),
            tooltip: 'Çıkış Yap',
            onPressed: () async {
              await context.read<AuthViewModel>().signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabAlignment: TabAlignment.start,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 12),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          AdminDashboardTab(),
          AdminUsersTab(),
          AdminProductsTab(),
          AdminCategoriesTab(),
          AdminNotificationsTab(),
        ],
      ),
    );
  }
}
