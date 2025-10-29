import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Singleton DioClient for handling all HTTP requests
/// Features:
/// - Automatic auth token injection
/// - Token refresh on 401
/// - Environment-based configuration
/// - Request/Response logging
/// - Secure token storage
class DioClient {
  static final DioClient _instance = DioClient._internal();
  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Singleton pattern
  factory DioClient() => _instance;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        // Base URL from environment variables
        baseUrl: dotenv.env['BASE_URL'] ?? 'https://api.example.com',
        
        // Timeouts
        connectTimeout: Duration(
          milliseconds: int.parse(dotenv.env['API_TIMEOUT'] ?? '30000'),
        ),
        receiveTimeout: Duration(
          milliseconds: int.parse(dotenv.env['API_TIMEOUT'] ?? '30000'),
        ),
        sendTimeout: Duration(
          milliseconds: int.parse(dotenv.env['API_TIMEOUT'] ?? '30000'),
        ),
        
        // Default headers
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        
        // Response type
        responseType: ResponseType.json,
        
        // Receive data when status code is not 2xx
        validateStatus: (status) {
          return status! < 500;
        },
      ),
    );

    _setupInterceptors();
  }

  /// Setup all interceptors
  void _setupInterceptors() {
    // Auth & API Key Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token from secure storage
          final token = await _storage.read(key: 'auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Add API key from env if needed
          final apiKey = dotenv.env['API_KEY'];
          if (apiKey != null && apiKey.isNotEmpty) {
            options.headers['X-API-Key'] = apiKey;
          }

          // Add custom headers if needed
          // options.headers['X-Platform'] = 'mobile';
          // options.headers['X-App-Version'] = '1.0.0';

          return handler.next(options);
        },
        
        onResponse: (response, handler) {
          // Handle successful responses
          return handler.next(response);
        },
        
        onError: (error, handler) async {
          // Handle 401 Unauthorized - refresh token logic
          if (error.response?.statusCode == 401) {
            // Attempt to refresh token
            if (await _refreshToken()) {
              // Retry the original request with new token
              try {
                final response = await _retry(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.reject(error);
              }
            } else {
              // Refresh failed, clear tokens
              await clearTokens();
            }
          }
          
          return handler.next(error);
        },
      ),
    );

    // Pretty logger for development (disable in production)
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ),
    );
  }

  /// Refresh token logic
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      // Create a new Dio instance without interceptors for refresh request
      final refreshDio = Dio(BaseOptions(
        baseUrl: _dio.options.baseUrl,
      ));

      final response = await refreshDio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];
        
        if (newToken != null) {
          await _storage.write(key: 'auth_token', value: newToken);
        }
        if (newRefreshToken != null) {
          await _storage.write(key: 'refresh_token', value: newRefreshToken);
        }
        
        return true;
      }
    } catch (e) {
      // Refresh failed, clear all tokens
      await _storage.deleteAll();
    }
    return false;
  }

  /// Retry failed request with new token
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    // Get the new token
    final token = await _storage.read(key: 'auth_token');
    
    // Update the authorization header
    if (token != null) {
      requestOptions.headers['Authorization'] = 'Bearer $token';
    }

    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  /// Get Dio instance
  Dio get dio => _dio;

  /// Get base URL
  String get baseUrl => _dio.options.baseUrl;

  /// Update base URL dynamically
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }

  // ==================== Secure Storage Helpers ====================

  /// Save authentication tokens
  Future<void> saveToken(String token, {String? refreshToken}) async {
    await _storage.write(key: 'auth_token', value: token);
    if (refreshToken != null) {
      await _storage.write(key: 'refresh_token', value: refreshToken);
    }
  }

  /// Get auth token
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all tokens
  Future<void> clearTokens() async {
    await _storage.delete(key: 'auth_token');
    await _storage.delete(key: 'refresh_token');
  }

  /// Save any key-value pair securely
  Future<void> saveSecure(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  /// Read secure value
  Future<String?> readSecure(String key) async {
    return await _storage.read(key: key);
  }

  /// Delete secure value
  Future<void> deleteSecure(String key) async {
    await _storage.delete(key: key);
  }

  /// Clear all secure storage
  Future<void> clearAllSecureStorage() async {
    await _storage.deleteAll();
  }

  // ==================== Convenience Methods ====================

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return await _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return await _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  /// Download file
  Future<Response> download(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
    CancelToken? cancelToken,
    bool deleteOnError = true,
    String lengthHeader = Headers.contentLengthHeader,
    dynamic data,
    Options? options,
  }) async {
    return await _dio.download(
      urlPath,
      savePath,
      onReceiveProgress: onReceiveProgress,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
      deleteOnError: deleteOnError,
      lengthHeader: lengthHeader,
      data: data,
      options: options,
    );
  }
}