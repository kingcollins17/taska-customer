import 'dart:async';

/// A singleton manager that tracks when the app is fully loaded and the first
/// screen has shown. Useful for deferring actions (like deep links, notifications, 
/// or initial API calls) until the app is fully ready to handle them.
class AppReadyManager {
  // Private constructor for singleton
  AppReadyManager._();

  // Singleton instance
  static final AppReadyManager _instance = AppReadyManager._();

  // Factory constructor to return the singleton instance
  factory AppReadyManager() => _instance;

  // Alternatively, providing a static getter
  static AppReadyManager get instance => _instance;

  // Completer to manage the ready state
  final Completer<void> _readyCompleter = Completer<void>();

  /// Returns a Future that completes when [markAsReady] is called.
  Future<void> get ready => _readyCompleter.future;

  /// Returns true if the app has already been marked as ready.
  bool get isReady => _readyCompleter.isCompleted;

  /// Call this method when the app load is complete, the first screen has shown,
  /// and everything is ready.
  void markAsReady() {
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
  }
}
