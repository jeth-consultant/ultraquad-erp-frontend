/// An in-app notification for the signed-in member, as returned by
/// GET /me/notifications.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.sentAt,
    required this.readAt,
  });

  final int id;
  final String title;
  final String body;
  final String type;
  final DateTime? sentAt;
  final DateTime? readAt;

  bool get isUnread => readAt == null;

  AppNotification copyWith({DateTime? readAt}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      type: type,
      sentAt: sentAt,
      readAt: readAt ?? this.readAt,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      type: json['type'] as String? ?? '',
      sentAt: json['sent_at'] != null ? DateTime.tryParse(json['sent_at'] as String) : null,
      readAt: json['read_at'] != null ? DateTime.tryParse(json['read_at'] as String) : null,
    );
  }
}
