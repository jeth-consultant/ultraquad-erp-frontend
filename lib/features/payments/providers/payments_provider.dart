import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/url_helper.dart';
import '../models/payment.dart';

/// Drives the "make a payment" flow: initiates an M-Pesa STK push and
/// polls its status (POST /payments/initiate, GET
/// /payments/:checkoutRequestId/status).
class PaymentsNotifier extends StateNotifier<AsyncValue<PaymentStatus?>> {
  PaymentsNotifier(this._apiClient, this._urlHelper) : super(const AsyncValue.data(null));

  final ApiClient _apiClient;
  final UrlHelper _urlHelper;

  Future<PaymentInitiation> initiate({required double amount, String? phone}) async {
    state = const AsyncValue.loading();
    try {
      final initiation = await _apiClient.guard(
        () => _apiClient.dio.post(
          _urlHelper.paymentsInitiate,
          data: {'amount': amount, if (phone != null && phone.isNotEmpty) 'phone': phone},
        ),
        (data) => PaymentInitiation.fromJson(data as Map<String, dynamic>),
      );
      state = const AsyncValue.data(
        PaymentStatus(status: 'pending', resultDesc: null, mpesaReceipt: null),
      );
      return initiation;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<PaymentStatus> checkStatus(String checkoutRequestId) async {
    final status = await _apiClient.guard(
      () => _apiClient.dio.get(_urlHelper.paymentStatus(checkoutRequestId)),
      (data) => PaymentStatus.fromJson(data as Map<String, dynamic>),
    );
    state = AsyncValue.data(status);
    return status;
  }

  void reset() => state = const AsyncValue.data(null);
}

final paymentsProvider = StateNotifierProvider<PaymentsNotifier, AsyncValue<PaymentStatus?>>((ref) {
  return PaymentsNotifier(ref.watch(apiClientProvider), ref.watch(urlHelperProvider));
});
