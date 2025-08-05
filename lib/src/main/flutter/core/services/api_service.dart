import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  late final Dio _dio;
  
  static const Duration _connectTimeout = Duration(seconds: 10);
  static const Duration _receiveTimeout = Duration(seconds: 30);

  ApiService() {
    _dio = Dio(BaseOptions(
      connectTimeout: _connectTimeout,
      receiveTimeout: _receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'WishGO-List/1.0.0',
      },
    ));

    // Add interceptors
    _addInterceptors();
  }

  void _addInterceptors() {
    // Request interceptor for logging
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (kDebugMode) {
          debugPrint('🌐 REQUEST: ${options.method} ${options.uri}');
          debugPrint('📤 Headers: ${options.headers}');
          if (options.data != null) {
            debugPrint('📤 Data: ${options.data}');
          }
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          debugPrint('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}');
          debugPrint('📥 Data: ${response.data}');
        }
        handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          debugPrint('❌ ERROR: ${error.requestOptions.method} ${error.requestOptions.uri}');
          debugPrint('❌ Message: ${error.message}');
          if (error.response != null) {
            debugPrint('❌ Response: ${error.response?.data}');
          }
        }
        handler.next(error);
      },
    ));

    // Retry interceptor
    _dio.interceptors.add(RetryInterceptor());
  }

  // Generic GET request
  Future<ApiResponse<T>> get<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        url,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      
      return ApiResponse<T>.success(
        data: fromJson != null ? fromJson(response.data) : response.data as T,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>.error(message: e.toString());
    }
  }

  // Generic POST request
  Future<ApiResponse<T>> post<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      
      return ApiResponse<T>.success(
        data: fromJson != null ? fromJson(response.data) : response.data as T,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>.error(message: e.toString());
    }
  }

  // Generic PUT request
  Future<ApiResponse<T>> put<T>(
    String url, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        url,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      
      return ApiResponse<T>.success(
        data: fromJson != null ? fromJson(response.data) : response.data as T,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>.error(message: e.toString());
    }
  }

  // Generic DELETE request
  Future<ApiResponse<T>> delete<T>(
    String url, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        url,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      
      return ApiResponse<T>.success(
        data: fromJson != null ? fromJson(response.data) : response.data as T,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>.error(message: e.toString());
    }
  }

  // Download file
  Future<ApiResponse<String>> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      await _dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
      
      return ApiResponse<String>.success(
        data: savePath,
        statusCode: 200,
      );
    } on DioException catch (e) {
      return _handleError<String>(e);
    } catch (e) {
      return ApiResponse<String>.error(message: e.toString());
    }
  }

  // Upload file
  Future<ApiResponse<T>> uploadFile<T>(
    String url,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final formData = FormData.fromMap({
        ...?data,
        fieldName: await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(
        url,
        data: formData,
        onSendProgress: onSendProgress,
      );
      
      return ApiResponse<T>.success(
        data: fromJson != null ? fromJson(response.data) : response.data as T,
        statusCode: response.statusCode ?? 200,
      );
    } on DioException catch (e) {
      return _handleError<T>(e);
    } catch (e) {
      return ApiResponse<T>.error(message: e.toString());
    }
  }

  ApiResponse<T> _handleError<T>(DioException error) {
    String message;
    int statusCode = 0;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.sendTimeout:
        message = 'Send timeout. Please try again.';
        break;
      case DioExceptionType.receiveTimeout:
        message = 'Receive timeout. Please try again.';
        break;
      case DioExceptionType.badResponse:
        statusCode = error.response?.statusCode ?? 0;
        message = _getErrorMessageFromResponse(error.response);
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection. Please check your network settings.';
        break;
      case DioExceptionType.badCertificate:
        message = 'Certificate error. Unable to verify server identity.';
        break;
      case DioExceptionType.unknown:
      default:
        if (error.error is SocketException) {
          message = 'No internet connection. Please check your network settings.';
        } else {
          message = error.message ?? 'An unexpected error occurred.';
        }
        break;
    }

    return ApiResponse<T>.error(
      message: message,
      statusCode: statusCode,
    );
  }

  String _getErrorMessageFromResponse(Response? response) {
    if (response == null) return 'Unknown error occurred.';

    switch (response.statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Access denied. You don\'t have permission.';
      case 404:
        return 'Resource not found.';
      case 408:
        return 'Request timeout. Please try again.';
      case 429:
        return 'Too many requests. Please wait and try again.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
        return 'Bad gateway. Service temporarily unavailable.';
      case 503:
        return 'Service unavailable. Please try again later.';
      default:
        // Try to extract error message from response body
        try {
          final data = response.data;
          if (data is Map<String, dynamic>) {
            return data['message'] ?? data['error'] ?? 'Unknown error occurred.';
          }
        } catch (e) {
          // Ignore parsing errors
        }
        return 'Error ${response.statusCode}: ${response.statusMessage ?? 'Unknown error'}';
    }
  }

  void dispose() {
    _dio.close();
  }
}

class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool isSuccess;
  final int statusCode;

  const ApiResponse._({
    this.data,
    this.message,
    required this.isSuccess,
    required this.statusCode,
  });

  factory ApiResponse.success({
    required T data,
    required int statusCode,
  }) {
    return ApiResponse._(
      data: data,
      isSuccess: true,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.error({
    required String message,
    int statusCode = 0,
  }) {
    return ApiResponse._(
      message: message,
      isSuccess: false,
      statusCode: statusCode,
    );
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'ApiResponse.success(data: $data, statusCode: $statusCode)';
    } else {
      return 'ApiResponse.error(message: $message, statusCode: $statusCode)';
    }
  }
}

class RetryInterceptor extends Interceptor {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 1);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    
    // Check if we should retry
    if (_shouldRetry(err) && _getRetryCount(requestOptions) < maxRetries) {
      // Increment retry count
      requestOptions.extra['retryCount'] = _getRetryCount(requestOptions) + 1;
      
      // Wait before retrying
      await Future.delayed(retryDelay * _getRetryCount(requestOptions));
      
      try {
        // Retry the request
        final response = await Dio().fetch(requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // If retry fails, continue with the original error
      }
    }
    
    handler.next(err);
  }

  bool _shouldRetry(DioException error) {
    // Only retry for network errors and 5xx server errors
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.connectionError ||
           (error.response?.statusCode != null && 
            error.response!.statusCode! >= 500);
  }

  int _getRetryCount(RequestOptions requestOptions) {
    return requestOptions.extra['retryCount'] ?? 0;
  }
}