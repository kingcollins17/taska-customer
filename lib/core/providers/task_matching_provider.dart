import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/task_providers.dart';
import 'package:seeker_app/core/services/local_storage_service.dart';

/// Provider to manage visibility state of the floating Task Matching Banner.
final showTaskMatchingBannerProvider = StateProvider<bool>((ref) => true);

class TaskMatchingNotifier extends AsyncNotifier<TaskMatchingState?> {
  Timer? _timer;

  @override
  FutureOr<TaskMatchingState?> build() async {
    ref.onDispose(() {
      _timer?.cancel();
    });

    final savedState = await _getSavedState();
    if (savedState != null &&
        savedState.status == MatchingStatus.pending &&
        savedState.taskId != null &&
        savedState.taskId!.isNotEmpty) {
      _startPolling(savedState.taskId!);
    }

    return savedState;
  }

  Future<TaskMatchingState?> _getSavedState() async {
    try {
      final jsonStr = await appStorage.get(StorageKey.matchingState);
      if (jsonStr != null && jsonStr.toString().isNotEmpty) {
        final map = jsonDecode(jsonStr.toString()) as Map<String, dynamic>;
        return TaskMatchingState.fromJson(map);
      }
    } catch (e, st) {
      AppErrorHandler.instance.handleError(e, st);
    }
    return null;
  }

  Future<void> _saveState(TaskMatchingState? matchingState) async {
    try {
      if (matchingState == null) {
        await appStorage.delete(StorageKey.matchingState);
      } else {
        await appStorage.set(
          StorageKey.matchingState,
          jsonEncode(matchingState.toJson()),
        );
      }
    } catch (e, st) {
      AppErrorHandler.instance.handleError(e, st);
    }
  }

  /// Starts polling taskDetailProvider periodically to track task assignment / status.
  Future<void> start(
    String taskId, {
    Duration interval = const Duration(minutes: 1),
  }) async {
    ref.read(showTaskMatchingBannerProvider.notifier).state = true;
    final initialState = TaskMatchingState(
      taskId: taskId,
      status: MatchingStatus.pending,
      task: state.value?.taskId == taskId ? state.value?.task : null,
    );

    state = AsyncData(initialState);
    await _saveState(initialState);

    _startPolling(taskId, interval: interval);
  }

  void _startPolling(
    String taskId, {
    Duration interval = const Duration(minutes: 1),
  }) {
    _timer?.cancel();
    _pollTask(taskId);
    _timer = Timer.periodic(interval, (_) {
      _pollTask(taskId);
    });
  }

  /// Polls task details and invalidates taskDetailProvider.
  Future<void> _pollTask(String taskId) async {
    try {
      // ref.invalidate(taskDetailProvider(taskId));
      ref.invalidate(taskAssignmentProvider(taskId));

      final task = await ref.read(taskDetailProvider(taskId).future);

      final statusStr = task.status?.toLowerCase() ?? '';
      final isAssigned =
          task.assignment != null || statusStr.contains('assigned');
      final isCancelled = statusStr.contains('cancelled');

      MatchingStatus status;
      if (isAssigned) {
        status = MatchingStatus.success;
        ref.invalidate(taskDetailProvider(taskId));
      } else if (isCancelled) {
        status = MatchingStatus.cancelled;
        ref.invalidate(taskDetailProvider(taskId));
      } else {
        status = MatchingStatus.pending;
      }

      final newState = TaskMatchingState(
        taskId: taskId,
        status: status,
        task: task,
      );

      state = AsyncData(newState);
      await _saveState(newState);

      if (status == MatchingStatus.success ||
          status == MatchingStatus.cancelled) {
        stop();
      }
    } catch (e) {
      // Keep state as-is or handle error if needed while continuing poll
    }
  }

  /// Stops periodic polling.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  /// Clears matching state and deletes it from local storage.
  Future<void> clear() async {
    stop();
    state = const AsyncData(null);
    await _saveState(null);
  }
}

final taskMatchingProvider =
    AsyncNotifierProvider.autoDispose<TaskMatchingNotifier, TaskMatchingState?>(
      () => TaskMatchingNotifier(),
    );

