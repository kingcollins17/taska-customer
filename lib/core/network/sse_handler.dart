import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';
import '../utils/debug_log.dart';

/// Enum representing the possible states of the SSE connection.
enum SseConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  closed,
}

/// A robust SSE (Server-Sent Events) handler wrapping [SSEClient]
/// featuring automatic reconnection with exponential backoff, jitter,
/// error resilience, and state management.
class SseHandler {
  /// The SSE server endpoint URL.
  final String url;

  /// Optional HTTP request headers.
  final Map<String, String>? headers;

  /// Maximum number of consecutive reconnection attempts.
  final int maxReconnectionAttempts;

  /// Initial duration to wait before attempting to reconnect.
  final Duration initialBackoff;

  /// Maximum duration to wait between reconnection attempts.
  final Duration maxBackoff;

  int _reconnectionAttempts = 0;
  bool _isDisposed = false;
  bool _isIntentionalClose = false;

  final _messageController = StreamController<dynamic>.broadcast();
  final _stateController = StreamController<SseConnectionState>.broadcast();

  StreamSubscription<SSEModel>? _sseSubscription;
  Timer? _reconnectTimer;

  SseConnectionState _currentState = SseConnectionState.disconnected;

  /// Creates an [SseHandler] with the specified [url] and reconnection parameters.
  SseHandler({
    required this.url,
    this.headers,
    this.maxReconnectionAttempts = 25,
    this.initialBackoff = const Duration(seconds: 2),
    this.maxBackoff = const Duration(seconds: 30),
  }) {
    _updateState(SseConnectionState.disconnected);
  }

  /// Broadcast stream of notification payloads (parsed JSON object or String).
  Stream<dynamic> get messageStream => _messageController.stream;

  /// Broadcast stream of connection state updates.
  Stream<SseConnectionState> get stateStream => _stateController.stream;

  /// Current connection state.
  SseConnectionState get currentState => _currentState;

  /// Updates internal connection state and notifies listeners.
  void _updateState(SseConnectionState state) {
    if (_isDisposed) return;
    if (_currentState != state) {
      _currentState = state;
      _stateController.add(state);
      'SseHandler state changed to: ${state.name}'.debugLog();
    }
  }

  /// Initiates connection to the SSE server.
  void connect() {
    if (_isDisposed) {
      'SseHandler is disposed, cannot connect.'.debugLog();
      return;
    }

    if (_currentState == SseConnectionState.connected ||
        _currentState == SseConnectionState.connecting) {
      return;
    }

    _isIntentionalClose = false;
    _updateState(_reconnectionAttempts > 0
        ? SseConnectionState.reconnecting
        : SseConnectionState.connecting);

    'SseHandler connecting to $url'.debugLog();

    try {
      final defaultHeaders = <String, String>{
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
        if (headers != null) ...headers!,
      };

      _sseSubscription?.cancel();
      _sseSubscription = SSEClient.subscribeToSSE(
        method: SSERequestType.GET,
        url: url,
        header: defaultHeaders,
      ).listen(
        (event) {
          if (_isDisposed) return;

          if (_currentState != SseConnectionState.connected) {
            _updateState(SseConnectionState.connected);
            _reconnectionAttempts = 0;
          }

          final rawData = event.data;
          if (rawData != null && rawData.isNotEmpty) {
            'SseHandler message received'.debugLog();
            try {
              final parsed = jsonDecode(rawData);
              
              _messageController.add(parsed);
              (parsed as Object?).debugLog();
            } catch (_) {
             
              _messageController.add(rawData);
               rawData.debugLog();
            }
          }
        },
        onError: (error, stackTrace) {
          'SseHandler stream error: $error'.debugLog();
          _handleDisconnectOrError();
        },
        onDone: () {
          'SseHandler stream closed by server'.debugLog();
          _handleDisconnectOrError();
        },
        cancelOnError: false,
      );
    } catch (e) {
      'SseHandler connect exception: $e'.debugLog();
      _handleDisconnectOrError();
    }
  }

  void _handleDisconnectOrError() {
    _sseSubscription?.cancel();
    _sseSubscription = null;

    if (_isDisposed || _isIntentionalClose) {
      _updateState(SseConnectionState.closed);
      return;
    }

    _updateState(SseConnectionState.disconnected);
    _scheduleReconnection();
  }

  void _scheduleReconnection() {
    if (_isDisposed || _isIntentionalClose) return;

    if (_reconnectionAttempts >= maxReconnectionAttempts) {
      'SseHandler max reconnection attempts ($maxReconnectionAttempts) reached'.debugLog();
      _updateState(SseConnectionState.closed);
      return;
    }

    _reconnectionAttempts++;

    // Calculate backoff: initialBackoff * 2^(attempts-1) with max cap & random jitter
    final powFactor = pow(2, _reconnectionAttempts - 1).toDouble();
    final backoffMs = (initialBackoff.inMilliseconds * powFactor).clamp(
      initialBackoff.inMilliseconds.toDouble(),
      maxBackoff.inMilliseconds.toDouble(),
    );
    final randomJitter = Random().nextDouble() * 1000;
    final delay = Duration(milliseconds: (backoffMs + randomJitter).toInt());

    'SseHandler scheduling reconnection attempt $_reconnectionAttempts in ${delay.inMilliseconds}ms'.debugLog();

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (!_isDisposed && !_isIntentionalClose) {
        connect();
      }
    });
  }

  /// Manually force a reconnection.
  void reconnect() {
    _reconnectionAttempts = 0;
    _sseSubscription?.cancel();
    _reconnectTimer?.cancel();
    connect();
  }

  /// Intentionally disconnect from the SSE server.
  void disconnect() {
    _isIntentionalClose = true;
    _reconnectTimer?.cancel();
    _sseSubscription?.cancel();
    _sseSubscription = null;
    try {
      SSEClient.unsubscribeFromSSE();
    } catch (_) {}
    _updateState(SseConnectionState.disconnected);
  }

  /// Cleans up resources and closes stream controllers.
  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _isIntentionalClose = true;
    _reconnectTimer?.cancel();
    _sseSubscription?.cancel();
    _sseSubscription = null;
    try {
      SSEClient.unsubscribeFromSSE();
    } catch (_) {}
    _updateState(SseConnectionState.closed);
    _messageController.close();
    _stateController.close();
    'SseHandler disposed'.debugLog();
  }
}
