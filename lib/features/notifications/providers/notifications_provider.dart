import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/url_helper.dart';
import '../models/app_notification.dart';

/// Loads the signed-in member's notifications and lets the UI mark one
/// or all of them as read (GET/PATCH /me/notifications).
class NotificationsNotifier extends StateNotifier<AsyncValue<List<AppNotification>>> {
  NotificationsNotifier(this._apiClient, this._urlHelper) : super(const AsyncValue.loading()) {
    fetch();
  }

  final ApiClient _apiClient;
  final UrlHelper _urlHelper;

  Future<void> fetch() async {
    state = const AsyncValue.loading();
    try {
      final notifications = await _apiClient.guard(
        () => _apiClient.dio.get(_urlHelper.myNotifications),
        (data) => (data as List<dynamic>)
            .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
      state = AsyncValue.data(notifications);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> markRead(int id) async {
    await _apiClient.guard(
      () => _apiClient.dio.patch(_urlHelper.myNotificationRead(id)),
      (data) => data,
    );
    final current = state.valueOrNull;
    if (current == null) return;
    state = AsyncValue.data([
      for (final notification in current)
        if (notification.id == id) notification.copyWith(readAt: DateTime.now()) else notification,
    ]);
  }

  Future<void> markAllRead() async {
    await _apiClient.guard(
      () => _apiClient.dio.post(_urlHelper.myNotificationsReadAll),
      (data) => data,
    );
    final current = state.valueOrNull;
    if (current == null) return;
    final now = DateTime.now();
    state = AsyncValue.data([
      for (final notification in current) notification.copyWith(readAt: notification.readAt ?? now),
    ]);
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, AsyncValue<List<AppNotification>>>((ref) {
  return NotificationsNotifier(ref.watch(apiClientProvider), ref.watch(urlHelperProvider));
});

/// Count of unread notifications, derived from [notificationsProvider].
final unreadNotificationsCountProvider = Provider<int>((ref) {
  final notifications = ref.watch(notificationsProvider).valueOrNull ?? const [];
  return notifications.where((n) => n.isUnread).length;
});
