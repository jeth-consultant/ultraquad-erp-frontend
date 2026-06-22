import 'package:intl/intl.dart';

/// "5 minutes ago" / "3 hours ago" / "2 days ago" for recent timestamps,
/// falling back to a formatted date once it's been over a week — mirrors
/// how notification timestamps are actually available (full DateTime),
/// unlike push-day records which only carry a date.
String relativeTimeLabel(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
  if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
  if (diff.inDays < 7) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
  return DateFormat.yMMMd().format(dateTime);
}
