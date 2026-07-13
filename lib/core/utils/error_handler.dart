import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';

/// Extension to convert any error or exception into a user-friendly string message.
extension FriendlyErrorMessageExtension on Object? {
  /// Analyzes the error object and returns a human-readable, user-friendly
  /// message suitable for displaying in the UI (e.g., in a Flushbar or Dialog).
  String toFriendlyMessage() {
    final error = this;

    if (error == null) {
      return 'An unknown error occurred.';
    }

    if (error is String) {
      return error;
    }

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.transformTimeout:
          return 'The connection timed out. Please check your internet connection and try again.';
        case DioExceptionType.badCertificate:
          return 'An issue occurred with the server certificate. Please try again later.';
        case DioExceptionType.badResponse:
          // Try to extract a specific error message from the response body
          final data = error.response?.data;
          if (data is Map<String, dynamic>) {
            final detail = data['detail'] ?? data['message'] ?? data['error'];
            if (detail is String && detail.isNotEmpty) {
              return detail;
            }
          }
          final statusCode = error.response?.statusCode;
          if (statusCode != null) {
            if (statusCode >= 500) {
              return 'The server encountered a problem. Please try again later.';
            } else if (statusCode == 404) {
              return 'The requested resource could not be found.';
            } else if (statusCode == 401 || statusCode == 403) {
              return 'You are not authorized to perform this action. Please log in again.';
            }
          }
          return 'Something went wrong processing your request. Please try again.';
        case DioExceptionType.cancel:
          return 'The request was cancelled.';
        case DioExceptionType.connectionError:
          return 'Unable to connect to the server. Please check your internet connection and try again.';
        case DioExceptionType.unknown:
          if (error.error is SocketException) {
            return 'No internet connection. Please check your network and try again.';
          }
          return 'An unexpected network error occurred. Please try again.';
      }
    }

    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (error is TimeoutException) {
      return 'The operation timed out. Please check your connection and try again.';
    }

    if (error is FormatException) {
      return 'There was a problem processing the data. Please try again or update the app.';
    }

    // Default fallback for any other unhandled Error or Exception
    return 'An unexpected error occurred. Please try again.';
  }
}
