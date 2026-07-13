import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:seeker_app/core/services/local_storage_service.dart';
import 'package:seeker_app/core/enviroment.dart';

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
        final accessToken = await appStorage.get('accessToken');
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
