import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/url_helper.dart';
import '../models/contribution.dart';

/// Fetches the signed-in member's contribution history from
/// GET /me/contributions.
final contributionsProvider = FutureProvider<List<Contribution>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final urlHelper = ref.watch(urlHelperProvider);
  return apiClient.guard(
    () => apiClient.dio.get(
      urlHelper.myContributions,
      queryParameters: {'limit': 100, 'offset': 0},
    ),
    (data) => (data as List<dynamic>)
        .map((item) => Contribution.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
});
