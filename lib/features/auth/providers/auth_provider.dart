import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/token_storage.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.isAdmin = false,
    this.userId,
    this.fullName,
    this.email,
  });

  final AuthStatus status;
  final bool isAdmin;
  final String? userId;
  final String? fullName;
  final String? email;

  AuthState copyWith({
    AuthStatus? status,
    bool? isAdmin,
    String? userId,
    String? fullName,
    String? email,
  }) {
    return AuthState(
      status: status ?? this.status,
      isAdmin: isAdmin ?? this.isAdmin,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
    );
  }
}

/// Holds the current authentication/session state and exposes the actions
/// (login, signup, logout, etc.) that talk to the backend API.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._apiClient, this._tokenStorage) : super(const AuthState()) {
    _restoreSession();
  }

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  Future<void> _restoreSession() async {
    final token = await _tokenStorage.accessToken;
    state = state.copyWith(
      status: token != null ? AuthStatus.authenticated : AuthStatus.unauthenticated,
    );
    // TODO: fetch /auth/me to populate user details and isAdmin flag.
  }

  Future<void> login({required String email, required String password}) async {
    final data = await _apiClient.guard(
      () => _apiClient.dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      ),
      (data) => data as Map<String, dynamic>,
    );

    await _tokenStorage.saveTokens(
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
    );

    final member = data['member'] as Map<String, dynamic>;
    state = state.copyWith(
      status: AuthStatus.authenticated,
      userId: member['id'].toString(),
      fullName: member['name'] as String?,
      email: member['email'] as String?,
      isAdmin: member['role'] == 'admin',
    );
  }

  Future<void> signup({
    required String fullName,
    required String phone,
    required String email,
    required String password,
    required String githubUsername,
  }) async {
    await _apiClient.guard(
      () => _apiClient.dio.post(
        ApiEndpoints.register,
        data: {
          'name': fullName,
          'phone': phone,
          'email': email,
          'password': password,
          'github_username': githubUsername,
        },
      ),
      (data) => data,
    );
  }

  Future<void> forgotPassword({required String email}) async {
    await _apiClient.guard(
      () => _apiClient.dio.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      ),
      (data) => data,
    );
  }

  Future<void> verifyOtp({required String email, required String otp}) async {
    await _apiClient.guard(
      () => _apiClient.dio.post(
        ApiEndpoints.verifyOtp,
        data: {'email': email, 'otp': otp},
      ),
      (data) => data,
    );
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    await _apiClient.guard(
      () => _apiClient.dio.post(
        ApiEndpoints.resetPassword,
        data: {'email': email, 'otp': otp, 'password': password},
      ),
      (data) => data,
    );
  }

  Future<void> logout() async {
    await _tokenStorage.clear();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(apiClientProvider), ref.watch(tokenStorageProvider));
});
