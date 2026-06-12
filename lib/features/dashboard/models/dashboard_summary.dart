/// Aggregated stats shown on the home/dashboard screen.
class DashboardSummary {
  const DashboardSummary({
    required this.totalContributions,
    required this.outstandingFines,
    required this.githubPushesToday,
    required this.unreadNotifications,
  });

  final double totalContributions;
  final double outstandingFines;
  final int githubPushesToday;
  final int unreadNotifications;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalContributions:
          (json['totalContributions'] as num?)?.toDouble() ?? 0,
      outstandingFines: (json['outstandingFines'] as num?)?.toDouble() ?? 0,
      githubPushesToday: (json['githubPushesToday'] as num?)?.toInt() ?? 0,
      unreadNotifications:
          (json['unreadNotifications'] as num?)?.toInt() ?? 0,
    );
  }

  static const empty = DashboardSummary(
    totalContributions: 0,
    outstandingFines: 0,
    githubPushesToday: 0,
    unreadNotifications: 0,
  );
}
