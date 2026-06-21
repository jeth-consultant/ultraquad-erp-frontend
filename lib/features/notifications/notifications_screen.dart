import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/api/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'models/app_notification.dart';
import 'providers/notifications_provider.dart';

/// Shows the signed-in member's notifications and lets them mark one or
/// all as read (GET/PATCH /me/notifications).
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if ((notificationsAsync.valueOrNull ?? const []).any((n) => n.isUnread))
            TextButton(
              onPressed: () => ref.read(notificationsProvider.notifier).markAllRead(),
              child: const Text('Mark all read', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: SafeArea(
        child: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return Center(child: Text('No notifications yet', style: AppTextStyles.caption));
            }
            return RefreshIndicator(
              onRefresh: () => ref.read(notificationsProvider.notifier).fetch(),
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  return _NotificationTile(
                    notification: notification,
                    onTap: notification.isUnread
                        ? () => ref.read(notificationsProvider.notifier).markRead(notification.id)
                        : null,
                  );
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Text(
              error is ApiException ? error.message : 'Failed to load notifications',
              style: AppTextStyles.body,
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, this.onTap});

  final AppNotification notification;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: notification.isUnread ? AppColors.navy.withValues(alpha: 0.05) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: notification.isUnread ? AppColors.navy.withValues(alpha: 0.2) : AppColors.border,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (notification.isUnread)
              Container(
                margin: const EdgeInsets.only(top: 6, right: 10),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
              )
            else
              const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: notification.isUnread ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(notification.body, style: AppTextStyles.body.copyWith(fontSize: 13)),
                  const SizedBox(height: 6),
                  if (notification.sentAt != null)
                    Text(DateFormat.yMMMd().add_jm().format(notification.sentAt!), style: AppTextStyles.caption),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
