import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(milliseconds: ApiConfig.connectTimeout),
        receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeout),
        headers: ApiConfig.headers,
      ),
    );

    // Interceptors để log và handle errors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('REQUEST[${options.method}] => ${options.uri}');
          print('Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            'RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}',
          );
          return handler.next(response);
        },
        onError: (error, handler) {
          print(
            'ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}',
          );
          print('Message: ${error.message}');
          return handler.next(error);
        },
      ),
    );
  }

  // GET Request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    T Function(dynamic)? fromJsonT,
    String? token,
  }) async {
    try {
      final response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: token != null
            ? Options(headers: ApiConfig.authHeaders(token))
            : null,
      );
      return _handleResponse<T>(response, fromJsonT);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // POST Request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic data,
    T Function(dynamic)? fromJsonT,
    String? token,
  }) async {
    try {
      final response = await _dio.post(
        endpoint,
        data: data,
        options: token != null
            ? Options(headers: ApiConfig.authHeaders(token))
            : null,
      );
      return _handleResponse<T>(response, fromJsonT);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // PUT Request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic data,
    T Function(dynamic)? fromJsonT,
    String? token,
  }) async {
    try {
      final response = await _dio.put(
        endpoint,
        data: data,
        options: token != null
            ? Options(headers: ApiConfig.authHeaders(token))
            : null,
      );
      return _handleResponse<T>(response, fromJsonT);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // DELETE Request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    T Function(dynamic)? fromJsonT,
    String? token,
  }) async {
    try {
      final response = await _dio.delete(
        endpoint,
        options: token != null
            ? Options(headers: ApiConfig.authHeaders(token))
            : null,
      );
      return _handleResponse<T>(response, fromJsonT);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  // Handle Response
  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJsonT,
  ) {
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ApiResponse.fromJson(response.data, fromJsonT);
    } else {
      return ApiResponse.error(
        message: 'Unexpected status code: ${response.statusCode}',
      );
    }
  }

  // Handle Error
  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiResponse.error(
            message: 'Connection timeout. Please check your internet.',
          );
        case DioExceptionType.badResponse:
          final data = error.response?.data;
          return ApiResponse.error(
            message: data?['message'] ?? 'Server error occurred',
            errors: data?['errors'],
          );
        case DioExceptionType.cancel:
          return ApiResponse.error(message: 'Request cancelled');
        default:
          return ApiResponse.error(message: 'Network error. Please try again.');
      }
    }
    return ApiResponse.error(message: 'An unexpected error occurred');
  }
}
