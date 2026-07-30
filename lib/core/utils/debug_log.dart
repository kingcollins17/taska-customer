import 'dart:convert';
import 'package:flutter/foundation.dart';

enum LogType { info, warn, error }

class LogData {
  final LogType type;
  final dynamic data;
  final DateTime timestamp;

  LogData({required this.type, required this.data, required this.timestamp});
}

class LogCache extends ChangeNotifier {
  LogCache._();
  static final LogCache instance = LogCache._();

  final List<LogData> logs = [];

  void addLog(LogData log) {
    logs.add(log);
    notifyListeners();
  }

  void clearLogs() {
    logs.clear();
    notifyListeners();
  }
}

/// Extension to easily log objects in debug mode with JSON formatting.
extension DebugLogExtension on Object? {
  /// Prints the object to the console if [kDebugMode] is true.
  ///
  /// It attempts to format the object as a JSON-encoded string with 3-space
  /// indentation if it is a JSON-encodable type (Map, List, String) or if
  /// the object has a `toJson()` method.
  ///
  /// If the conversion to JSON fails, it falls back to calling `.toString()`.
  void debugLog({LogType type = LogType.info}) {
    if (!kDebugMode) return;

    if (this == null) {
      LogCache.instance.addLog(
        LogData(type: type, data: 'null', timestamp: DateTime.now()),
      );
      debugPrint('null');
      return;
    }

    String logDataString;
    try {
      dynamic objectToEncode = this;

      // Check if the object has a toJson() method and call it
      try {
        objectToEncode = (this as dynamic).toJson();
      } on NoSuchMethodError {
        // Object doesn't have toJson(), proceed with the original object
      } catch (_) {
        // Ignore other errors during toJson() invocation and proceed
      }

      const encoder = JsonEncoder.withIndent('   ');
      logDataString = encoder.convert(objectToEncode);
    } catch (_) {
      // Fallback if JsonEncoder fails (e.g. object contains non-encodable properties)
      logDataString = toString();
    }

    LogCache.instance.addLog(
      LogData(type: type, data: logDataString, timestamp: DateTime.now()),
    );
    debugPrint(logDataString);
  }
}
