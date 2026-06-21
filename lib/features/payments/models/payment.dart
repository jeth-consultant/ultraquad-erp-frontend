/// Result of POST /payments/initiate: an M-Pesa STK push has been sent
/// to the member's phone.
class PaymentInitiation {
  const PaymentInitiation({
    required this.checkoutRequestId,
    required this.merchantRequestId,
    required this.customerMessage,
  });

  final String checkoutRequestId;
  final String merchantRequestId;
  final String customerMessage;

  factory PaymentInitiation.fromJson(Map<String, dynamic> json) {
    return PaymentInitiation(
      checkoutRequestId: json['checkoutRequestId'] as String? ?? '',
      merchantRequestId: json['merchantRequestId'] as String? ?? '',
      customerMessage: json['customerMessage'] as String? ?? '',
    );
  }
}

/// Result of GET /payments/:checkoutRequestId/status.
class PaymentStatus {
  const PaymentStatus({
    required this.status,
    required this.resultDesc,
    required this.mpesaReceipt,
  });

  final String status;
  final String? resultDesc;
  final String? mpesaReceipt;

  bool get isPending => status == 'pending';
  bool get isSuccess => status == 'success';

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      status: json['status'] as String? ?? 'pending',
      resultDesc: json['resultDesc'] as String?,
      mpesaReceipt: json['mpesaReceipt'] as String?,
    );
  }
}
