import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/location_provider.dart';
import '../widgets/deal_card.dart';
import '../widgets/category_chip.dart';

class HomeScreen extends ConsumerWidget {
  final Widget? child;
  
  const HomeScreen({super.key, this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize location on home screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider.notifier).getCurrentLocation();
    });

    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          IndexedStack(
            index: _calculateTabIndex(context),
            children: [
              // Home Tab Content
              _HomeTab(),
              
              // Map Tab
              const SizedBox.shrink(),
              
              // Favorites Tab
              const SizedBox.shrink(),
              
              // Notifications Tab
              const SizedBox.shrink(),
              
              // Profile Tab
              const SizedBox.shrink(),
            ],
          ),
          
          // Child route content (deal details, etc.)
          if (child != null) child!,
        ],
      ),
      
      // Floating Action Button - AI Assistant
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/ai-chat'),
        backgroundColor: AppTheme.secondary,
        icon: const Icon(Icons.smart_toy_rounded),
        label: const Text('AI Assistant'),
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  int _calculateTabIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.contains('/map')) return 1;
    if (location.contains('/favorites')) return 2;
    if (location.contains('/notifications')) return 3;
    if (location.contains('/profile')) return 4;
    return 0;
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _calculateTabIndex(context),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/map');
              break;
            case 2:
              context.go('/favorites');
              break;
            case 3:
              context.go('/notifications');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textSecondaryLight,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map_rounded),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_outline),
            activeIcon: Icon(Icons.favorite_rounded),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            activeIcon: Icon(Icons.notifications_rounded),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _HomeTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);
    final dealsAsync = ref.watch(nearbyDealsProvider);

    return CustomScrollView(
      slivers: [
        // App Bar with Search
        SliverAppBar(
          floating: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                locationState.city ?? 'Your Location',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondaryLight,
                ),
              ),
              const Text(
                'Discover Deals',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              onPressed: () {
                // Scan QR code for coupons
              },
            ),
          ],
        ),

        // Search Bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search deals, stores, brands...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.tune,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                filled: true,
                fillColor: AppTheme.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (query) {
                // Navigate to search results
              },
            ),
          ),
        ),

        // Categories
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // View all categories
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
              children: [
                CategoryChip(
                  label: '🍽️ Restaurants',
                  icon: Icons.restaurant,
                  isSelected: false,
                  onTap: () {},
                ),
                CategoryChip(
                  label: '🛒 Groceries',
                  icon: Icons.shopping_cart,
                  isSelected: false,
                  onTap: () {},
                ),
                CategoryChip(
                  label: '👗 Fashion',
                  icon: Icons.checkroom,
                  isSelected: false,
                  onTap: () {},
                ),
                CategoryChip(
                  label: '📱 Electronics',
                  icon: Icons.devices,
                  isSelected: false,
                  onTap: () {},
                ),
                CategoryChip(
                  label: '💄 Beauty',
                  icon: Icons.face,
                  isSelected: false,
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),

        // Trending Deals Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Trending Nearby',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // View all trending deals
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
        ),

        // Deals Grid
        dealsAsync.when(
          data: (deals) {
            if (deals.isEmpty) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: AppConstants.spacingXxl),
                      Icon(
                        Icons.explore_off_outlined,
                        size: 64,
                        color: AppTheme.textSecondaryLight.withOpacity(0.5),
                      ),
                      const SizedBox(height: AppConstants.spacingMd),
                      Text(
                        'No deals found nearby',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppConstants.spacingMd,
                  crossAxisSpacing: AppConstants.spacingMd,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final deal = deals[index];
                    return DealCard(deal: deal);
                  },
                  childCount: deals.length > 6 ? 6 : deals.length,
                ),
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, stack) => SliverToBoxAdapter(
            child: Center(
              child: Text('Error: $error'),
            ),
          ),
        ),

        // Add some spacing at bottom
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }
}
