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
  String get verifyOtp => _build(ApiEndpoints.verifyOtp);
  String get resetPassword => _build(ApiEndpoints.resetPassword);
  String get me => _build(ApiEndpoints.me);

  // Dashboard
  String get dashboardSummary => _build(ApiEndpoints.dashboardSummary);

  // Contributions
  String get contributions => _build(ApiEndpoints.contributions);

  // Fines
  String get fines => _build(ApiEndpoints.fines);

  // Payments
  String get paymentsStkPush => _build(ApiEndpoints.paymentsStkPush);
  String get paymentsStatus => _build(ApiEndpoints.paymentsStatus);
  String get paymentsHistory => _build(ApiEndpoints.paymentsHistory);

  // GitHub activity
  String get githubActivity => _build(ApiEndpoints.githubActivity);

  // Notifications
  String get notifications => _build(ApiEndpoints.notifications);
  String get notificationsRegisterDevice =>
      _build(ApiEndpoints.notificationsRegisterDevice);

  // Profile
  String get profile => _build(ApiEndpoints.profile);
  String get profileDeviceToken => _build(ApiEndpoints.profileDeviceToken);

  // Admin
  String get adminMembers => _build(ApiEndpoints.adminMembers);
  String get adminSettings => _build(ApiEndpoints.adminSettings);
  String get adminBroadcasts => _build(ApiEndpoints.adminBroadcasts);
  String get adminCsvExport => _build(ApiEndpoints.adminCsvExport);
}

/// Riverpod-resolved [UrlHelper], built from [baseUrlProvider] so every
/// endpoint URL ultimately derives from `.env`.
final urlHelperProvider = Provider<UrlHelper>((ref) {
  return UrlHelper(ref.watch(baseUrlProvider));
});
