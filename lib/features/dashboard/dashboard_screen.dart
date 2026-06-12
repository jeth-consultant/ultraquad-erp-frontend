import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/placeholder_screen.dart';
import 'models/dashboard_summary.dart';
import 'providers/dashboard_provider.dart';

/// Home screen shown after login: quick stats + module cards.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('UltraQuad ERP')),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(dashboardSummaryProvider.future),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Overview', style: AppTextStyles.heading2),
            const SizedBox(height: 12),
            _SummaryRow(
              summary: summaryAsync.valueOrNull ?? DashboardSummary.empty,
            ),
            const SizedBox(height: 24),
            Text('Modules', style: AppTextStyles.heading2),
            const SizedBox(height: 12),
            _ModuleGrid(unreadNotifications: summaryAsync.valueOrNull?.unreadNotifications ?? 0),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            label: 'Contributions',
            value: 'KES ${summary.totalContributions.toStringAsFixed(0)}',
            color: AppColors.teal,
            icon: Icons.link,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            label: 'Outstanding Fines',
            value: 'KES ${summary.outstandingFines.toStringAsFixed(0)}',
            color: AppColors.red,
            icon: Icons.notifications_active_outlined,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(value, style: AppTextStyles.heading2),
            const SizedBox(height: 4),
            Text(label, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}

class _ModuleGrid extends StatelessWidget {
  const _ModuleGrid({required this.unreadNotifications});

  final int unreadNotifications;

  @override
  Widget build(BuildContext context) {
    final modules = <_ModuleCardData>[
      const _ModuleCardData(
        title: 'Contributions',
        icon: Icons.link,
        color: AppColors.teal,
      ),
      const _ModuleCardData(
        title: 'Fines',
        icon: Icons.gavel_outlined,
        color: AppColors.red,
      ),
      const _ModuleCardData(
        title: 'Make Payment',
        icon: Icons.shield_outlined,
        color: AppColors.navy,
      ),
      const _ModuleCardData(
        title: 'GitHub Sync',
        icon: Icons.account_tree_outlined,
        color: AppColors.green,
      ),
      _ModuleCardData(
        title: 'Notifications',
        icon: Icons.notifications_outlined,
        color: AppColors.mint,
        badgeCount: unreadNotifications,
      ),
      const _ModuleCardData(
        title: 'Profile',
        icon: Icons.person_outline,
        color: AppColors.navy,
      ),
      const _ModuleCardData(
        title: 'Admin',
        icon: Icons.admin_panel_settings_outlined,
        color: AppColors.teal,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return _ModuleCard(data: module);
      },
    );
  }
}

class _ModuleCardData {
  const _ModuleCardData({
    required this.title,
    required this.icon,
    required this.color,
    this.badgeCount = 0,
  });

  final String title;
  final IconData icon;
  final Color color;
  final int badgeCount;
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.data});

  final _ModuleCardData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PlaceholderScreen(title: data.title),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(data.icon, color: data.color, size: 28),
                  const SizedBox(height: 12),
                  Text(data.title, style: AppTextStyles.body),
                ],
              ),
              if (data.badgeCount > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${data.badgeCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
