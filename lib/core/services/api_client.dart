import 'package:dio/dio.dart';

import '../utils/logger.dart';

/// HTTP client configured with base options, timeouts, and logging.
class ApiClient {
  ApiClient({Dio? dio, String? baseUrl})
      : _dio = dio ?? Dio(),
        _baseUrl = baseUrl ?? _defaultBaseUrl {
    _configureDio();
  }

  static const String _defaultBaseUrl = 'https://api.expedition.app';

  final Dio _dio;
  final String _baseUrl;

  Dio get dio => _dio;

  void _configureDio() {
    _dio.options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (message) => AppLogger.debug(message.toString()),
      ),
    );
  }
}
