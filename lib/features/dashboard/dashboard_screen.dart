import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/placeholder_screen.dart';
import '../auth/providers/auth_provider.dart';
import '../profile/profile_screen.dart';
import 'models/dashboard_summary.dart';
import 'providers/dashboard_provider.dart';

/// Home screen shown after login: standing summary cards + bottom nav.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _navIndex = 0;

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final summary = summaryAsync.valueOrNull ?? DashboardSummary.empty;
    final fullName = ref.watch(authProvider).fullName ?? 'there';
    final firstName = fullName.split(' ').first;
    final unreadNotifications = summary.unreadNotifications;

    return Scaffold(
      backgroundColor: AppColors.surface,
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
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textPrimary),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PlaceholderScreen(title: 'Notifications')),
                  );
                },
              ),
              if (unreadNotifications > 0)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.red, shape: BoxShape.circle),
                    child: Text(
                      '$unreadNotifications',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 4),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
              child: const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.navy,
                child: Icon(Icons.person_outline, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Here's your standing today.", style: AppTextStyles.body.copyWith(color: AppColors.teal)),
              const SizedBox(height: 16),
              _OutstandingFinesCard(amount: summary.outstandingFines),
              const SizedBox(height: 16),
              _UnpaidContributionsCard(
                amount: summary.totalContributions,
                missedMonths: summary.missedMonths,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _navIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.navy,
        unselectedItemColor: AppColors.textSecondary,
        onTap: (index) {
          if (index == 0) {
            setState(() => _navIndex = index);
            return;
          }
          final titles = ['Home', 'Paybill', 'GitHub', 'Fines'];
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PlaceholderScreen(title: titles[index])),
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet_outlined), label: 'Paybill'),
          BottomNavigationBarItem(icon: Icon(Icons.code_rounded), label: 'GitHub'),
          BottomNavigationBarItem(icon: Icon(Icons.warning_amber_rounded), label: 'Fines'),
        ],
      ),
    );
  }
}

class _OutstandingFinesCard extends StatelessWidget {
  const _OutstandingFinesCard({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: AppColors.red),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OUTSTANDING FINES',
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.6),
                  ),
                  Text(
                    'KES ${amount.toStringAsFixed(0)}',
                    style: AppTextStyles.heading1.copyWith(fontSize: 24),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PlaceholderScreen(title: 'Fines')),
              );
            },
            child: Text(
              'View & pay fines →',
              style: AppTextStyles.body.copyWith(color: AppColors.red, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

class _UnpaidContributionsCard extends StatelessWidget {
  const _UnpaidContributionsCard({required this.amount, required this.missedMonths});

  final double amount;
  final List<MissedMonth> missedMonths;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet_outlined, color: AppColors.textPrimary),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UNPAID CONTRIBUTIONS',
                    style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.6),
                  ),
                  Text(
                    'KES ${amount.toStringAsFixed(0)}',
                    style: AppTextStyles.heading1.copyWith(fontSize: 24),
                  ),
                  Text(
                    '${missedMonths.length} month${missedMonths.length == 1 ? '' : 's'} missed',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ],
          ),
          if (missedMonths.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            Text(
              'MISSED MONTHS',
              style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.6),
            ),
            const SizedBox(height: 8),
            ...missedMonths.map(
              (month) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.red),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(month.label, style: AppTextStyles.body)),
                    Text(
                      'KES ${month.amount.toStringAsFixed(0)}',
                      style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PlaceholderScreen(title: 'Contributions')),
              );
            },
            child: Text(
              'Go to contributions →',
              style: AppTextStyles.body.copyWith(color: AppColors.navy, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
