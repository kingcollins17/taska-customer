import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker_app/core/enviroment.dart';
import 'package:seeker_app/core/network/websocket_handler.dart';
import 'package:seeker_app/core/services/local_storage_service.dart';
import 'package:seeker_app/core/services/device_tray.dart';

class WebsocketNotifier extends StreamNotifier<dynamic> {
  WebsocketHandler? _handler;

  @override
  Stream<dynamic> build() async* {
    final token = await appStorage.get(StorageKey.accessToken);
    if (token == null || token.toString().isEmpty) {
      throw Exception('Not authenticated for websocket');
    }

    final env = Environment.fromEnv();
    String domain = env.baseDomain;
    if (domain.isEmpty) {
      try {
        domain = Uri.parse(env.baseUrl).host;
      } catch (_) {
        domain = 'domain';
      }
    }

    final wsUrl = 'wss://$domain/api/v1/notifications/ws?token=$token';

    _handler = WebsocketHandler(url: wsUrl, maxReconnectionAttempts: 25);
    _handler!.connect();

    ref.onDispose(() {
      _handler?.dispose();
    });

    yield* _handler!.messageStream;
  }

  void send(dynamic data) {
    _handler?.send(data);
  }
}

final websocketProvider = StreamNotifierProvider<WebsocketNotifier, dynamic>(
  WebsocketNotifier.new,
);

final deviceTrayNotificationsProvider = Provider<void>((ref) {
  ref.listen(websocketProvider, (previous, next) {
    if (next.hasValue && next.value != null) {
      final data = next.value;
      if (data is Map<String, dynamic>) {
        final title = data['title'];
        final body = data['body'];
        if (title != null && body != null) {
          DeviceTray.instance.showNotification(
            id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
            title: title.toString(),
            body: body.toString(),
            payload: jsonEncode(data['data'] ?? {}),
          );
        }
      }
    }
  });
});
