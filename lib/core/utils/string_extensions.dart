extension StringExt on String {
  /// Checks if this string (lowercased) is exactly present in [values].
  bool isExactlyIn(Iterable<String> values) {
    return values.map((i) => i.toLowerCase()).contains(toLowerCase());
  }

  /// Checks if this string matches any of the regular expression patterns in [values].
  bool isRegexIn(Iterable<String> values) {
    return values.any((pattern) {
      try {
        final regex = RegExp(pattern, caseSensitive: false);
        return regex.hasMatch(this);
      } catch (_) {
        return false;
      }
    });
  }

  /// Checks if the string is a valid email address.
  bool get isValidEmail {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(this);
  }

  /// Checks if the string is a valid phone number.
  bool get isValidPhoneNumber {
    final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
    return phoneRegex.hasMatch(this);
  }

  /// Checks if the string is a valid URL.
  bool get isValidUrl {
    final urlRegex = RegExp(
      r'^(https?:\/\/)?(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );
    return urlRegex.hasMatch(this);
  }

  /// Capitalizes the first character of the string.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes the first letter of each word in the string.
  String get capitalizeWords {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Checks if the string represents a numeric value.
  bool get isNumeric {
    return double.tryParse(this) != null;
  }

  /// Truncates the string to a maximum length and appends a suffix.
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}$suffix';
  }

  /// Checks if the string contains only alphanumeric characters.
  bool get isAlphanumeric {
    final alphaNumericRegex = RegExp(r'^[a-zA-Z0-9]+$');
    return alphaNumericRegex.hasMatch(this);
  }

  /// Removes all whitespace from the string.
  String get removeWhitespace {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Converts the string to double, returning 0.0 if parsing fails.
  double toDoubleOrZero() {
    return double.tryParse(this) ?? 0.0;
  }

  /// Converts the string to int, returning 0 if parsing fails.
  int toIntOrZero() {
    return int.tryParse(this) ?? 0;
  }
}

extension NullableStringExt on String? {
  /// Returns true if the string is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns true if the string is null, empty, or consists only of whitespace.
  bool get isNullOrBlank => this == null || this!.trim().isEmpty;

  /// Returns the string itself, or an empty string if it is null.
  String get orEmpty => this ?? '';
}
