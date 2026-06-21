import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_endpoints.dart';
import 'env_config.dart';

/// Builds full request URLs by combining a base URL (from `.env`) with
/// each endpoint path. Obtain an instance via [urlHelperProvider] so the
/// base URL is resolved through Riverpod rather than hardcoded.
class UrlHelper {
  const UrlHelper(this.baseUrl);

  final String baseUrl;

  String _build(String path) => '$baseUrl$path';

  // Auth
  String get register => _build(ApiEndpoints.register);
  String get login => _build(ApiEndpoints.login);
  String get refreshToken => _build(ApiEndpoints.refreshToken);
  String get logout => _build(ApiEndpoints.logout);
  String get forgotPassword => _build(ApiEndpoints.forgotPassword);
  String get sendOtp => _build(ApiEndpoints.sendOtp);
  String get verifyOtp => _build(ApiEndpoints.verifyOtp);
  String get resetPassword => _build(ApiEndpoints.resetPassword);

  // Profile
  String get me => _build(ApiEndpoints.me);
  String get meDeviceToken => _build(ApiEndpoints.meDeviceToken);

  // Contributions
  String get myContributions => _build(ApiEndpoints.myContributions);

  // Fines
  String get myFines => _build(ApiEndpoints.myFines);

  // Notifications
  String get myNotifications => _build(ApiEndpoints.myNotifications);
  String myNotificationRead(int id) =>
      _build(ApiEndpoints.myNotificationRead(id));
  String get myNotificationsReadAll =>
      _build(ApiEndpoints.myNotificationsReadAll);

  // Push days
  String get myPushDays => _build(ApiEndpoints.myPushDays);

  // Payments
  String get paymentsInitiate => _build(ApiEndpoints.paymentsInitiate);
  String paymentStatus(String checkoutRequestId) =>
      _build(ApiEndpoints.paymentStatus(checkoutRequestId));
}

/// Riverpod-resolved [UrlHelper], built from [baseUrlProvider] so every
/// endpoint URL ultimately derives from `.env`.
final urlHelperProvider = Provider<UrlHelper>((ref) {
  return UrlHelper(ref.watch(baseUrlProvider));
});
