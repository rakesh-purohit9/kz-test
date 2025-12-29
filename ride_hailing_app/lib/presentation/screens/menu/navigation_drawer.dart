import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/constants.dart';
import '../../../data/providers/providers.dart';

/// App navigation drawer (hamburger menu)
class AppNavigationDrawer extends ConsumerWidget {
  const AppNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // User Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.divider,
                    backgroundImage: user?.photoUrl != null &&
                            user!.photoUrl!.isNotEmpty
                        ? NetworkImage(user.photoUrl!)
                        : null,
                    child: (user?.photoUrl == null || user!.photoUrl!.isEmpty)
                        ? Text(
                            user?.initials ?? 'U',
                            style: AppTypography.headlineMedium,
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'User',
                          style: AppTypography.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              user?.rating.toStringAsFixed(2) ?? '5.00',
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () {
                      Navigator.pop(context);
                      // Navigate to profile
                    },
                  ),
                ],
              ),
            ),
            const Divider(),
            // Menu Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _MenuItem(
                    icon: Icons.history,
                    title: AppStrings.rideHistory,
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/ride-history');
                    },
                  ),
                  _MenuItem(
                    icon: Icons.payment,
                    title: AppStrings.payments,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to payments
                    },
                  ),
                  _MenuItem(
                    icon: Icons.account_balance_wallet_outlined,
                    title: AppStrings.wallet,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to wallet
                    },
                  ),
                  _MenuItem(
                    icon: Icons.local_offer_outlined,
                    title: AppStrings.promotions,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to promotions
                    },
                  ),
                  const Divider(),
                  _MenuItem(
                    icon: Icons.help_outline,
                    title: AppStrings.help,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to help
                    },
                  ),
                  _MenuItem(
                    icon: Icons.shield_outlined,
                    title: AppStrings.safety,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to safety
                    },
                  ),
                  _MenuItem(
                    icon: Icons.settings_outlined,
                    title: AppStrings.settings,
                    onTap: () {
                      Navigator.pop(context);
                      // Navigate to settings
                    },
                  ),
                  const Divider(),
                  _MenuItem(
                    icon: Icons.info_outline,
                    title: AppStrings.about,
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog(context);
                    },
                  ),
                ],
              ),
            ),
            // Sign Out
            const Divider(),
            _MenuItem(
              icon: Icons.logout,
              title: AppStrings.signOut,
              onTap: () async {
                Navigator.pop(context);
                await ref.read(authProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              },
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.directions_car,
                color: AppColors.textOnPrimary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Text(AppStrings.appName),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.tagline,
              style: AppTypography.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Version 1.0.0',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.ok),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Widget? trailing;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.textPrimary,
      ),
      title: Text(
        title,
        style: AppTypography.bodyLarge,
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
