/// A single missed contribution month and the amount owed for it.
class MissedMonth {
  const MissedMonth({required this.label, required this.amount});

  final String label;
  final double amount;

  factory MissedMonth.fromJson(Map<String, dynamic> json) {
    return MissedMonth(
      label: json['label'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Aggregated stats shown on the home/dashboard screen.
class DashboardSummary {
  const DashboardSummary({
    required this.totalContributions,
    required this.outstandingFines,
    required this.githubPushesToday,
    required this.unreadNotifications,
    this.missedMonths = const [],
  });

  final double totalContributions;
  final double outstandingFines;
  final int githubPushesToday;
  final int unreadNotifications;
  final List<MissedMonth> missedMonths;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalContributions:
          (json['totalContributions'] as num?)?.toDouble() ?? 0,
      outstandingFines: (json['outstandingFines'] as num?)?.toDouble() ?? 0,
      githubPushesToday: (json['githubPushesToday'] as num?)?.toInt() ?? 0,
      unreadNotifications:
          (json['unreadNotifications'] as num?)?.toInt() ?? 0,
      missedMonths: (json['missedMonths'] as List<dynamic>?)
              ?.map((m) => MissedMonth.fromJson(m as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  static const empty = DashboardSummary(
    totalContributions: 0,
    outstandingFines: 0,
    githubPushesToday: 0,
    unreadNotifications: 0,
  );
}
