import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

// Placeholder screens - these would be fully implemented in production
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Deals'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: AppTheme.textSecondaryLight.withOpacity(0.5),
            ),
            const SizedBox(height: AppConstants.spacingLg),
            const Text(
              'No saved deals yet',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppConstants.spacingMd),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Browse Deals'),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              child: const Icon(Icons.local_offer, color: AppTheme.primary),
            ),
            title: const Text('New deal nearby!'),
            subtitle: const Text('50% off at Starbucks - 0.5km away'),
            trailing: const Text('2m', style: TextStyle(fontSize: 12)),
          );
        },
      ),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.spacingMd),
        children: [
          // Profile Header
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primary,
                  child: const Text(
                    'JD',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: AppConstants.spacingMd),
                const Text(
                  'John Doe',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'john.doe@example.com',
                  style: TextStyle(color: AppTheme.textSecondaryLight),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spacingXl),
          
          // Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatCard(label: 'Coins', value: '1,250'),
              _StatCard(label: 'Savings', value: '\$432'),
              _StatCard(label: 'Deals', value: '28'),
            ],
          ),
          const SizedBox(height: AppConstants.spacingXl),
          
          // Menu Items
          _MenuItem(icon: Icons.wallet, label: 'Wallet', onTap: () {}),
          _MenuItem(icon: Icons.card_giftcard, label: 'Rewards', onTap: () {}),
          _MenuItem(icon: Icons.history, label: 'History', onTap: () {}),
          _MenuItem(icon: Icons.settings, label: 'Settings', onTap: () {}),
          _MenuItem(icon: Icons.help_outline, label: 'Help & Support', onTap: () {}),
          _MenuItem(icon: Icons.info_outline, label: 'About', onTap: () {}),
          
          const SizedBox(height: AppConstants.spacingLg),
          
          // Logout Button
          OutlinedButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.go('/login');
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: AppTheme.cardShadow(),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

// Additional placeholder screens
class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Wallet')), body: const Center(child: Text('Wallet')));
}

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Rewards')), body: const Center(child: Text('Rewards')));
}

class MerchantDashboardScreen extends StatelessWidget {
  const MerchantDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Merchant Dashboard')), body: const Center(child: Text('Merchant Dashboard')));
}

class DealDetailsScreen extends StatelessWidget {
  final String dealId;
  const DealDetailsScreen({super.key, required this.dealId});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Deal Details')), body: Center(child: Text('Deal: $dealId')));
}

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Sign Up')), body: const Center(child: Text('Signup')));
}
