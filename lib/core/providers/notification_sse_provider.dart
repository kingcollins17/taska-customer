import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker_app/core/enviroment.dart';
import 'package:seeker_app/core/models/notifications/notification_item.dart';
import 'package:seeker_app/core/network/sse_handler.dart';
import 'package:seeker_app/core/providers/notification_providers.dart';
import 'package:seeker_app/core/services/device_tray.dart';
import 'package:seeker_app/core/services/local_storage_service.dart';

/// StreamNotifier for real-time in-app SSE notifications.
///
/// Connects to `/api/v1/notifications/stream?token=<jwt>` using [SseHandler]
/// and automatically handles reconnection, token retrieval, and stream lifecycle.
class NotificationSseNotifier extends StreamNotifier<dynamic> {
  SseHandler? _handler;

  @override
  Stream<dynamic> build() async* {
    final token = await appStorage.get(StorageKey.accessToken);
    if (token == null || token.toString().isEmpty) {
      throw Exception('Not authenticated for notifications SSE stream');
    }

    final env = Environment.fromEnv();
    String baseUrl = env.baseUrl;
    if (baseUrl.isEmpty) {
      baseUrl = 'https://stellar-prosperity-production.up.railway.app';
    }

    final sseUrl = '$baseUrl/api/v1/notifications/stream?token=$token';

    _handler = SseHandler(
      url: sseUrl,
      maxReconnectionAttempts: 25,
      initialBackoff: const Duration(seconds: 2),
      maxBackoff: const Duration(seconds: 30),
    );

    _handler!.connect();

    ref.onDispose(() {
      _handler?.dispose();
    });

    yield* _handler!.messageStream;
  }

  /// Triggers a manual reconnection attempt.
  void reconnect() {
    _handler?.reconnect();
  }

  /// Returns the current connection state of the SSE stream.
  SseConnectionState get connectionState =>
      _handler?.currentState ?? SseConnectionState.disconnected;
}

/// Riverpod provider for real-time SSE notification messages stream.
final notificationSseProvider =
    StreamNotifierProvider<NotificationSseNotifier, dynamic>(
      NotificationSseNotifier.new,
    );

/// Riverpod provider to expose parsed [NotificationItem] from the SSE stream.
final notificationItemSseProvider = Provider<NotificationItem?>((ref) {
  final asyncValue = ref.watch(notificationSseProvider);
  return asyncValue.when(
    data: (rawData) {
      if (rawData is Map<String, dynamic>) {
        try {
          return NotificationItem.fromJson(rawData);
        } catch (_) {}
      } else if (rawData is String) {
        try {
          final decoded = jsonDecode(rawData);
          if (decoded is Map<String, dynamic>) {
            return NotificationItem.fromJson(decoded);
          }
        } catch (_) {}
      }
      return null;
    },
    error: (_, stack) => null,
    loading: () => null,
  );
});

/// Device tray & state invalidation listener provider.
///
/// Listens to incoming real-time SSE notification payloads, triggers system tray
/// notifications, and invalidates list/counter providers to refresh in-app UI.
final notificationSseTrayListenerProvider = Provider<void>((ref) {
  ref.listen(notificationSseProvider, (previous, next) {
    if (next.hasValue && next.value != null) {
      final data = next.value;
      Map<String, dynamic>? payload;

      if (data is Map<String, dynamic>) {
        payload = data;
      } else if (data is String) {
        try {
          final decoded = jsonDecode(data);
          if (decoded is Map<String, dynamic>) {
            payload = decoded;
          }
        } catch (_) {}
      }

      if (payload != null) {
        final title = payload['title'] ?? payload['type'] ?? 'New Notification';
        final body = payload['body'] ?? payload['message'] ?? '';
        final notificationData = payload['data'] ?? {};

        DeviceTray.instance.showNotification(
          id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
          title: title.toString(),
          body: body.toString(),
          payload: jsonEncode(notificationData),
        );

        // Refresh in-app notifications list and unread count
        ref.invalidate(notificationsProvider);
        ref.invalidate(notificationCountsProvider);
      }
    }
  });
});
