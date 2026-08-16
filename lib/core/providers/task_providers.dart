import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter_riverpod/legacy.dart';
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
    } catch (_) {
      _page--;
    }
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    try {
      final items = await _fetchTasks();
      state = AsyncValue.data(items);
    } catch (_) {}
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
    } catch (_) {
      _page--;
    }
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    try {
      final items = await _fetchTasks();
      state = AsyncValue.data(items);
    } catch (_) {}
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

// TODO: Remove this as backend will have multiple pending dispatches, instead query the taskDetailProvider for status, if its assigned, then get assigment
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
        // ref.invalidate(taskDetailProvider(taskId));
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

final taskStatusFilterProvider = StateProvider<List<String>>((ref) => []);

class TasksNotifier extends AsyncNotifier<List<TaskLite>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  // Filters
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
    final statusFilter = ref.watch(taskStatusFilterProvider);
    _page = 1;
    _hasMore = true;
    return _fetchTasks(statusFilter);
  }

  Future<List<TaskLite>> _fetchTasks([List<String>? statusFilter]) async {
    final client = ref.read(tasksClientProvider);
    final user = ref.read(userProvider).value;
    final statuses = statusFilter ?? ref.read(taskStatusFilterProvider);

    final response = await client.listTasks(
      page: _page,
      perPage: _perPage,
      status: statuses,
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
    } catch (_) {
      _page--;
    }
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    try {
      final items = await _fetchTasks();
      state = AsyncValue.data(items);
    } catch (_) {}
  }

  void setFilters({
    String? categoryId,
    String? serviceId,
    String? search,
    double? radiusKm,
    String? sortBy,
    bool? sortDesc,
  }) {
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
    ref.read(taskStatusFilterProvider.notifier).state = [];
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

final taskAssignmentProvider = FutureProvider.family<TaskAssignment, String>((
  ref,
  taskId,
) async {
  final client = ref.read(tasksClientProvider);
  final response = await client.getTaskAssignment(taskId);

  if (response.success && response.data != null) {
    return response.data!;
  }

  throw Exception(response.detail ?? 'Failed to load task assignment');
});

final verifyProviderPinProvider = FutureProvider.family
    .autoDispose<TaskAssignmentProvider, ({String? taskId, String? pin})>((
      ref,
      params,
    ) async {
      final taskId = params.taskId;
      final pin = params.pin;

      if (taskId == null || taskId.isEmpty) {
        throw Exception('Task ID is required');
      }
      if (pin == null || pin.isEmpty) {
        throw Exception('PIN is required');
      }

      try {
        final client = ref.read(tasksClientProvider);
        final response = await client.verifyProviderPin(taskId, {'pin': pin});

        if (response.success && response.data != null) {
          return response.data!;
        }

        throw Exception(
          response.detail ??
              'The PIN provided is incorrect. For your security, do not allow this provider in.',
        );
      } on DioException catch (e) {
        if (e.response?.data != null && e.response?.data is Map) {
          final detail =
              e.response?.data['detail'] ?? e.response?.data['message'];
          if (detail != null && detail.toString().isNotEmpty) {
            throw Exception(detail.toString());
          }
        }
        if (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.response == null) {
          throw Exception(
            'Network connection error. Please check your internet connection and try again.',
          );
        }
        throw Exception(
          'Failed to verify provider PIN. Please check your network and try again.',
        );
      }
    }, retry: (retryCount, error) => null);
