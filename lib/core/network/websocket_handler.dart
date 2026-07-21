import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

import '../utils/debug_log.dart';

/// Enum representing the possible states of the WebSocket connection.
enum WebSocketConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  closed,
}

/// A robust WebSocket handler that wraps [WebSocketChannel] and provides
/// automatic reconnection, exponential backoff, and state management.
class WebsocketHandler {
  /// The URL of the WebSocket server.
  final String url;
  
  /// The maximum number of consecutive reconnection attempts.
  final int maxReconnectionAttempts;
  
  /// The initial duration to wait before attempting to reconnect.
  final Duration initialBackoff;
  
  /// The maximum duration to wait between reconnection attempts.
  final Duration maxBackoff;

  WebSocketChannel? _channel;
  int _reconnectionAttempts = 0;
  bool _isDisposed = false;
  bool _isIntentionalClose = false;

  final _messageController = StreamController<dynamic>.broadcast();
  final _stateController = StreamController<WebSocketConnectionState>.broadcast();
  
  StreamSubscription? _channelSubscription;
  Timer? _reconnectTimer;

  WebSocketConnectionState _currentState = WebSocketConnectionState.disconnected;

  /// Creates a [WebsocketHandler] with the specified [url] and optional
  /// reconnection parameters.
  WebsocketHandler({
    required this.url,
    this.maxReconnectionAttempts = 5,
    this.initialBackoff = const Duration(seconds: 1),
    this.maxBackoff = const Duration(seconds: 30),
  }) {
    _updateState(WebSocketConnectionState.disconnected);
  }

  /// A broadcast stream of messages received from the WebSocket.
  Stream<dynamic> get messageStream => _messageController.stream;

  /// A broadcast stream of connection state changes.
  Stream<WebSocketConnectionState> get stateStream => _stateController.stream;

  /// The current state of the WebSocket connection.
  WebSocketConnectionState get currentState => _currentState;

  /// Updates the internal connection state and notifies listeners.
  void _updateState(WebSocketConnectionState state) {
    if (_isDisposed) return;
    if (_currentState != state) {
      _currentState = state;
      _stateController.add(state);
      'WebsocketHandler state changed to: ${state.name}'.debugLog();
    }
  }

  /// Initiates a connection to the WebSocket server.
  ///
  /// If already connected or connecting, this method does nothing.
  void connect() {
    if (_isDisposed) {
      'WebsocketHandler is disposed, cannot connect.'.debugLog();
      return;
    }
    if (_currentState == WebSocketConnectionState.connected || 
        _currentState == WebSocketConnectionState.connecting) {
      return;
    }

    _isIntentionalClose = false;
    _updateState(WebSocketConnectionState.connecting);
    'WebsocketHandler connecting to $url'.debugLog();

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      _channelSubscription = _channel!.stream.listen(
        (message) {
          // Reset reconnection attempts on receiving a message
          // since it implies a healthy connection.
          _reconnectionAttempts = 0; 
          
          if (_currentState != WebSocketConnectionState.connected) {
            _updateState(WebSocketConnectionState.connected);
          }
          
          dynamic decodedMessage = message;
          if (message is String) {
            try {
              decodedMessage = jsonDecode(message);
            } catch (e) {
              'WebsocketHandler jsonDecode error: $e. Falling back to original message.'.debugLog();
            }
          }
          _messageController.add(decodedMessage);
        },
        onDone: () {
          'WebsocketHandler connection closed. Intentional: $_isIntentionalClose'.debugLog();
          if (!_isIntentionalClose) {
            _handleDisconnect();
          } else {
            _updateState(WebSocketConnectionState.closed);
          }
        },
        onError: (error) {
          'WebsocketHandler error: $error'.debugLog();
          _handleDisconnect();
        },
        cancelOnError: true,
      );

      // Await connection readiness if possible, though stream events usually handle status.
      _channel!.ready.then((_) {
        if (!_isDisposed && !_isIntentionalClose) {
          _reconnectionAttempts = 0;
          _updateState(WebSocketConnectionState.connected);
          'WebsocketHandler connected successfully'.debugLog();
        }
      }).catchError((error) {
        'WebsocketHandler ready error: $error'.debugLog();
      });

    } catch (e) {
      'WebsocketHandler connect exception: $e'.debugLog();
      _handleDisconnect();
    }
  }

  /// Sends [data] over the WebSocket connection.
  void send(dynamic data) {
    if (_isDisposed) return;
    if (_currentState != WebSocketConnectionState.connected) {
      'WebsocketHandler cannot send message: Not connected'.debugLog();
      return;
    }
    
    try {
      _channel?.sink.add(data);
      'WebsocketHandler message sent'.debugLog();
    } catch (e) {
      'WebsocketHandler send error: $e'.debugLog();
    }
  }

  /// Handles an unexpected disconnection by scheduling a reconnection attempt
  /// using exponential backoff with jitter.
  void _handleDisconnect() {
    if (_isDisposed || _isIntentionalClose) return;

    _cleanupChannel();

    if (_reconnectionAttempts < maxReconnectionAttempts) {
      _reconnectionAttempts++;
      _updateState(WebSocketConnectionState.reconnecting);
      
      final backoff = _calculateBackoff(_reconnectionAttempts);
      'WebsocketHandler reconnecting in ${backoff.inSeconds} seconds (Attempt $_reconnectionAttempts of $maxReconnectionAttempts)'.debugLog();

      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(backoff, () {
        connect();
      });
    } else {
      'WebsocketHandler reached max reconnection attempts'.debugLog();
      _updateState(WebSocketConnectionState.disconnected);
    }
  }

  /// Calculates the backoff duration for a given [attempt] using exponential
  /// backoff with random jitter to prevent thundering herd problems.
  Duration _calculateBackoff(int attempt) {
    final backoffMilliseconds = initialBackoff.inMilliseconds * pow(2, attempt - 1);
    final backoff = Duration(milliseconds: backoffMilliseconds.toInt());
    
    // Add jitter up to 1000 milliseconds
    final jitter = Duration(milliseconds: Random().nextInt(1000));
    final totalBackoff = backoff + jitter;
    
    return totalBackoff.compareTo(maxBackoff) < 0 ? totalBackoff : maxBackoff;
  }

  /// Cleans up the active channel subscription and sink.
  void _cleanupChannel() {
    _channelSubscription?.cancel();
    _channelSubscription = null;
    
    _channel?.sink.close(status.goingAway);
    _channel = null;
  }

  /// Intentionally closes the WebSocket connection. No reconnection will be attempted.
  void close() {
    if (_isDisposed) return;
    
    _isIntentionalClose = true;
    _reconnectTimer?.cancel();
    _cleanupChannel();
    _updateState(WebSocketConnectionState.closed);
    
    'WebsocketHandler connection closed intentionally'.debugLog();
  }

  /// Disposes of all resources, including streams and controllers.
  /// The handler cannot be used after this method is called.
  void dispose() {
    if (_isDisposed) return;
    
    _isDisposed = true;
    close();
    
    _messageController.close();
    _stateController.close();
    
    'WebsocketHandler disposed'.debugLog();
  }
}
