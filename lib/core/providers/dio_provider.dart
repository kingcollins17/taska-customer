import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:seeker_app/core/services/local_storage_service.dart';
import 'package:seeker_app/core/enviroment.dart';
import 'package:seeker_app/core/utils/debug_log.dart';

final dioProvider = Provider<Dio>((ref) {
  final env = Environment.fromEnv();

  final dio = Dio(
    BaseOptions(
      baseUrl: env.baseUrl,
      contentType: 'application/json',
      validateStatus: (_) => true,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await appStorage.get(StorageKey.accessToken);
        if (accessToken != null && accessToken.toString().isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.data is Map<String, dynamic>) {
          response.data['statusCode'] = response.statusCode;
        }
        return handler.next(response);
      },
    ),
  );

  dio.interceptors.add(const DebugCacheInterceptor());

  dio.interceptors.add(
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

  return dio;
});

class DebugCacheInterceptor extends Interceptor {
  const DebugCacheInterceptor();

  void _addToDebugCache(Map<String, dynamic> rawMap) {
    try {
      const encoder = JsonEncoder.withIndent('   ');
      final logDataString = encoder.convert(rawMap);

      LogCache.instance.addLog(
        LogData(
          type: LogType.network,
          data: logDataString,
          timestamp: DateTime.now(),
          rawData: rawMap,
        ),
      );
    } catch (_) {
      LogCache.instance.addLog(
        LogData(
          type: LogType.network,
          data: rawMap.toString(),
          timestamp: DateTime.now(),
          rawData: rawMap,
        ),
      );
    }
  }

  bool _isJsonEncodable(dynamic value) {
    if (value == null) return true;
    try {
      jsonEncode(value);
      return true;
    } catch (_) {
      return false;
    }
  }

  dynamic _tryToJsonEncodable(dynamic data) {
    if (data == null) return null;
    if (data is Map || data is List) {
      if (_isJsonEncodable(data)) return data;
    }
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map || decoded is List) return decoded;
      } catch (_) {}
      return data;
    }
    if (data is num || data is bool) return data;

    try {
      final json = (data as dynamic).toJson();
      if (_isJsonEncodable(json)) return json;
    } catch (_) {}

    return null;
  }

  Map<String, dynamic>? _sanitizeHeaders(Map<String, dynamic> headers) {
    try {
      final map = <String, dynamic>{};
      headers.forEach((key, value) {
        if (value is String || value is num || value is bool) {
          map[key] = value;
        } else if (value is List) {
          map[key] = value.length == 1
              ? value.first.toString()
              : value.map((e) => e.toString()).toList();
        } else if (value != null) {
          map[key] = value.toString();
        }
      });
      return map;
    } catch (_) {
      return null;
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final Map<String, dynamic> requestLog = {
        'event': 'HTTP_REQUEST',
        'method': options.method,
        'url': options.uri.toString(),
        if (options.headers.isNotEmpty)
          'headers': _sanitizeHeaders(options.headers) ?? options.headers,
        if (options.queryParameters.isNotEmpty)
          'queryParameters': _tryToJsonEncodable(options.queryParameters) ??
              options.queryParameters.toString(),
      };

      if (options.data != null) {
        final encodableBody = _tryToJsonEncodable(options.data);
        requestLog['body'] = encodableBody ?? options.data.toString();
      }

      _addToDebugCache(requestLog);
    } catch (_) {
      // Avoid interrupting execution flow if logging fails
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    try {
      final Map<String, dynamic> responseLog = {
        'event': 'HTTP_RESPONSE',
        'statusCode': response.statusCode,
        if (response.statusMessage != null && response.statusMessage!.isNotEmpty)
          'statusMessage': response.statusMessage,
        'method': response.requestOptions.method,
        'url': response.requestOptions.uri.toString(),
        if (response.headers.map.isNotEmpty)
          'headers': _sanitizeHeaders(response.headers.map) ??
              response.headers.map,
      };

      if (response.data != null) {
        final encodableData = _tryToJsonEncodable(response.data);
        responseLog['body'] = encodableData ?? response.data.toString();
      }

      _addToDebugCache(responseLog);
    } catch (_) {
      // Avoid interrupting execution flow if logging fails
    }

    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    try {
      final Map<String, dynamic> errorLog = {
        'event': 'HTTP_ERROR',
        'errorType': err.type.name,
        if (err.message != null) 'message': err.message,
        'method': err.requestOptions.method,
        'url': err.requestOptions.uri.toString(),
        if (err.response?.statusCode != null)
          'statusCode': err.response?.statusCode,
        if (err.response?.statusMessage != null &&
            err.response!.statusMessage!.isNotEmpty)
          'statusMessage': err.response?.statusMessage,
      };

      if (err.response?.headers.map != null &&
          err.response!.headers.map.isNotEmpty) {
        errorLog['headers'] = _sanitizeHeaders(err.response!.headers.map) ??
            err.response!.headers.map;
      }

      if (err.response?.data != null) {
        final encodableRespData = _tryToJsonEncodable(err.response!.data);
        errorLog['body'] = encodableRespData ?? err.response!.data.toString();
      }

      if (err.error != null) {
        final encodableErr = _tryToJsonEncodable(err.error);
        errorLog['error'] = encodableErr ?? err.error.toString();
      }

      _addToDebugCache(errorLog);
    } catch (_) {
      // Avoid interrupting execution flow if logging fails
    }

    super.onError(err, handler);
  }
}
