import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_strings.dart';
import 'package:unimarket/core/theme/app_theme.dart';
import 'package:unimarket/core/router/app_router.dart';
import 'package:unimarket/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:unimarket/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:unimarket/features/home/viewmodel/home_viewmodel.dart';
import 'package:unimarket/features/product/viewmodel/add_product_viewmodel.dart';

/// UniMarket Ana Uygulama Widget'ı
///
/// MultiProvider ile tüm ViewModel'ler widget ağacına enjekte edilir.
/// MaterialApp.router, GoRouter ile deklaratif routing sağlar.
/// Light/dark tema desteği ve Material 3 aktif.
class UniMarketApp extends StatelessWidget {
  const UniMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth ViewModel — uygulama genelinde auth state yönetimi
        ChangeNotifierProvider(create: (_) => AuthViewModel()),

        // Profile ViewModel — profil bilgileri yönetimi
        ChangeNotifierProvider(create: (_) => ProfileViewModel()),

        // Home ViewModel — ana sayfa ürün listesi yönetimi
        ChangeNotifierProvider(create: (_) => HomeViewModel()..loadProducts()),

        // Add Product ViewModel — ürün ekleme ekranı state yönetimi
        ChangeNotifierProvider(create: (_) => AddProductViewModel()),
      ],
      child: MaterialApp.router(
        // Uygulama bilgileri
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,

        // Tema
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.light,

        // Routing
        routerConfig: AppRouter.router,
      ),
    );
  }
}
