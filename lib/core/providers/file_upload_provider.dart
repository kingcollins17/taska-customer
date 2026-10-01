import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker_app/core/clients/utils_client.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/services/local_storage_service.dart';

/// AsyncNotifier for handling single/multiple file uploads and file deletions via [UtilsClient].
/// State is [void] to track loading and error status of file operations.
class FileUploadNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    return null;
  }

  /// Upload a single file.
  Future<FileUploadData?> uploadSingle(
    File file, {
    void Function(FileUploadData)? onSuccess,
    void Function(String)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(utilsClientProvider);
      final response = await client.uploadSingleFile(file);

      if (response.success && response.data != null) {
        state = const AsyncData(null);
        final fileData = response.data!;
        if (fileData.url != null) {
          await ref.read(uploadedFileUrlsProvider.notifier).addUrl(fileData.url!);
        }
        onSuccess?.call(fileData);
        return fileData;
      } else {
        final errorMsg =
            response.detail ?? response.message ?? 'Failed to upload file';
        state = AsyncError(errorMsg, StackTrace.current);
        onError?.call(errorMsg);
        return null;
      }
    } catch (e, st) {
      final friendlyError = e.toFriendlyMessage();
      state = AsyncError(friendlyError, st);
      onError?.call(friendlyError);
      AppErrorHandler.instance.handleError(e, st);
      return null;
    }
  }

  /// Upload multiple files in parallel.
  Future<List<FileUploadData>> uploadMultiple(
    List<File> files, {
    void Function(List<FileUploadData>)? onSuccess,
    void Function(String)? onError,
  }) async {
    if (files.isEmpty) {
      onSuccess?.call([]);
      return [];
    }

    state = const AsyncLoading();
    try {
      final client = ref.read(utilsClientProvider);
      final response = await client.uploadMultipleFiles(files);

      if (response.success && response.data != null) {
        final uploadedList = response.data!.files ?? [];
        state = const AsyncData(null);

        final urls = uploadedList.map((f) => f.url).whereType<String>();
        await ref.read(uploadedFileUrlsProvider.notifier).addUrls(urls);

        onSuccess?.call(uploadedList);
        return uploadedList;
      } else {
        final errorMsg =
            response.detail ?? response.message ?? 'Failed to upload files';
        state = AsyncError(errorMsg, StackTrace.current);
        onError?.call(errorMsg);
        return [];
      }
    } catch (e, st) {
      final friendlyError = e.toFriendlyMessage();
      state = AsyncError(friendlyError, st);
      onError?.call(friendlyError);
      AppErrorHandler.instance.handleError(e, st);
      return [];
    }
  }

  /// Delete multiple files by their URLs.
  Future<bool> deleteFiles(
    List<String> fileUrls, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    if (fileUrls.isEmpty) {
      onSuccess?.call();
      return true;
    }

    state = const AsyncLoading();
    try {
      final client = ref.read(utilsClientProvider);
      final response = await client.deleteMultipleFiles(
        DeleteFilesRequest(fileUrls: fileUrls),
      );

      if (response.success) {
        state = const AsyncData(null);
        await ref.read(uploadedFileUrlsProvider.notifier).removeUrls(fileUrls);
        onSuccess?.call();
        return true;
      } else {
        final errorMsg =
            response.detail ?? response.message ?? 'Failed to delete files';
        state = AsyncError(errorMsg, StackTrace.current);
        onError?.call(errorMsg);
        return false;
      }
    } catch (e, st) {
      final friendlyError = e.toFriendlyMessage();
      state = AsyncError(friendlyError, st);
      onError?.call(friendlyError);
      AppErrorHandler.instance.handleError(e, st);
      return false;
    }
  }

  /// Delete a single file by URL.
  Future<bool> deleteSingleFile(
    String fileUrl, {
    VoidCallback? onSuccess,
    void Function(String)? onError,
  }) async {
    return deleteFiles([fileUrl], onSuccess: onSuccess, onError: onError);
  }
}

/// Riverpod provider for handling file upload and deletion requests.
final fileUploadProvider =
    AsyncNotifierProvider<FileUploadNotifier, void>(
      FileUploadNotifier.new,
    );

/// AsyncNotifier for managing tracked uploaded file URLs.
/// Maintains a state of [Set<String>] and persists it to local storage via [appStorage].
class UploadedFileUrlsNotifier extends AsyncNotifier<Set<String>> {
  @override
  FutureOr<Set<String>> build() async {
    return _load();
  }

  Future<Set<String>> _load() async {
    try {
      final rawData = await appStorage.get(StorageKey.uploadedFileUrls);
      if (rawData != null && rawData is String && rawData.isNotEmpty) {
        final decoded = jsonDecode(rawData);
        if (decoded is List) {
          return decoded.cast<String>().toSet();
        }
      }
    } catch (e, st) {
      AppErrorHandler.instance.handleError(e, st);
    }
    return <String>{};
  }

  Future<void> _save(Set<String> urls) async {
    try {
      final jsonStr = jsonEncode(urls.toList());
      await appStorage.set(StorageKey.uploadedFileUrls, jsonStr);
    } catch (e, st) {
      AppErrorHandler.instance.handleError(e, st);
    }
  }

  /// Add a single URL to the tracked set.
  Future<void> addUrl(String url) async {
    final current = state.value ?? <String>{};
    final updated = {...current, url};
    state = AsyncData(updated);
    await _save(updated);
  }

  /// Add multiple URLs to the tracked set.
  Future<void> addUrls(Iterable<String> urls) async {
    final current = state.value ?? <String>{};
    final updated = {...current, ...urls};
    state = AsyncData(updated);
    await _save(updated);
  }

  /// Remove a single URL from the tracked set.
  Future<void> removeUrl(String url) async {
    final current = state.value ?? <String>{};
    final updated = current.where((u) => u != url).toSet();
    state = AsyncData(updated);
    await _save(updated);
  }

  /// Remove multiple URLs from the tracked set.
  Future<void> removeUrls(Iterable<String> urls) async {
    final removeSet = urls.toSet();
    final current = state.value ?? <String>{};
    final updated = current.where((u) => !removeSet.contains(u)).toSet();
    state = AsyncData(updated);
    await _save(updated);
  }

  /// Clear all tracked URLs from state and storage.
  Future<void> clear() async {
    state = const AsyncData(<String>{});
    await appStorage.delete(StorageKey.uploadedFileUrls);
  }
}

/// Provider for tracked uploaded file URLs.
final uploadedFileUrlsProvider =
    AsyncNotifierProvider<UploadedFileUrlsNotifier, Set<String>>(
      UploadedFileUrlsNotifier.new,
    );

/// Provider that syncs and deletes orphaned uploaded file URLs on app startup if any exist.
final syncUploadedFileUrlsProvider = FutureProvider<void>((ref) async {
  final fileUrls = await ref.watch(uploadedFileUrlsProvider.future);
  if (fileUrls.isNotEmpty) {
    final notifier = ref.read(fileUploadProvider.notifier);
    await notifier.deleteFiles(fileUrls.toList());
  }
});
