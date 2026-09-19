import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:queue/queue.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final shellNavigatorKey = GlobalKey<NavigatorState>();

const naira = '₦';

final appQueue = Queue();

/// Helper function for configuring Riverpod provider retry logic.
Duration? Function(int retryCount, Object error) retryFunc([int maxRetries = 2]) {
  return (retryCount, error) => error is! DioException ? null: retryCount < maxRetries ? const Duration(seconds: 1) : null;
}