import 'package:dio/dio.dart';
import 'end_points.dart';

class ApiClient {
  late Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: EndPoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Logging Interceptor
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
    
    // Future: Add Auth Interceptor here for Bearer tokens
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    // Custom error handling logic based on status codes
    return Exception(e.message ?? 'Unknown error occurred');
  }
}
