/// Base configuration and endpoint paths for the Ultraquad ERP API.
class ApiEndpoints {
  ApiEndpoints._();

  /// Local backend (Express) running on port 4000.
  /// - Android emulator: use 10.0.2.2 instead of localhost.
  /// - iOS simulator / desktop / web: localhost works.
  static const String baseUrl = 'http://localhost:4000/api';

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

  // Admin
  static const String adminMembers = '/admin/members';
  static const String adminSettings = '/admin/settings';
  static const String adminBroadcasts = '/admin/broadcasts';
  static const String adminCsvExport = '/admin/export';
}
