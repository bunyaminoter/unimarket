import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unimarket/features/onboarding/view/onboarding_screen.dart';
import 'package:unimarket/features/home/view/home_screen.dart';
import 'package:unimarket/features/auth/view/login_screen.dart';
import 'package:unimarket/features/auth/view/register_screen.dart';
import 'package:unimarket/features/profile/view/profile_screen.dart';
import 'package:unimarket/features/product/view/add_product_screen.dart';
import 'package:unimarket/features/product/view/product_detail_screen.dart';
import 'package:unimarket/features/product/view/my_products_screen.dart';
import 'package:unimarket/features/product/view/favorites_screen.dart';
import 'package:unimarket/features/chat/view/chat_list_screen.dart';
import 'package:unimarket/features/chat/view/chat_detail_screen.dart';
import 'package:unimarket/models/product_model.dart';
import 'package:unimarket/models/user_model.dart';

/// Uygulama route isimleri.
/// Tüm route'lar burada merkezi olarak tanımlıdır.
class AppRoutes {
  AppRoutes._();

  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String addProduct = '/add-product';
  static const String myProducts = '/my-products';
  static const String favorites = '/favorites';
  static const String productDetail = '/product/:id';
  static const String chatList = '/chat-list';
  static const String chatDetail = '/chat-detail/:chatId';
}

/// GoRouter yapılandırması.
/// Auth guard, redirect'ler ve sayfa geçiş animasyonları.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.onboarding,
    debugLogDiagnostics: true,
    routes: [
      // ── Onboarding ──────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // ── Login ───────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // ── Register ────────────────────────────────────────
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RegisterScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),

      // ── Home ────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),

      // ── Profile ─────────────────────────────────────────
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ProfileScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 1.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),

      // ── Add Product ───────────────────────────────────────
      GoRoute(
        path: AppRoutes.addProduct,
        name: 'addProduct',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddProductScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0.0, 1.0), // Aşağıdan yukarı modal gibi
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),

      // ── My Products ───────────────────────────────────────
      GoRoute(
        path: AppRoutes.myProducts,
        name: 'myProducts',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MyProductsScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0), // Sağdan sola
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),

      // ── Favorites ─────────────────────────────────────────
      GoRoute(
        path: AppRoutes.favorites,
        name: 'favorites',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const FavoritesScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0), // Sağdan sola
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),

      // ── Chat List ─────────────────────────────────────────
      GoRoute(
        path: AppRoutes.chatList,
        name: 'chatList',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const ChatListScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(1.0, 0.0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),

      // ── Chat Detail ───────────────────────────────────────
      GoRoute(
        path: AppRoutes.chatDetail,
        name: 'chatDetail',
        pageBuilder: (context, state) {
          final chatId = state.pathParameters['chatId'];
          final targetUser = state.extra as UserModel;

          return CustomTransitionPage(
            key: state.pageKey,
            child: ChatDetailScreen(
              chatId: chatId ?? '',
              targetUser: targetUser,
            ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1.0, 0.0),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
          );
        },
      ),

      // ── Product Detail ────────────────────────────────────
      GoRoute(
        path: AppRoutes.productDetail,
        name: 'productDetail',
        pageBuilder: (context, state) {
          final product = state.extra as ProductModel;
          return CustomTransitionPage(
            key: state.pageKey,
            child: ProductDetailScreen(initialProduct: product),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(1.0, 0.0), // Sağdan sola
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(
                            parent: animation,
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                    child: child,
                  );
                },
          );
        },
      ),
    ],

    // Hata sayfası
    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Sayfa bulunamadı',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                state.uri.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
