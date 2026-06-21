import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/url_helper.dart';
import '../models/profile.dart';

/// Loads and updates the signed-in member's profile (GET/PATCH /profile)
/// and registers push-notification device tokens.
class ProfileNotifier extends StateNotifier<AsyncValue<Profile>> {
  ProfileNotifier(this._apiClient, this._urlHelper) : super(const AsyncValue.loading()) {
    fetchProfile();
  }

  final ApiClient _apiClient;
  final UrlHelper _urlHelper;

  Future<void> fetchProfile() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _apiClient.guard(
        () => _apiClient.dio.get(_urlHelper.me),
        (data) => Profile.fromJson(data as Map<String, dynamic>),
      );
      state = AsyncValue.data(profile);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<Profile> updateProfile({
    String? name,
    String? email,
    String? githubUsername,
  }) async {
    final profile = await _apiClient.guard(
      () => _apiClient.dio.patch(
        _urlHelper.me,
        data: {
          'name': ?name,
          'email': ?email,
          'github_username': ?githubUsername,
        },
      ),
      (data) => Profile.fromJson(data as Map<String, dynamic>),
    );
    state = AsyncValue.data(profile);
    return profile;
  }

  Future<void> registerDeviceToken({
    required String token,
    required String platform,
  }) async {
    await _apiClient.guard(
      () => _apiClient.dio.post(
        _urlHelper.meDeviceToken,
        data: {'token': token, 'platform': platform},
      ),
      (data) => data,
    );
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<Profile>>((ref) {
  return ProfileNotifier(ref.watch(apiClientProvider), ref.watch(urlHelperProvider));
});
