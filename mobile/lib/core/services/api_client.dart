import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/api_response.dart';
import 'storage_service.dart';
import '../constants/app_constants.dart';

class ApiClient {
  late final Dio _dio;
  final StorageService _storageService = StorageService();
  bool _isRefreshing = false;
  final List<RequestOptions> _requestQueue = [];

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
          print('Headers: ${options.headers}');
          print('Data: ${options.data}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            'RESPONSE[${response.statusCode}] => ${response.requestOptions.uri}',
          );
          print('Response Data: ${response.data}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          print(
            'ERROR[${error.response?.statusCode}] => ${error.requestOptions.uri}',
          );
          print('Error Message: ${error.message}');
          print('Error Response: ${error.response?.data}');

          if (error.response?.statusCode == 401) {
            final requestOptions = error.requestOptions;

            // Tránh refresh token cho endpoint refresh/login/register
            if (requestOptions.path.contains('/refresh') ||
                requestOptions.path.contains('/login') ||
                requestOptions.path.contains('/register')) {
              return handler.next(error);
            }

            // Nếu đang refresh, thêm request vào queue
            if (_isRefreshing) {
              _requestQueue.add(requestOptions);
              return handler.reject(error);
            }

            _isRefreshing = true;

            try {
              // Lấy refresh token từ storage
              final refreshToken = await _storageService.getRefreshToken();

              if (refreshToken == null) {
                _isRefreshing = false;
                return handler.next(error);
              }

              // Gọi API refresh token
              final response = await _dio.post(
                ApiConfig.refreshToken,
                data: {'refresh_token': refreshToken},
              );

              if (response.statusCode == 200) {
                final data = response.data;
                final newAccessToken = data['access_token'];
                final newRefreshToken = data['refresh_token'];

                // Lưu token mới
                await _storageService.saveTokenWithExpiry(newAccessToken);
                await _storageService.saveRefreshToken(newRefreshToken);

                // Retry request ban đầu với token mới
                requestOptions.headers['Authorization'] =
                    'Bearer $newAccessToken';
                final retryResponse = await _dio.fetch(requestOptions);

                // Xử lý các request trong queue
                for (var req in _requestQueue) {
                  req.headers['Authorization'] = 'Bearer $newAccessToken';
                  _dio.fetch(req);
                }
                _requestQueue.clear();

                _isRefreshing = false;
                return handler.resolve(retryResponse);
              }
            } catch (e) {
              print('Refresh token failed: $e');
              // Clear tokens nếu refresh thất bại
              await _storageService.clearAll();
              _requestQueue.clear();
            }

            _isRefreshing = false;
          }

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

  // PATCH Request
  Future<ApiResponse<T>> patch<T>(
    String endpoint, {
    dynamic data,
    T Function(dynamic)? fromJsonT,
    String? token,
  }) async {
    try {
      final response = await _dio.patch(
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
    // Success status codes
    if (response.statusCode == 200 ||
        response.statusCode == 201 ||
        response.statusCode == 204) {
      final data = response.data;

      // Case 1: Response là object trực tiếp (login, register, couple check)
      if (fromJsonT != null && data is Map<String, dynamic>) {
        // Check nếu có wrapper {success, message, data}
        if (data.containsKey('success') && data.containsKey('data')) {
          // Wrapped response format
          return ApiResponse.fromJson(data, fromJsonT);
        } else {
          // Direct object response - không có wrapper
          return ApiResponse<T>(
            success: true,
            message: 'Success',
            data: fromJsonT(data),
          );
        }
      }

      // Case 2: Response có format chuẩn nhưng không có fromJsonT
      if (data is Map<String, dynamic> && data.containsKey('data')) {
        return ApiResponse.fromJson(data, fromJsonT);
      }

      // Case 3: Response là primitive type hoặc list
      if (fromJsonT != null) {
        try {
          return ApiResponse<T>(
            success: true,
            message: 'Success',
            data: fromJsonT(data),
          );
        } catch (e) {
          return ApiResponse.error(
            message: 'Failed to parse response: ${e.toString()}',
          );
        }
      }

      // Case 4: Default - treat whole response as data
      return ApiResponse<T>(
        success: true,
        message: 'Success',
        data: data as T?,
      );
    } else {
      // Non-success status codes
      return ApiResponse.error(
        message: 'Unexpected status code: ${response.statusCode}',
      );
    }
  }

  // Handle Error - Improved
  ApiResponse<T> _handleError<T>(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ApiResponse.error(message: ErrorMessages.noInternet);

        case DioExceptionType.badResponse:
          final data = error.response?.data;
          String message = ErrorMessages.serverError;
          Map<String, dynamic>? errors;

          if (data is Map<String, dynamic>) {
            // FastAPI validation error format
            if (data.containsKey('detail')) {
              final detail = data['detail'];
              if (detail is String) {
                message = detail;
              } else if (detail is List) {
                // Validation errors
                message = detail
                    .map((e) => '${e['loc']?.last ?? 'Field'}: ${e['msg']}')
                    .join(', ');
              }
            } else if (data.containsKey('message')) {
              message = data['message'];
            }

            errors = data;
          }

          return ApiResponse.error(message: message, errors: errors);

        case DioExceptionType.cancel:
          return ApiResponse.error(message: 'Request cancelled');

        case DioExceptionType.connectionError:
          return ApiResponse.error(message: ErrorMessages.noInternet);

        default:
          return ApiResponse.error(message: ErrorMessages.networkError);
      }
    }
    return ApiResponse.error(
      message: 'An unexpected error occurred: ${error.toString()}',
    );
  }
}
