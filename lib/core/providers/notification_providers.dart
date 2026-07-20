import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker_app/core/clients/notifications_client.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/models/models.dart';

class NotificationsNotifier extends AsyncNotifier<List<NotificationItem>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  @override
  FutureOr<List<NotificationItem>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchNotifications();
  }

  Future<List<NotificationItem>> _fetchNotifications() async {
    final client = ref.read(notificationsClientProvider);
    final response = await client.getNotifications(_page, _perPage);

    if (response.success && response.data != null) {
      final items = response.data!.items ?? [];

      if (items.length < _perPage) {
        _hasMore = false;
      }
      return items;
    } else {
      throw Exception(response.detail ?? 'Failed to load notifications');
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isRefreshing || state.isReloading || !_hasMore)
      return;

    try {
      _page++;
      final newItems = await _fetchNotifications();
      final currentState = state.value ?? [];
      state = AsyncValue.data([...currentState, ...newItems]);
    } catch (e, stack) {
      // state = AsyncValue.error(e, stack);
    }
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    _page = 1;
    _hasMore = true;
    try {
      final items = await _fetchNotifications();
      state = AsyncValue.data(items);
    } catch (e, stack) {
      // state = AsyncValue.error(e, stack);
    }
  }

  Future<void> markAsRead(
    List<String> notificationIds, {
    void Function()? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final client = ref.read(notificationsClientProvider);
      final response = await client.markRead({
        'notification_ids': notificationIds,
      });
      if (response.success) {
        refresh();
        ref.invalidate(notificationCountsProvider);
        onSuccess?.call();
      }
    } catch (e) {
      onError?.call(e.toFriendlyMessage());

      AppErrorHandler.instance.handleError(e);
    }
  }
}

final notificationsProvider =
    AsyncNotifierProvider<NotificationsNotifier, List<NotificationItem>>(
      () => NotificationsNotifier(),
    );

final notificationCountsProvider = FutureProvider<NotificationCounts>((
  ref,
) async {
  final client = ref.read(notificationsClientProvider);
  final response = await client.getNotificationCounts();
  if (response.success && response.data != null) {
    return response.data!;
  }
  throw Exception(response.detail ?? 'Failed to get notification counts');
});
