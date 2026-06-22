import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/api/api_exception.dart';
import '../../core/navigation/app_section.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_drawer.dart';
import 'models/push_day.dart';
import 'providers/push_days_provider.dart';

/// Shows the signed-in member's GitHub push activity (GET /me/push-days).
class PushDaysScreen extends ConsumerWidget {
  const PushDaysScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pushDaysAsync = ref.watch(pushDaysProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Push Days')),
      drawer: const AppDrawer(current: AppSection.pushDays),
      body: SafeArea(
        child: pushDaysAsync.when(
          data: (pushDays) {
            if (pushDays.isEmpty) {
              return Center(child: Text('No push activity recorded yet', style: AppTextStyles.caption));
            }
            return RefreshIndicator(
              onRefresh: () => ref.refresh(pushDaysProvider.future),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pushDays.length,
                itemBuilder: (context, index) => _PushDayTile(pushDay: pushDays[index]),
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              error is ApiException ? error.message : 'Failed to load push days',
              style: AppTextStyles.body,
            ),
          ),
        ),
      ),
    );
  }
}

class _PushDayTile extends StatelessWidget {
  const _PushDayTile({required this.pushDay});

  final PushDay pushDay;

  @override
  Widget build(BuildContext context) {
    final color = pushDay.satisfied ? AppColors.green : AppColors.red;
    final date = DateTime.tryParse(pushDay.date);

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
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              pushDay.satisfied ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              date != null ? DateFormat.yMMMd().format(date) : pushDay.date,
              style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '${pushDay.commitsCount} commit${pushDay.commitsCount == 1 ? '' : 's'}',
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }
}
