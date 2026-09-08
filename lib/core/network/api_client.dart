import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

import 'api_endpoints.dart';

/// Standardized API response wrapper
class ApiResponse<T> {
  final bool isSuccess;
  final T? data;
  final String? errorMessage;
  final String? errorCode;
  final int statusCode;

  const ApiResponse({
    required this.isSuccess,
    this.data,
    this.errorMessage,
    this.errorCode,
    this.statusCode = 200,
  });

  factory ApiResponse.success(T data, {int statusCode = 200}) {
    return ApiResponse(isSuccess: true, data: data, statusCode: statusCode);
  }

  factory ApiResponse.failure(
    String message, {
    String? code,
    int statusCode = 400,
  }) {
    return ApiResponse(
      isSuccess: false,
      errorMessage: message,
      errorCode: code ?? 'REQUEST_FAILED',
      statusCode: statusCode,
    );
  }
}

/// Abstract API Client interface
abstract class ApiClient {
  Future<ApiResponse<Map<String, dynamic>>> get(
    String path, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  });

  Future<ApiResponse<Map<String, dynamic>>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  });
}

/// Default HTTP API Client utilizing standard HttpClient
class HttpApiClient implements ApiClient {
  final String baseUrl;
  final Duration timeout;
  final String? authToken;

  HttpApiClient({
    this.baseUrl = ApiEndpoints.defaultBaseUrl,
    this.timeout = const Duration(seconds: 10),
    this.authToken,
  });

  @override
  Future<ApiResponse<Map<String, dynamic>>> get(
    String path, {
    Map<String, String>? queryParams,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path, queryParams);
      if (kIsWeb) {
        // In web Flutter environments without dart:io socket access
        return ApiResponse.failure(
          'Direct HTTP socket client not active in web mode; utilizing local repository layer.',
          code: 'WEB_FALLBACK',
        );
      }

      final client = HttpClient()..connectionTimeout = timeout;
      final request = await client.getUrl(uri).timeout(timeout);

      _applyHeaders(request, headers);

      final response = await request.close().timeout(timeout);
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return _parseResponse(response.statusCode, responseBody);
    } on TimeoutException {
      return ApiResponse.failure(
        'Network timeout. Running in offline mode.',
        code: 'ERR_TIMEOUT',
      );
    } on SocketException catch (e) {
      return ApiResponse.failure(
        'Backend unreachable: ${e.message}. Using offline cache.',
        code: 'ERR_OFFLINE',
      );
    } catch (e) {
      return ApiResponse.failure(
        'Unexpected network error: $e',
        code: 'ERR_NETWORK',
      );
    }
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final uri = _buildUri(path);
      if (kIsWeb) {
        return ApiResponse.failure(
          'Direct HTTP socket client not active in web mode; queued for local offline sync.',
          code: 'WEB_FALLBACK',
        );
      }

      final client = HttpClient()..connectionTimeout = timeout;
      final request = await client.postUrl(uri).timeout(timeout);

      _applyHeaders(request, headers);
      request.headers.set(
        HttpHeaders.contentTypeHeader,
        'application/json; charset=UTF-8',
      );

      if (body != null) {
        request.write(jsonEncode(body));
      }

      final response = await request.close().timeout(timeout);
      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      return _parseResponse(response.statusCode, responseBody);
    } on TimeoutException {
      return ApiResponse.failure(
        'Network timeout. Changes saved locally to sync queue.',
        code: 'ERR_TIMEOUT',
      );
    } on SocketException catch (e) {
      return ApiResponse.failure(
        'Backend unreachable (${e.message}). Saved locally for pending sync.',
        code: 'ERR_OFFLINE',
      );
    } catch (e) {
      return ApiResponse.failure(
        'Unexpected network error: $e',
        code: 'ERR_NETWORK',
      );
    }
  }

  Uri _buildUri(String path, [Map<String, String>? queryParams]) {
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final fullUrl = '$baseUrl$cleanPath';
    final uri = Uri.parse(fullUrl);
    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  void _applyHeaders(
    HttpClientRequest request,
    Map<String, String>? customHeaders,
  ) {
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');
    if (authToken != null) {
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $authToken');
    }
    if (customHeaders != null) {
      customHeaders.forEach((k, v) => request.headers.set(k, v));
    }
  }

  ApiResponse<Map<String, dynamic>> _parseResponse(
    int statusCode,
    String bodyString,
  ) {
    try {
      final decoded = jsonDecode(bodyString);
      if (decoded is Map<String, dynamic>) {
        if (statusCode >= 200 && statusCode < 300) {
          return ApiResponse.success(decoded, statusCode: statusCode);
        } else {
          final errorObj = decoded['error'];
          final message = errorObj is Map
              ? errorObj['message'] ?? 'Request failed'
              : 'Request failed';
          final code = errorObj is Map ? errorObj['code'] : 'API_ERROR';
          return ApiResponse.failure(
            message.toString(),
            code: code?.toString(),
            statusCode: statusCode,
          );
        }
      }
      return ApiResponse.failure(
        'Unexpected response format',
        statusCode: statusCode,
      );
    } catch (e) {
      return ApiResponse.failure(
        'Failed to parse server response: $e',
        statusCode: statusCode,
      );
    }
  }
}
