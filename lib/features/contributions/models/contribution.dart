/// A single recorded contribution payment, as returned by
/// GET /me/contributions.
class Contribution {
  const Contribution({
    required this.id,
    required this.amount,
    required this.mpesaReceipt,
    required this.paidAt,
    required this.periodMonth,
  });

  final int id;
  final double amount;
  final String mpesaReceipt;
  final DateTime? paidAt;
  final String periodMonth;

  factory Contribution.fromJson(Map<String, dynamic> json) {
    return Contribution(
      id: (json['id'] as num?)?.toInt() ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0,
      mpesaReceipt: json['mpesa_receipt'] as String? ?? '',
      paidAt: json['paid_at'] != null ? DateTime.tryParse(json['paid_at'] as String) : null,
      periodMonth: json['period_month'] as String? ?? '',
    );
  }
}
