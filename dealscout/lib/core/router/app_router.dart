import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../presentation/screens/splash/splash_screen.dart';
import '../../presentation/screens/onboarding/onboarding_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/signup_screen.dart';
import '../../presentation/screens/home/home_screen.dart';
import '../../presentation/screens/map/map_screen.dart';
import '../../presentation/screens/deal_details/deal_details_screen.dart';
import '../../presentation/screens/ai_chat/ai_chat_screen.dart';
import '../../presentation/screens/favorites/favorites_screen.dart';
import '../../presentation/screens/notifications/notifications_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/merchant/merchant_dashboard_screen.dart';
import '../../presentation/screens/wallet/wallet_screen.dart';
import '../../presentation/screens/rewards/rewards_screen.dart';

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Authentication
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        builder: (context, state) => const SignupScreen(),
      ),
      
      // Main App - Shell Route for Bottom Navigation
      ShellRoute(
        builder: (context, state, child) => HomeScreen(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (context, state) => NoTransitionPage(
              child: Container(), // Content rendered by HomeScreen
            ),
          ),
          
          // Map View
          GoRoute(
            path: '/map',
            name: 'map',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const MapScreen(),
            ),
          ),
          
          // Favorites
          GoRoute(
            path: '/favorites',
            name: 'favorites',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const FavoritesScreen(),
            ),
          ),
          
          // Notifications
          GoRoute(
            path: '/notifications',
            name: 'notifications',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const NotificationsScreen(),
            ),
          ),
          
          // Profile
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const ProfileScreen(),
            ),
          ),
          
          // Deal Details
          GoRoute(
            path: '/deal/:id',
            name: 'deal-details',
            builder: (context, state) {
              final dealId = state.pathParameters['id']!;
              return DealDetailsScreen(dealId: dealId);
            },
          ),
          
          // AI Chat
          GoRoute(
            path: '/ai-chat',
            name: 'ai-chat',
            builder: (context, state) => const AiChatScreen(),
          ),
          
          // Merchant Dashboard
          GoRoute(
            path: '/merchant',
            name: 'merchant',
            builder: (context, state) => const MerchantDashboardScreen(),
          ),
          
          // Wallet
          GoRoute(
            path: '/wallet',
            name: 'wallet',
            builder: (context, state) => const WalletScreen(),
          ),
          
          // Rewards
          GoRoute(
            path: '/rewards',
            name: 'rewards',
            builder: (context, state) => const RewardsScreen(),
          ),
        ],
      ),
    ],
    
    // Error handler for route not found
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Page not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
