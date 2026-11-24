import 'dart:async';
import 'package:dio/dio.dart';
import 'package:eism/core/managers/auth_session_manager.dart';
import 'package:flutter/foundation.dart';
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

    // Logging Interceptor (Production Safe: requestBody & responseBody set to false so passwords/tokens are not logged)
    _dio.interceptors.add(LogInterceptor(
      requestHeader: false,
      requestBody: false,
      responseHeader: false,
      responseBody: false,
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
    if (e.response != null) {
      if (e.response?.statusCode == 417) {
        if (kDebugMode) {
          debugPrint('[API 417] Server response: ${e.response?.data}');
        }
        final bool isLoginRequest = e.requestOptions.path.contains(EndPoints.login) ||
            e.requestOptions.path.contains('Parent/Login');
        if (!isLoginRequest) {
          unawaited(AuthSessionManager.handle417AuthFailure());
        }
      }
      return ApiException(
        message: e.message ?? 'Unknown error occurred',
        statusCode: e.response?.statusCode,
        responseData: e.response?.data,
      );
    }
    return Exception(e.message ?? 'Unknown error occurred');
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic responseData;

  ApiException({
    required this.message,
    this.statusCode,
    this.responseData,
  });

  @override
  String toString() => message;
}
