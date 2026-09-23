import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/local_storage.dart';
import 'api_constants.dart';

class DioClient {
  static Dio? _dio;

  static Dio get instance {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {"Content-Type": "application/json"},
        ),
      );

      // Auth Header Interceptor
      _dio!.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final userId = await LocalStorage.getUserId();
            final token = await LocalStorage.getToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            if (userId != null && userId.isNotEmpty) {
              options.headers['x-user-id'] = userId;
            }
            return handler.next(options);
          },
          onError: (DioException error, handler) async {
            if (error.response?.statusCode == 401) {
              // Handle unauthorized session expiration globally if needed
              debugPrint("DioClient: 401 Unauthorized detected. Clearing session.");
              await LocalStorage.clear();
            }
            return handler.next(error);
          },
        ),
      );

      // Security: Enable request/response body logging ONLY in debug mode
      if (kDebugMode) {
        _dio!.interceptors.add(
          LogInterceptor(requestBody: true, responseBody: true),
        );
      }
    }
    return _dio!;
  }
}

