import 'package:intl/intl.dart';

extension NumExtension on num {
  /// Formats the number as Nigerian Naira (₦) with decimal places.
  /// For example, 20000.50 becomes ₦20,000.50.
  String toNaira([int? decimalDigits]) {
    final format = NumberFormat.currency(
      symbol: '₦',
      decimalDigits: decimalDigits ?? 0,
    );
    return format.format(this);
  }
}
