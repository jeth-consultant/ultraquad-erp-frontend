import '../contributions/models/contribution.dart';
import '../fines/models/fine.dart';
import '../push_days/models/push_day.dart';

/// Stats shown on the home screen, computed client-side from the real
/// contributions/fines/push-days endpoints — there is no dedicated
/// dashboard-summary endpoint on the backend.
class DashboardStats {
  const DashboardStats({
    required this.thisMonthContribution,
    required this.lastMonthContribution,
    required this.pendingFines,
    required this.pendingFinesCount,
    required this.daysActiveThisMonth,
    required this.lastPushDate,
    required this.lastContribution,
  });

  final double thisMonthContribution;
  final double lastMonthContribution;
  final double pendingFines;
  final int pendingFinesCount;
  final int daysActiveThisMonth;
  final DateTime? lastPushDate;
  final Contribution? lastContribution;

  static const _monthlyTarget = 30;
  int get monthlyTarget => _monthlyTarget;

  /// Percentage change vs. last month, or null if there's nothing to
  /// compare against (avoids a fabricated +∞%/+100% on a brand-new
  /// member's first contribution).
  int? get contributionTrendPercent {
    if (lastMonthContribution <= 0) return null;
    return (((thisMonthContribution - lastMonthContribution) / lastMonthContribution) * 100).round();
  }

  static DashboardStats compute({
    required List<Contribution> contributions,
    required List<Fine> fines,
    required List<PushDay> pushDays,
  }) {
    final now = DateTime.now();
    final thisPeriod = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final lastMonthDate = DateTime(now.year, now.month - 1);
    final lastPeriod = '${lastMonthDate.year}-${lastMonthDate.month.toString().padLeft(2, '0')}';

    final thisMonthContribution =
        contributions.where((c) => c.periodMonth == thisPeriod).fold<double>(0, (sum, c) => sum + c.amount);
    final lastMonthContribution =
        contributions.where((c) => c.periodMonth == lastPeriod).fold<double>(0, (sum, c) => sum + c.amount);

    final unpaidFines = fines.where((f) => f.isUnpaid);
    final pendingFines = unpaidFines.fold<double>(0, (sum, f) => sum + f.amount);

    final daysActiveThisMonth = pushDays.where((p) {
      if (!p.satisfied) return false;
      final date = DateTime.tryParse(p.date);
      return date != null && date.year == now.year && date.month == now.month;
    }).length;

    DateTime? lastPushDate;
    for (final pushDay in pushDays) {
      final date = DateTime.tryParse(pushDay.date);
      if (date != null && (lastPushDate == null || date.isAfter(lastPushDate))) {
        lastPushDate = date;
      }
    }

    Contribution? lastContribution;
    for (final contribution in contributions) {
      if (contribution.paidAt == null) continue;
      if (lastContribution == null || contribution.paidAt!.isAfter(lastContribution.paidAt!)) {
        lastContribution = contribution;
      }
    }

    return DashboardStats(
      thisMonthContribution: thisMonthContribution,
      lastMonthContribution: lastMonthContribution,
      pendingFines: pendingFines,
      pendingFinesCount: unpaidFines.length,
      daysActiveThisMonth: daysActiveThisMonth,
      lastPushDate: lastPushDate,
      lastContribution: lastContribution,
    );
  }
}

/// "Today" / "Yesterday" / "N days ago" — relative day text without
/// fabricating a time-of-day we don't have.
String relativeDayLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final diff = today.difference(target).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff > 1) return '$diff days ago';
  return 'In the future';
}
