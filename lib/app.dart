import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unimarket/core/constants/app_strings.dart';
import 'package:unimarket/core/theme/app_theme.dart';
import 'package:unimarket/core/router/app_router.dart';
import 'package:unimarket/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:unimarket/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:unimarket/features/home/viewmodel/home_viewmodel.dart';
import 'package:unimarket/features/product/viewmodel/add_product_viewmodel.dart';
import 'package:unimarket/features/product/viewmodel/product_detail_viewmodel.dart';
import 'package:unimarket/features/product/viewmodel/my_products_viewmodel.dart';
import 'package:unimarket/features/product/viewmodel/favorites_viewmodel.dart';
import 'package:unimarket/features/trade/viewmodel/trade_offer_viewmodel.dart';
import 'package:unimarket/features/trade/viewmodel/my_offers_viewmodel.dart';
import 'package:unimarket/features/chat/viewmodel/chat_viewmodel.dart';
import 'package:unimarket/features/auction/viewmodel/auction_viewmodel.dart';
import 'package:unimarket/features/auction/viewmodel/auction_list_viewmodel.dart';
import 'package:unimarket/features/admin/viewmodel/admin_viewmodel.dart';
import 'package:unimarket/features/notifications/viewmodel/notification_viewmodel.dart';

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

        // Product Detail ViewModel
        ChangeNotifierProvider(create: (_) => ProductDetailViewModel()),

        // Trade Offer ViewModel
        ChangeNotifierProvider(create: (_) => TradeOfferViewModel()),

        // My Offers ViewModel
        ChangeNotifierProvider(create: (_) => MyOffersViewModel()),

        // My Products ViewModel
        ChangeNotifierProvider(create: (_) => MyProductsViewModel()),

        // Favorites ViewModel
        ChangeNotifierProvider(create: (_) => FavoritesViewModel()),

        // Chat ViewModels
        ChangeNotifierProvider(create: (_) => ChatListViewModel()),
        ChangeNotifierProvider(create: (_) => ChatDetailViewModel()),

        // Auction ViewModel
        ChangeNotifierProvider(create: (_) => AuctionViewModel()),
        ChangeNotifierProvider(create: (_) => AuctionListViewModel()),

        // Admin ViewModel
        ChangeNotifierProvider(create: (_) => AdminViewModel()),

        // Notification ViewModel
        ChangeNotifierProvider(create: (_) => NotificationViewModel()),
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
