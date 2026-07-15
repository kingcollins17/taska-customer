import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker_app/core/clients/tasks_client.dart';
import 'package:seeker_app/core/core.dart';

/// Notifier responsible for managing the state of task attachments being collected.
class TaskAttachmentUploadNotifier extends AsyncNotifier<List<File>> {
  /// Initializes the state of the attachment upload process with an empty list.
  @override
  FutureOr<List<File>> build() async {
    return [];
  }

  /// Resets the attachments state to an empty list.
  ///
  /// This should be called at the beginning of a new task creation flow
  /// or when attachments need to be cleared completely.
  ///
  /// Parameters:
  /// - [onSuccess]: Optional callback executed when the state is successfully reset.
  /// - [onError]: Optional callback executed if an error occurs during reset.
  Future<void> reset({
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      state = const AsyncData([]);
      onSuccess?.call();
    } catch (e, st) {
      onError?.call(e.toFriendlyMessage());
      AppErrorHandler.instance.handleError(e, st);
    }
  }

  /// Adds a new file to the attachments list.
  ///
  /// If the file is already in the list, it will not be added again.
  ///
  /// Parameters:
  /// - [file]: The [File] object to add to the attachments.
  Future<void> addAttachment(File file) async {
    if (!state.hasValue) {
      await reset();
    }
    final current = state.value ?? [];
    if (!current.any((f) => f.path == file.path)) {
      state = AsyncData([...current, file]);
    }
  }

  /// Removes a file from the attachments list.
  ///
  /// Parameters:
  /// - [file]: The [File] object to remove from the attachments.
  Future<void> removeAttachment(File file) async {
    if (!state.hasValue) {
      await reset();
    }
    final current = state.value ?? [];
    final updated = current.where((f) => f.path != file.path).toList();
    state = AsyncData(updated);
  }

  /// Submits the collected attachments to the backend API.
  ///
  /// Uploads each file individually to the given [taskId] using [tasksClientProvider].
  /// Upon successful upload of all files, it clears the local state.
  ///
  /// Parameters:
  /// - [taskId]: The unique identifier of the task to attach files to.
  /// - [onSuccess]: Optional callback executed if all files upload successfully.
  /// - [onError]: Optional callback executed with a user-friendly message if any upload fails.
  Future<void> upload({
    required String taskId,
    void Function()? onSuccess,
    void Function(String)? onError,
  }) async {
    try {
      final files = state.value;
      if (files == null || files.isEmpty) {
        throw 'No attachments to upload';
      }

      final client = ref.read(tasksClientProvider);
      for (final file in files) {
        final response = await client.uploadAttachment(taskId, file);
        if (!response.success) {
          throw response.detail ?? 'Something went wrong while uploading attachments';
        }
      }
      
      state = const AsyncData([]);
      onSuccess?.call();
    } catch (e, st) {
      onError?.call(e.toFriendlyMessage());
      AppErrorHandler.instance.handleError(e, st);
    }
  }
}

/// Provider for the [TaskAttachmentUploadNotifier], managing the global state of task
/// attachments throughout the task creation flow.
final taskAttachmentUploadProvider =
    AsyncNotifierProvider<TaskAttachmentUploadNotifier, List<File>>(() {
      return TaskAttachmentUploadNotifier();
    });
