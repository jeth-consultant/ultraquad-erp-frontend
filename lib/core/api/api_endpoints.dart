/// Endpoint paths for the Ultraquad ERP API.
///
/// The base URL (host/port, including the `/api` prefix) is intentionally
/// not defined here — it is loaded from the `.env` file via
/// [baseUrlProvider] so it never appears as a hardcoded value in source.
///
/// Paths below mirror the backend's actual mounted routers
/// (see `src/app.ts` in the backend repo):
///   /api/auth     -> authRouter
///   /api/me       -> profileRouter (profile, contributions, fines,
///                    notifications, push-days for the signed-in member)
///   /api/payments -> paymentsRouter
class ApiEndpoints {
  ApiEndpoints._();

  // Auth
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String sendOtp = '/auth/send-otp';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resetPassword = '/auth/reset-password';

  // Profile (GET/PATCH the signed-in member)
  static const String me = '/me';
  static const String meDeviceToken = '/me/device-token';

  // Contributions (signed-in member's history)
  static const String myContributions = '/me/contributions';

  // Fines (signed-in member's fines)
  static const String myFines = '/me/fines';

  // Notifications (signed-in member's notifications)
  static const String myNotifications = '/me/notifications';
  static String myNotificationRead(int id) => '/me/notifications/$id/read';
  static const String myNotificationsReadAll = '/me/notifications/read-all';

  // Push days (signed-in member's GitHub push activity)
  static const String myPushDays = '/me/push-days';

  // Payments (M-Pesa STK push)
  static const String paymentsInitiate = '/payments/initiate';
  static String paymentStatus(String checkoutRequestId) =>
      '/payments/$checkoutRequestId/status';
}
