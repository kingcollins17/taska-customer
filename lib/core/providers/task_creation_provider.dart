import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker_app/core/clients/tasks_client.dart';
import 'package:seeker_app/core/core.dart';
import '../models/models.dart';
import '../services/local_storage_service.dart';

/// Notifier responsible for managing the state of a task being created.
/// It persists the draft to local storage to prevent data loss.
class TaskCreationNotifier extends AsyncNotifier<CreateTaskRequest?> {
  /// Initializes the state of the task creation process.
  ///
  /// Attempts to retrieve a previously saved draft from local storage.
  /// If a valid draft is found, it initializes the state with that draft.
  /// Otherwise, it returns `null` to indicate no active draft.
  @override
  FutureOr<CreateTaskRequest?> build() async {
    return _getSavedDraft();
  }

  /// Resets the task creation state to a fresh [CreateTaskRequest].
  ///
  /// This should be called at the beginning of a new task creation flow.
  /// It initializes a new empty draft and saves it to local storage.
  ///
  /// Parameters:
  /// - [onSuccess]: Optional callback executed when the state is successfully reset.
  /// - [onError]: Optional callback executed if an error occurs during reset,
  ///   providing a user-friendly error message.
  Future<void> reset({
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      _updateState(CreateTaskRequest());
    } catch (e, st) {
      onError?.call(e.toFriendlyMessage());
      AppErrorHandler.instance.handleError(e, st);
    }
  }

  /// Retrieves and decodes a saved task draft from local storage.
  ///
  /// Returns a [CreateTaskRequest] if a draft exists and is successfully decoded.
  /// If no draft exists or decoding fails, it catches the error using
  /// [AppErrorHandler] and returns `null`.
  Future<CreateTaskRequest?> _getSavedDraft() async {
    final draftStr = await appStorage.get(StorageKey.taskDraft);
    if (draftStr != null) {
      try {
        final Map<String, dynamic> draftMap = jsonDecode(draftStr);
        return CreateTaskRequest.fromJson(draftMap);
      } catch (e, st) {
        AppErrorHandler.instance.handleError(e, st);
        return null;
      }
    }
    return null;
  }

  /// Updates the current state with the new [value] and persists it.
  ///
  /// This method updates the [AsyncNotifier] state to an [AsyncData] containing
  /// the new draft, and asynchronously saves the draft to local storage.
  Future<void> _updateState(CreateTaskRequest value) {
    state = AsyncData(value);
    return _save(value);
  }

  /// Serializes the provided [request] and saves it to local storage.
  ///
  /// The draft is saved under the [StorageKey.taskDraft] key as a JSON string.
  Future<void> _save(CreateTaskRequest request) async {
    await appStorage.set(StorageKey.taskDraft, jsonEncode(request.toJson()));
  }

  /// Removes the currently saved task draft from local storage.
  ///
  /// This is typically called after a successful task submission to clean up
  /// the stale draft data or when discarding a draft.
  Future<void> _delete() async {
    await appStorage.delete(StorageKey.taskDraft);
  }

  /// Updates the selected category for the task draft.
  ///
  /// Setting a new category automatically clears any previously selected service,
  /// since services are scoped to specific categories.
  /// If the draft hasn't been initialized, it calls [reset] first.
  ///
  /// Parameters:
  /// - [categoryId]: The unique identifier of the selected category.
  Future<void> updateCategory(String categoryId) async {
    if (!state.hasValue || state.value == null) {
      await reset();
    }
    final current = state.value;
    if (current != null) {
      _updateState(current.copyWith(categoryId: categoryId, serviceId: null));
    }
  }

  /// Updates the selected service for the task draft.
  ///
  /// If the draft hasn't been initialized, it calls [reset] first.
  ///
  /// Parameters:
  /// - [serviceId]: The unique identifier of the selected service.
  Future<void> updateService(String serviceId) async {
    if (!state.hasValue || state.value == null) {
      await reset();
    }
    final current = state.value;
    if (current != null) {
      _updateState(current.copyWith(serviceId: serviceId));
    }
  }

  /// Updates the title and description of the task draft.
  ///
  /// If the draft hasn't been initialized, it calls [reset] first.
  ///
  /// Parameters:
  /// - [title]: The main title or headline of the task.
  /// - [description]: An optional detailed description of the task requirements.
  Future<void> updateDescription({
    required String title,
    String? description,
  }) async {
    if (!state.hasValue || state.value == null) {
      await reset();
    }
    final current = state.value;
    if (current != null) {
      _updateState(current.copyWith(title: title, description: description));
    }
  }

  /// Updates the budget details and pricing model for the task draft.
  ///
  /// If the draft hasn't been initialized, it calls [reset] first.
  ///
  /// Parameters:
  /// - [min]: The optional minimum budget amount.
  /// - [max]: The optional maximum budget amount.
  /// - [pricingModel]: The pricing model string (e.g., 'fixed', 'hourly').
  Future<void> updateBudget({
    double? min,
    double? max,
    String? pricingModel,
  }) async {
    if (!state.hasValue || state.value == null) {
      await reset();
    }
    final current = state.value;
    if (current != null) {
      _updateState(
        current.copyWith(
          budgetMin: min,
          budgetMax: max,
          pricingModel: pricingModel,
        ),
      );
    }
  }

  /// Updates the location required for the task.
  ///
  /// Currently replaces the existing locations array with a single new location.
  /// If the draft hasn't been initialized, it calls [reset] first.
  ///
  /// Parameters:
  /// - [location]: The [CreateTaskLocationRequest] object representing the task location.
  Future<void> updateLocation(CreateTaskLocationRequest location) async {
    if (!state.hasValue || state.value == null) {
      await reset();
    }
    final current = state.value;
    if (current != null) {
      _updateState(
        current.copyWith(
          locations: [location.copyWith(locationType: 'service')],
        ),
      );
    }
  }

  /// Updates the scheduling timeline for the task draft.
  ///
  /// If the draft hasn't been initialized, it calls [reset] first.
  ///
  /// Parameters:
  /// - [startAt]: Optional date and time when the task is scheduled to start.
  /// - [expiresAt]: Optional date and time when the task request expires.
  Future<void> updateSchedule({DateTime? startAt, DateTime? expiresAt}) async {
    if (!state.hasValue || state.value == null) {
      await reset();
    }
    final current = state.value;
    if (current != null) {
      _updateState(
        current.copyWith(scheduledStartAt: startAt, expiresAt: expiresAt),
      );
    }
  }

  /// Submits the completed task draft to the backend API.
  ///
  /// This method reads the current state, ensuring it exists, and then sends it
  /// via the [tasksClientProvider]. Upon success, it deletes the local draft
  /// and triggers the [onSuccess] callback. Upon failure, it throws an error
  /// which is caught and sent to the [onError] callback and logged via [AppErrorHandler].
  ///
  /// Parameters:
  /// - [onSuccess]: Optional callback executed if the task is created successfully.
  /// - [onError]: Optional callback executed with a user-friendly message if submission fails.
  Future<void> submit({
    void Function(String? taskId)? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final request = state.value;
      if (request == null) throw 'No draft to submit';

      final response = await ref.read(tasksClientProvider).createTask(request);
      if (response.success) {
        await _delete();
        final data = response.data ?? {};
        onSuccess?.call(data['id']?.toString());
      } else {
        throw response.detail ?? 'Something went wrong while posting this task';
      }
    } catch (e, st) {
      onError?.call(e.toFriendlyMessage());
      AppErrorHandler.instance.handleError(e, st);
    }
  }
}

/// Provider for the [TaskCreationNotifier], managing the global state of a task
/// draft throughout the task creation flow.
final taskCreationProvider =
    AsyncNotifierProvider<TaskCreationNotifier, CreateTaskRequest?>(() {
      return TaskCreationNotifier();
    });
