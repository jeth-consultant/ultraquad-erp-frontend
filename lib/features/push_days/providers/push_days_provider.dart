import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/url_helper.dart';
import '../models/push_day.dart';

/// Fetches the signed-in member's GitHub push activity from
/// GET /me/push-days.
final pushDaysProvider = FutureProvider<List<PushDay>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final urlHelper = ref.watch(urlHelperProvider);
  return apiClient.guard(
    () => apiClient.dio.get(
      urlHelper.myPushDays,
      queryParameters: {'limit': 100, 'offset': 0},
    ),
    (data) => (data as List<dynamic>)
        .map((item) => PushDay.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
});
