import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Extension to easily log objects in debug mode with JSON formatting.
extension DebugLogExtension on Object? {
  /// Prints the object to the console if [kDebugMode] is true.
  ///
  /// It attempts to format the object as a JSON-encoded string with 3-space
  /// indentation if it is a JSON-encodable type (Map, List, String) or if
  /// the object has a `toJson()` method.
  /// 
  /// If the conversion to JSON fails, it falls back to calling `.toString()`.
  void debugLog() {
    if (!kDebugMode) return;

    if (this == null) {
      debugPrint('null');
      return;
    }

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
      final jsonString = encoder.convert(objectToEncode);
      debugPrint(jsonString);
    } catch (_) {
      // Fallback if JsonEncoder fails (e.g. object contains non-encodable properties)
      debugPrint(toString());
    }
  }
}
