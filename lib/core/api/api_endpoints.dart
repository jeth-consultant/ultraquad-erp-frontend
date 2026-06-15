/// Endpoint paths for the Ultraquad ERP API.
///
/// The base URL (host/port) is intentionally not defined here — it is
/// loaded from the `.env` file via [baseUrlProvider] so it never appears
/// as a hardcoded value in source.
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';
  static const String me = '/auth/me';

  // Dashboard
  static const String dashboardSummary = '/dashboard/summary';

  // Contributions
  static const String contributions = '/contributions';

  // Fines
  static const String fines = '/fines';

  // Payments
  static const String paymentsStkPush = '/payments/stk-push';
  static const String paymentsStatus = '/payments/status';
  static const String paymentsHistory = '/payments/history';

  // GitHub activity
  static const String githubActivity = '/github/activity';

  // Notifications
  static const String notifications = '/notifications';
  static const String notificationsRegisterDevice =
      '/notifications/register-device';

  // Profile
  static const String profile = '/profile';
  static const String profileDeviceToken = '/profile/device-token';

  // Admin
  static const String adminMembers = '/admin/members';
  static const String adminSettings = '/admin/settings';
  static const String adminBroadcasts = '/admin/broadcasts';
  static const String adminCsvExport = '/admin/export';
}
