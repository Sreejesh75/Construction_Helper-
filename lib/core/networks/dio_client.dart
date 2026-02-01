import 'package:dio/dio.dart';
import 'api_constants.dart';

class DioClient {
  static Dio? _dio;

  static Dio get instance {
    if (_dio == null) {
      _dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {"Content-Type": "application/json"},
        ),
      );

      //  Logging (dev only)
      _dio!.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: true),
      );
    }
    return _dio!;
  }
}
