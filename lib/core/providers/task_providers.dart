import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker_app/core/clients/tasks_client.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/user_provider.dart';

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

final pendingDispatchProvider = FutureProvider.family<DispatchAttempt, String>((
  ref,
  taskId,
) async {
  final client = ref.read(tasksClientProvider);
  final response = await client.getPendingDispatch(taskId);

  if (response.success && response.data != null) {
    return response.data!;
  }

  throw Exception(response.detail ?? 'Failed to load pending dispatch');
  // return DispatchAttempt(
  //   id: 'mock_id',
  //   taskId: taskId,
  //   providerId: 'provider_id',
  //   sequenceOrder: 1,
  //   matchScore: 99.0,
  //   offeredPayout: 10.0,
  //   pingedAt: DateTime.now(),
  //   expiresAt: DateTime.now().add(const Duration(minutes: 5)),
  //   respondedAt: null,
  //   status: 'pending',
  // );
});

class TaskDraftActionNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> confirmDraft({
    required String taskId,
    void Function()? onSuccess,
    void Function(String error)? onError,
  }) async {
    try {
      final client = ref.read(tasksClientProvider);
      final response = await client.confirmDraftTask(taskId);

      if (response.success) {
        onSuccess?.call();
      } else {
        final error = response.detail ?? 'Failed to confirm draft';

        onError?.call(error);
      }
    } catch (e, st) {
      AppErrorHandler.instance.handleError(e, st);
      onError?.call(e.toString());
    }
  }

  Future<void> cancelDraft({
    required String taskId,
    void Function()? onSuccess,
    void Function(String error)? onError,
  }) async {
    try {
      final client = ref.read(tasksClientProvider);
      final response = await client.cancelDraftTask(taskId);

      if (response.success) {
        onSuccess?.call();
      } else {
        final error = response.detail ?? 'Failed to cancel draft';
        onError?.call(error);
      }
    } catch (e, st) {
      AppErrorHandler.instance.handleError(e, st);
      onError?.call(e.toString());
    }
  }
}

final taskDraftActionProvider =
    AsyncNotifierProvider<TaskDraftActionNotifier, void>(
      () => TaskDraftActionNotifier(),
    );

class TasksNotifier extends AsyncNotifier<List<TaskLite>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  // Filters
  String? status;
  String? categoryId;
  String? serviceId;
  String? search;
  double? radiusKm;
  String? sortBy = 'created_at';
  bool? sortDesc = true;

  bool get hasMore => _hasMore;

  @override
  FutureOr<List<TaskLite>> build() async {
    await ref.watch(userProvider.future);
    _page = 1;
    _hasMore = true;
    return _fetchTasks();
  }

  Future<List<TaskLite>> _fetchTasks() async {
    final client = ref.read(tasksClientProvider);
    final user = ref.read(userProvider).value;
    
    final response = await client.listTasks(
      page: _page,
      perPage: _perPage,
      status: status,
      categoryId: categoryId,
      serviceId: serviceId,
      search: search,
      radiusKm: radiusKm,
      sortBy: sortBy,
      sortDesc: sortDesc,
      customerId: user?.id,
    );

    if (response.success && response.data != null) {
      final items = response.data!.items ?? [];

      if (items.length < _perPage) {
        _hasMore = false;
      }
      return items;
    } else {
      throw Exception(response.detail ?? 'Failed to load tasks');
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

  void setFilters({
    String? status,
    String? categoryId,
    String? serviceId,
    String? search,
    double? radiusKm,
    String? sortBy,
    bool? sortDesc,
  }) {
    this.status = status ?? this.status;
    this.categoryId = categoryId ?? this.categoryId;
    this.serviceId = serviceId ?? this.serviceId;
    this.search = search ?? this.search;
    this.radiusKm = radiusKm ?? this.radiusKm;
    this.sortBy = sortBy ?? this.sortBy;
    this.sortDesc = sortDesc ?? this.sortDesc;

    state = const AsyncValue.loading();
    refresh();
  }

  void clearFilters() {
    status = null;
    categoryId = null;
    serviceId = null;
    search = null;
    radiusKm = null;
    sortBy = 'created_at';
    sortDesc = true;

    state = const AsyncValue.loading();
    refresh();
  }
}

final tasksProvider = AsyncNotifierProvider<TasksNotifier, List<TaskLite>>(
  () => TasksNotifier(),
);
