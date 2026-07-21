import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker_app/core/clients/tasks_client.dart';
import 'package:seeker_app/core/models/models.dart';

class ActiveTasksNotifier extends AsyncNotifier<List<TaskLite>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  FutureOr<List<TaskLite>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchTasks();
  }

  Future<List<TaskLite>> _fetchTasks() async {
    final client = ref.read(tasksClientProvider);
    final response = await client.getActiveTasks(
      page: _page,
      perPage: _perPage,
    );

    if (response.success && response.data != null) {
      final items = response.data!.items ?? [];

      if (items.length < _perPage) {
        _hasMore = false;
      }
      return items;
    } else {
      throw Exception(response.detail ?? 'Failed to load active tasks');
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading ||
        state.isRefreshing ||
        state.isReloading ||
        !_hasMore) {
      return;
    }

    try {
      _page++;
      final newItems = await _fetchTasks();
      final currentState = state.value ?? [];
      state = AsyncValue.data([...currentState, ...newItems]);
    } catch (e, stack) {
      _page--;
    }
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    try {
      final items = await _fetchTasks();
      state = AsyncValue.data(items);
    } catch (e, stack) {}
  }
}

final activeTasksProvider =
    AsyncNotifierProvider<ActiveTasksNotifier, List<TaskLite>>(
      () => ActiveTasksNotifier(),
    );

class PendingTasksNotifier extends AsyncNotifier<List<TaskLite>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  FutureOr<List<TaskLite>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchTasks();
  }

  Future<List<TaskLite>> _fetchTasks() async {
    final client = ref.read(tasksClientProvider);
    final response = await client.getPendingTasks(
      page: _page,
      perPage: _perPage,
    );

    if (response.success && response.data != null) {
      final items = response.data!.items ?? [];

      if (items.length < _perPage) {
        _hasMore = false;
      }
      return items;
    } else {
      throw Exception(response.detail ?? 'Failed to load pending tasks');
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading ||
        state.isRefreshing ||
        state.isReloading ||
        !_hasMore) {
      return;
    }

    try {
      _page++;
      final newItems = await _fetchTasks();
      final currentState = state.value ?? [];
      state = AsyncValue.data([...currentState, ...newItems]);
    } catch (e, stack) {
      _page--;
    }
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    try {
      final items = await _fetchTasks();
      state = AsyncValue.data(items);
    } catch (e, stack) {}
  }
}

final pendingTasksProvider =
    AsyncNotifierProvider<PendingTasksNotifier, List<TaskLite>>(
      () => PendingTasksNotifier(),
    );

final taskDetailProvider = FutureProvider.family<Task, String>((
  ref,
  taskId,
) async {
  final client = ref.read(tasksClientProvider);
  final response = await client.getTask(taskId);

  if (response.success && response.data != null) {
    return response.data!;
  }

  throw Exception(response.detail ?? 'Failed to load task details');
});

final allTasksAggregatedProvider = FutureProvider<List<TaskLite>>((ref) async {
  final activeTasks = await ref.watch(activeTasksProvider.future);
  final pendingTasks = await ref.watch(pendingTasksProvider.future);

  final allTasks = [...activeTasks, ...pendingTasks];

  allTasks.shuffle();

  allTasks.sort((a, b) {
    final dateA = a.scheduledStartAt ?? a.createdAt;
    final dateB = b.scheduledStartAt ?? b.createdAt;
    if (dateA == null && dateB == null) return 0;
    if (dateA == null) return 1;
    if (dateB == null) return -1;
    return dateB.compareTo(dateA);
  });

  return allTasks;
});
