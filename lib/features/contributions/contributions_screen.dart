import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/api/api_exception.dart';
import '../../core/navigation/app_section.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_drawer.dart';
import 'models/contribution.dart';
import 'providers/contributions_provider.dart';

/// Shows the signed-in member's contribution history (GET /me/contributions).
class ContributionsScreen extends ConsumerWidget {
  const ContributionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributionsAsync = ref.watch(contributionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Contributions')),
      drawer: const AppDrawer(current: AppSection.contributions),
      body: SafeArea(
        child: contributionsAsync.when(
          data: (contributions) {
            final total = contributions.fold<double>(0, (sum, c) => sum + c.amount);
            return RefreshIndicator(
              onRefresh: () => ref.refresh(contributionsProvider.future),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.teal.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL CONTRIBUTED',
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.6),
                        ),
                        Text('KES ${total.toStringAsFixed(0)}', style: AppTextStyles.heading1.copyWith(fontSize: 24)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (contributions.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(child: Text('No contributions yet', style: AppTextStyles.caption)),
                    )
                  else
                    ...contributions.map((c) => _ContributionTile(contribution: c)),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              error is ApiException ? error.message : 'Failed to load contributions',
              style: AppTextStyles.body,
            ),
          ),
        ),
      ),
    );
  }
}

class _ContributionTile extends StatelessWidget {
  const _ContributionTile({required this.contribution});

  final Contribution contribution;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.check_circle_outline, color: AppColors.green, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contribution.periodMonth, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
                if (contribution.paidAt != null)
                  Text(DateFormat.yMMMd().format(contribution.paidAt!), style: AppTextStyles.caption),
                Text('Receipt: ${contribution.mpesaReceipt}', style: AppTextStyles.caption),
              ],
            ),
          ),
          Text(
            'KES ${contribution.amount.toStringAsFixed(0)}',
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
