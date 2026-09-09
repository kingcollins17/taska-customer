import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker_app/core/clients/reviews_client.dart';
import 'package:seeker_app/core/constants.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/task_providers.dart';
import 'package:seeker_app/core/services/local_storage_service.dart';

class TaskReviewPromptLog {
  final String taskId;
  final DateTime lastShownAt;

  const TaskReviewPromptLog({
    required this.taskId,
    required this.lastShownAt,
  });

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'lastShownAt': lastShownAt.toIso8601String(),
      };

  factory TaskReviewPromptLog.fromJson(Map<String, dynamic> json) {
    return TaskReviewPromptLog(
      taskId: json['taskId'] as String,
      lastShownAt: DateTime.parse(json['lastShownAt'] as String),
    );
  }
}

class TaskReviewPromptHistoryNotifier
    extends Notifier<List<TaskReviewPromptLog>> {
  @override
  List<TaskReviewPromptLog> build() {
    return _loadFromStorage();
  }

  List<TaskReviewPromptLog> _loadFromStorage() {
    try {
      final box = appStorage.syncBox;
      final rawData = box.get(StorageKey.reviewPromptHistory.name);
      if (rawData is List) {
        return rawData
            .whereType<Map>()
            .map(
              (e) => TaskReviewPromptLog.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<void> _save() async {
    try {
      final jsonList = state.map((item) => item.toJson()).toList();
      await appStorage.set(StorageKey.reviewPromptHistory, jsonList);
    } catch (_) {}
  }

  Future<void> _clear() async {
    state = [];
    try {
      await appStorage.delete(StorageKey.reviewPromptHistory);
    } catch (_) {}
  }

  Future<void> clear() async => _clear();

  Future<void> updatePromptShown(String taskId, [DateTime? lastShownAt]) async {
    final now = lastShownAt ?? DateTime.now();
    final updatedList = List<TaskReviewPromptLog>.from(state);
    final index = updatedList.indexWhere((item) => item.taskId == taskId);

    if (index >= 0) {
      updatedList[index] = TaskReviewPromptLog(
        taskId: taskId,
        lastShownAt: now,
      );
    } else {
      updatedList.add(
        TaskReviewPromptLog(
          taskId: taskId,
          lastShownAt: now,
        ),
      );
    }

    state = updatedList;
    await _save();
  }
}

final taskReviewPromptHistoryProvider = NotifierProvider<
    TaskReviewPromptHistoryNotifier, List<TaskReviewPromptLog>>(
  TaskReviewPromptHistoryNotifier.new,
);

class PendingReviewsNotifier extends AsyncNotifier<List<PendingReviewTask>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  @override
  FutureOr<List<PendingReviewTask>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchPendingReviews();
  }

  Future<List<PendingReviewTask>> _fetchPendingReviews() async {
    final client = ref.read(reviewsClientProvider);
    final response = await client.getPendingCustomerReviews(
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
      throw Exception(response.detail ?? 'Failed to load pending reviews');
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
      final newItems = await _fetchPendingReviews();
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
      final items = await _fetchPendingReviews();
      state = AsyncValue.data(items);
    } catch (_) {}
  }
}

final pendingReviewsProvider =
    AsyncNotifierProvider<PendingReviewsNotifier, List<PendingReviewTask>>(
  () => PendingReviewsNotifier(),
);

final pendingReviewsCountProvider = FutureProvider<int>((ref) async {
  final client = ref.read(reviewsClientProvider);
  final response = await client.getPendingCustomerReviews(page: 1, perPage: 1);
  if (response.success && response.data != null) {
    return response.data!.total ?? 0;
  }
  return 0;
});

class SubmitReviewNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> submitReview({
    required String taskId,
    required int rating,
    String? comment,
    void Function()? onSuccess,
    void Function(String error)? onError,
  }) async {
    try {
      final client = ref.read(reviewsClientProvider);
      final response = await client.submitReview(
        SubmitReviewRequest(
          taskId: taskId,
          rating: rating,
          comment: comment,
        ),
      );

      if (response.success) {
        // ref.invalidate(pendingReviewsProvider);
        // ref.invalidate(pendingReviewsCountProvider);
        // ref.invalidate(tasksProvider);
        onSuccess?.call();
      } else {
        final error = response.detail ?? 'Failed to submit review';
        onError?.call(error);
      }
    } catch (e, st) {
      AppErrorHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyMessage());
    }
  }
}

final submitReviewProvider = AsyncNotifierProvider<SubmitReviewNotifier, void>(
  () => SubmitReviewNotifier(),
);

final pendingReviewPromptListenerProvider = Provider.autoDispose<void>((ref) {
  void checkAndPrompt(List<PendingReviewTask> pendingTasks) {
    if (pendingTasks.isEmpty) return;

    final historyNotifier = ref.read(taskReviewPromptHistoryProvider.notifier);
    final history = ref.read(taskReviewPromptHistoryProvider);
    final historyMap = {
      for (final item in history) item.taskId: item.lastShownAt,
    };

    final eligibleTasks = pendingTasks.where((task) {
      final id = task.id;
      if (id == null || id.isEmpty) return false;
      final lastShown = historyMap[id];
      if (lastShown == null) return true;
      return DateTime.now().difference(lastShown) >= const Duration(days: 1);
    }).toList();

    if (eligibleTasks.isEmpty) return;

    final random = Random();
    final selectedTask = eligibleTasks[random.nextInt(eligibleTasks.length)];
    final taskId = selectedTask.id!;

    appQueue.add(() async {
      await historyNotifier.updatePromptShown(taskId);
      await SubmitReviewSheet.show(taskId: taskId);
    });
  }

  ref.listen<AsyncValue<List<PendingReviewTask>>>(pendingReviewsProvider,
      (previous, next) {
    if (next.hasValue && next.value != null) {
      checkAndPrompt(next.value!);
    }
  });

  final asyncPending = ref.watch(pendingReviewsProvider);
  if (asyncPending.hasValue && asyncPending.value != null) {
    checkAndPrompt(asyncPending.value!);
  }
});
