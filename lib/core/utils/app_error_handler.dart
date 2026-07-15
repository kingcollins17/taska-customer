import 'package:seeker_app/core/utils/debug_log.dart';

class AppErrorHandler {
  AppErrorHandler._();

  static final AppErrorHandler instance = AppErrorHandler._();

  void handleError(Object error, [StackTrace? stackTrace]) {
    error.debugLog();
    stackTrace?.debugLog();
  }
}
