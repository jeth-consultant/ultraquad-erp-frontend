import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/welcome_screen.dart';
import '../../features/contributions/contributions_screen.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/fines/fines_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/notifications/providers/notifications_provider.dart';
import '../../features/payments/payment_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/push_days/push_days_screen.dart';
import '../navigation/app_section.dart';
import '../theme/app_colors.dart';

class _NavItem {
  const _NavItem(this.icon, this.label, this.section, this.color, this.builder);

  final IconData icon;
  final String label;
  final AppSection section;
  final Color color;
  final Widget Function() builder;
}

/// The app's sidebar — implemented as a slide-out [Drawer] (the mobile
/// equivalent of a desktop sidebar). Shared by every top-level screen so
/// navigation between sections doesn't require backtracking to Home.
class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key, required this.current});

  final AppSection current;

  static final List<_NavItem> _items = [
    _NavItem(Icons.space_dashboard_outlined, 'Dashboard', AppSection.dashboard, AppColors.amber, () => const DashboardScreen()),
    _NavItem(Icons.account_balance_wallet_outlined, 'Contributions', AppSection.contributions, AppColors.teal,
        () => const ContributionsScreen()),
    _NavItem(Icons.warning_amber_rounded, 'Fines', AppSection.fines, AppColors.red, () => const FinesScreen()),
    _NavItem(Icons.code_rounded, 'Push Days', AppSection.pushDays, AppColors.mint, () => const PushDaysScreen()),
    _NavItem(Icons.payments_outlined, 'Make a Payment', AppSection.payments, AppColors.amberDeep, () => const PaymentScreen()),
    _NavItem(Icons.notifications_none_rounded, 'Notifications', AppSection.notifications, Colors.lightBlueAccent,
        () => const NotificationsScreen()),
    _NavItem(Icons.person_outline, 'Profile', AppSection.profile, Colors.white70, () => const ProfileScreen()),
  ];

  void _go(BuildContext context, AppSection section, Widget Function() builder) {
    Navigator.of(context).pop();
    if (section == current) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => builder()));
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    Navigator.of(context).pop();
    await ref.read(authProvider.notifier).logout();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final unreadCount = ref.watch(unreadNotificationsCountProvider);
    final name = auth.fullName ?? 'Member';
    final initials = _initialsOf(name);

    return Drawer(
      backgroundColor: AppColors.navy,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.amber, AppColors.amberDeep]),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'UQ',
                      style: TextStyle(color: AppColors.navy, fontWeight: FontWeight.w800, fontSize: 14),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text('UltraQuad', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                      Text('ERP · v1.0.0', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 20, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'MAIN',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.1),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 6),
                children: [
                  for (final item in _items)
                    _item(context, item, badgeCount: item.section == AppSection.notifications ? unreadCount : 0),
                ],
              ),
            ),
            const Divider(color: Colors.white12, height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.teal,
                    child: Text(
                      initials,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Text('Member · Online', style: TextStyle(color: Colors.white54, fontSize: 11)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: Colors.white54, size: 19),
                    tooltip: 'Logout',
                    onPressed: () => _logout(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, _NavItem item, {int badgeCount = 0}) {
    final isActive = item.section == current;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? Colors.white.withValues(alpha: 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: isActive ? item.color : Colors.transparent, width: 3)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _go(context, item.section, item.builder),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            child: Row(
              children: [
                Icon(item.icon, size: 19, color: isActive ? item.color : Colors.white70),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.white70,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13.5,
                    ),
                  ),
                ),
                if (badgeCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.red, borderRadius: BorderRadius.circular(20)),
                    child: Text(
                      '$badgeCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _initialsOf(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
}
