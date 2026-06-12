import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/url_helper.dart';
import '../models/dashboard_summary.dart';

/// Fetches the home screen summary stats (contributions, fines, GitHub
/// activity, notifications) from the backend.
final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  return apiClient.guard(
    () => apiClient.dio.get(UrlHelper.dashboardSummary),
    (data) => DashboardSummary.fromJson(data as Map<String, dynamic>),
  );
});
