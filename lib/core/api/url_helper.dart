import 'api_endpoints.dart';

/// Builds full request URLs by combining [ApiEndpoints.baseUrl] with each
/// endpoint path. Use these getters wherever a complete URL is needed
/// (e.g. Dio requests, CSV download links).
class UrlHelper {
  UrlHelper._();

  static String _build(String path) => '${ApiEndpoints.baseUrl}$path';

  // Auth
  static String get register => _build(ApiEndpoints.register);
  static String get login => _build(ApiEndpoints.login);
  static String get refreshToken => _build(ApiEndpoints.refreshToken);
  static String get logout => _build(ApiEndpoints.logout);
  static String get forgotPassword => _build(ApiEndpoints.forgotPassword);
  static String get verifyOtp => _build(ApiEndpoints.verifyOtp);
  static String get resetPassword => _build(ApiEndpoints.resetPassword);
  static String get me => _build(ApiEndpoints.me);

  // Dashboard
  static String get dashboardSummary => _build(ApiEndpoints.dashboardSummary);

  // Contributions
  static String get contributions => _build(ApiEndpoints.contributions);

  // Fines
  static String get fines => _build(ApiEndpoints.fines);

  // Payments
  static String get paymentsStkPush => _build(ApiEndpoints.paymentsStkPush);
  static String get paymentsStatus => _build(ApiEndpoints.paymentsStatus);
  static String get paymentsHistory => _build(ApiEndpoints.paymentsHistory);

  // GitHub activity
  static String get githubActivity => _build(ApiEndpoints.githubActivity);

  // Notifications
  static String get notifications => _build(ApiEndpoints.notifications);
  static String get notificationsRegisterDevice =>
      _build(ApiEndpoints.notificationsRegisterDevice);

  // Profile
  static String get profile => _build(ApiEndpoints.profile);

  // Admin
  static String get adminMembers => _build(ApiEndpoints.adminMembers);
  static String get adminSettings => _build(ApiEndpoints.adminSettings);
  static String get adminBroadcasts => _build(ApiEndpoints.adminBroadcasts);
  static String get adminCsvExport => _build(ApiEndpoints.adminCsvExport);
}
