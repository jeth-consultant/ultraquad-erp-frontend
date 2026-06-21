import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../payments/payment_screen.dart';
import 'models/fine.dart';
import 'providers/fines_provider.dart';

/// Shows the signed-in member's fines (GET /me/fines) with a shortcut to
/// pay off the outstanding total.
class FinesScreen extends ConsumerWidget {
  const FinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finesAsync = ref.watch(finesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('My Fines')),
      body: SafeArea(
        child: finesAsync.when(
          data: (fines) {
            final unpaidTotal = fines.where((f) => f.isUnpaid).fold<double>(0, (sum, f) => sum + f.amount);
            return RefreshIndicator(
              onRefresh: () => ref.refresh(finesProvider.future),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.red.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'OUTSTANDING FINES',
                          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0.6),
                        ),
                        Text(
                          'KES ${unpaidTotal.toStringAsFixed(0)}',
                          style: AppTextStyles.heading1.copyWith(fontSize: 24),
                        ),
                        if (unpaidTotal > 0) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PaymentScreen(prefilledAmount: unpaidTotal),
                                  ),
                                );
                              },
                              child: const Text('Pay outstanding fines'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (fines.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: Center(child: Text('No fines on record', style: AppTextStyles.caption)),
                    )
                  else
                    ...fines.map((f) => _FineTile(fine: f)),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              error is ApiException ? error.message : 'Failed to load fines',
              style: AppTextStyles.body,
            ),
          ),
        ),
      ),
    );
  }
}

class _FineTile extends StatelessWidget {
  const _FineTile({required this.fine});

  final Fine fine;

  Color get _statusColor {
    switch (fine.status) {
      case 'paid':
        return AppColors.green;
      case 'waived':
        return AppColors.textSecondary;
      default:
        return AppColors.red;
    }
  }

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
              color: _statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.warning_amber_rounded, color: _statusColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fine.reason == 'missed_push' ? 'Missed push' : 'Manual fine',
                  style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(fine.dateIncurred, style: AppTextStyles.caption),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('KES ${fine.amount.toStringAsFixed(0)}', style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700)),
              Text(
                fine.status.toUpperCase(),
                style: AppTextStyles.caption.copyWith(color: _statusColor, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
