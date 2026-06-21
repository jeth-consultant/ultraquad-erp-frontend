import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/providers/auth_provider.dart';
import '../auth/welcome_screen.dart';
import '../contributions/contributions_screen.dart';
import '../fines/fines_screen.dart';
import '../notifications/notifications_screen.dart';
import '../notifications/providers/notifications_provider.dart';
import '../payments/payment_screen.dart';
import '../profile/profile_screen.dart';
import '../push_days/push_days_screen.dart';

/// Home screen shown after login: a menu of the app's sections rather
/// than a card-based summary.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authProvider.notifier).logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fullName = ref.watch(authProvider).fullName ?? 'there';
    final firstName = fullName.split(' ').first;
    final unreadCount = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        titleSpacing: 16,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ULTRAQUAD ERP',
              style: AppTextStyles.caption.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            Text('Welcome, $firstName', style: AppTextStyles.heading2),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Text('What would you like to do?', style: AppTextStyles.body.copyWith(color: AppColors.teal)),
            const SizedBox(height: 16),
            _MenuTile(
              icon: Icons.account_balance_wallet_outlined,
              iconColor: AppColors.teal,
              title: 'My Contributions',
              subtitle: 'View your monthly contribution history',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ContributionsScreen()),
              ),
            ),
            _MenuTile(
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.red,
              title: 'My Fines',
              subtitle: 'View and pay outstanding fines',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FinesScreen()),
              ),
            ),
            _MenuTile(
              icon: Icons.code_rounded,
              iconColor: AppColors.navy,
              title: 'Push Days',
              subtitle: 'Track your daily GitHub push activity',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PushDaysScreen()),
              ),
            ),
            _MenuTile(
              icon: Icons.payments_outlined,
              iconColor: AppColors.green,
              title: 'Make a Payment',
              subtitle: 'Pay via M-Pesa STK push',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PaymentScreen()),
              ),
            ),
            _MenuTile(
              icon: Icons.notifications_none_rounded,
              iconColor: AppColors.mint,
              iconBackground: AppColors.navy,
              title: 'Notifications',
              subtitle: 'Payment receipts, fines, and announcements',
              badgeCount: unreadCount,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
            ),
            _MenuTile(
              icon: Icons.person_outline,
              iconColor: AppColors.navy,
              title: 'Profile',
              subtitle: 'View and edit your account details',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ),
            ),
            const SizedBox(height: 8),
            _MenuTile(
              icon: Icons.logout_rounded,
              iconColor: AppColors.red,
              title: 'Log out',
              subtitle: 'Sign out of your account',
              onTap: () => _logout(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconBackground,
    this.badgeCount = 0,
  });

  final IconData icon;
  final Color iconColor;
  final Color? iconBackground;
  final String title;
  final String subtitle;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (iconBackground ?? iconColor).withValues(alpha: iconBackground != null ? 1 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.caption),
                  ],
                ),
              ),
              if (badgeCount > 0)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(20)),
                  child: Text(
                    '$badgeCount',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
