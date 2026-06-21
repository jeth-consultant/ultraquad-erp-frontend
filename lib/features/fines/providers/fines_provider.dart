import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/url_helper.dart';
import '../models/fine.dart';

/// Fetches the signed-in member's fines from GET /me/fines.
final finesProvider = FutureProvider<List<Fine>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  final urlHelper = ref.watch(urlHelperProvider);
  return apiClient.guard(
    () => apiClient.dio.get(urlHelper.myFines),
    (data) => (data as List<dynamic>)
        .map((item) => Fine.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
});
