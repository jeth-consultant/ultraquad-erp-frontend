/// A fine levied against the signed-in member, as returned by
/// GET /me/fines.
class Fine {
  const Fine({
    required this.id,
    required this.reason,
    required this.amount,
    required this.dateIncurred,
    required this.status,
    required this.paidWithReceipt,
  });

  final int id;
  final String reason;
  final double amount;
  final String dateIncurred;
  final String status;
  final String? paidWithReceipt;

  bool get isUnpaid => status == 'unpaid';

  factory Fine.fromJson(Map<String, dynamic> json) {
    return Fine(
      id: (json['id'] as num?)?.toInt() ?? 0,
      reason: json['reason'] as String? ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '') ?? 0,
      dateIncurred: json['date_incurred'] as String? ?? '',
      status: json['status'] as String? ?? 'unpaid',
      paidWithReceipt: json['paid_with_receipt'] as String?,
    );
  }
}
