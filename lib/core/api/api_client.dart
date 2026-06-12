import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_endpoints.dart';
import 'api_exception.dart';
import 'token_storage.dart';

/// Thin wrapper around [Dio] that attaches the access token to every
/// request and transparently refreshes it on a 401 response.
class ApiClient {
  ApiClient({TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorage(),
        dio = Dio(
          BaseOptions(
            baseUrl: ApiEndpoints.baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {'Content-Type': 'application/json'},
          ),
        ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 && !_isRefreshing) {
            final refreshed = await _refreshAccessToken();
            if (refreshed) {
              final retryRequest = await _retry(error.requestOptions);
              return handler.resolve(retryRequest);
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio dio;
  final TokenStorage _tokenStorage;
  bool _isRefreshing = false;

  Future<bool> _refreshAccessToken() async {
    final refreshToken = await _tokenStorage.refreshToken;
    if (refreshToken == null) return false;

    _isRefreshing = true;
    try {
      final response = await dio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': null}),
      );
      final newAccessToken = response.data['accessToken'] as String?;
      final newRefreshToken = response.data['refreshToken'] as String?;
      if (newAccessToken == null) return false;

      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken ?? refreshToken,
      );
      return true;
    } catch (_) {
      await _tokenStorage.clear();
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await _tokenStorage.accessToken;
    final options = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Wraps a request, converting [DioException]s into [ApiException]s.
  Future<T> guard<T>(Future<Response<dynamic>> Function() request,
      T Function(dynamic data) onSuccess) async {
    try {
      final response = await request();
      return onSuccess(response.data);
    } on DioException catch (e) {
      throw ApiException(
        message: e.response?.data?['message'] as String? ?? e.message ?? 'Request failed',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    }
  }
}

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(tokenStorage: ref.watch(tokenStorageProvider));
});
