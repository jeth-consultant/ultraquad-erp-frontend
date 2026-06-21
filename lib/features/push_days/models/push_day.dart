/// A single day's GitHub push activity record, as returned by
/// GET /me/push-days.
class PushDay {
  const PushDay({
    required this.id,
    required this.date,
    required this.commitsCount,
    required this.satisfied,
  });

  final int id;
  final String date;
  final int commitsCount;
  final bool satisfied;

  factory PushDay.fromJson(Map<String, dynamic> json) {
    return PushDay(
      id: (json['id'] as num?)?.toInt() ?? 0,
      date: json['date'] as String? ?? '',
      commitsCount: (json['commits_count'] as num?)?.toInt() ?? 0,
      satisfied: json['satisfied'] as bool? ?? false,
    );
  }
}
