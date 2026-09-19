import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker_app/core/clients/support_client.dart';
import 'package:seeker_app/core/constants.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/models/models.dart';

/// Notifier for listing user cases with pagination and optional taskId filter.
class UserCasesNotifier extends AsyncNotifier<List<SupportCase>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  final String? taskId;

  UserCasesNotifier([this.taskId]);

  @override
  FutureOr<List<SupportCase>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchCases();
  }

  Future<List<SupportCase>> _fetchCases() async {
    final client = ref.read(supportClientProvider);
    final response = await client.listUserCases(
      page: _page,
      perPage: _perPage,
      taskId: taskId,
    );

    if (response.success && response.data != null) {
      final items = response.data!.items ?? [];
      if (items.length < _perPage) {
        _hasMore = false;
      }
      return items;
    } else {
      throw Exception(response.detail ?? response.message ?? 'Failed to load support cases');
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading || state.isRefreshing) return;

    final currentData = state.value ?? [];
    _page++;

    try {
      final newItems = await _fetchCases();
      state = AsyncData([...currentData, ...newItems]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchCases());
  }
}

final userCasesProvider = AsyncNotifierProvider.family<
    UserCasesNotifier, List<SupportCase>, String?>((param) =>
  UserCasesNotifier(param),
  retry: retryFunc(2)
);

/// Provider for fetching details of a specific case by caseId.
final caseDetailProvider = FutureProvider.family<SupportCase, String>((
  ref,
  caseId,
) async {
  final client = ref.read(supportClientProvider);
  final response = await client.getUserCase(caseId);

  if (response.success && response.data != null) {
    return response.data!;
  }
  throw Exception(response.detail ?? response.message ?? 'Failed to load case details');
}, retry: retryFunc(2));

/// Notifier for fetching messages for a specific case with pagination.
class CaseMessagesNotifier extends AsyncNotifier<List<SupportCaseMessage>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  final String caseId;

  CaseMessagesNotifier(this.caseId);

  @override
  FutureOr<List<SupportCaseMessage>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchMessages();
  }

  Future<List<SupportCaseMessage>> _fetchMessages() async {
    final client = ref.read(supportClientProvider);
    final response = await client.getCaseMessages(
      caseId,
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
      throw Exception(response.detail ?? response.message ?? 'Failed to load case messages');
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading || state.isRefreshing) return;

    final currentData = state.value ?? [];
    _page++;

    try {
      final newItems = await _fetchMessages();
      state = AsyncData([...currentData, ...newItems]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchMessages());
  }
}

final caseMessagesProvider = AsyncNotifierProvider.family<
    CaseMessagesNotifier, List<SupportCaseMessage>, String>(
  (caseId) => CaseMessagesNotifier(caseId),
  retry: retryFunc()
);

/// Notifier for fetching case timeline with pagination.
class CaseTimelineNotifier extends AsyncNotifier<List<SupportCaseTimelineItem>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  final String caseId;

  CaseTimelineNotifier(this.caseId);

  @override
  FutureOr<List<SupportCaseTimelineItem>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchTimeline();
  }

  Future<List<SupportCaseTimelineItem>> _fetchTimeline() async {
    final client = ref.read(supportClientProvider);
    final response = await client.getCaseTimeline(
      caseId,
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
      throw Exception(response.detail ?? response.message ?? 'Failed to load case timeline');
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading || state.isRefreshing) return;

    final currentData = state.value ?? [];
    _page++;

    try {
      final newItems = await _fetchTimeline();
      state = AsyncData([...currentData, ...newItems]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchTimeline());
  }
}

final caseTimelineProvider = AsyncNotifierProvider.family<
    CaseTimelineNotifier, List<SupportCaseTimelineItem>, String>(
  (caseId) => CaseTimelineNotifier(caseId),
  retry: retryFunc(2)
);

/// Notifier for performing actions on support cases (create case, send message, upload attachment, close/reopen case).
class SupportActionsNotifier extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Create a new support case
  Future<void> createCase({
    required CreateSupportCaseRequest request,
    void Function(SupportCase caseItem)? onSuccess,
    void Function(String error)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(supportClientProvider);
      final response = await client.createCase(request);

      if (response.success && response.data != null) {
        state = const AsyncData(null);
        ref.invalidate(userCasesProvider(null));
        if (request.taskId != null) {
          ref.invalidate(userCasesProvider(request.taskId));
        }
        onSuccess?.call(response.data!);
      } else {
        final error = response.detail ?? response.message ?? 'Failed to create support case';
        state = AsyncError(error, StackTrace.current);
        onError?.call(error);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      AppErrorHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyMessage());
    }
  }

  /// Send a message to an existing case
  Future<void> sendMessage({
    required String caseId,
    required SendSupportMessageRequest request,
    void Function(SupportCaseMessage message)? onSuccess,
    void Function(String error)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(supportClientProvider);
      final response = await client.sendUserMessage(caseId, request);

      if (response.success && response.data != null) {
        state = const AsyncData(null);
        ref.invalidate(caseMessagesProvider(caseId));
        ref.invalidate(caseTimelineProvider(caseId));
        onSuccess?.call(response.data!);
      } else {
        final error = response.detail ?? response.message ?? 'Failed to send message';
        state = AsyncError(error, StackTrace.current);
        onError?.call(error);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      AppErrorHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyMessage());
    }
  }

  /// Upload an attachment for a case
  Future<void> uploadAttachment({
    required String caseId,
    required File file,
    String? messageId,
    void Function(SupportCaseAttachment attachment)? onSuccess,
    void Function(String error)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(supportClientProvider);
      final response = await client.uploadAttachment(
        caseId,
        file,
        messageId: messageId,
      );

      if (response.success && response.data != null) {
        state = const AsyncData(null);
        ref.invalidate(caseMessagesProvider(caseId));
        onSuccess?.call(response.data!);
      } else {
        final error = response.detail ?? response.message ?? 'Failed to upload attachment';
        state = AsyncError(error, StackTrace.current);
        onError?.call(error);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      AppErrorHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyMessage());
    }
  }

  /// Close a support case
  Future<void> closeCase({
    required String caseId,
    void Function(SupportCase caseItem)? onSuccess,
    void Function(String error)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(supportClientProvider);
      final response = await client.closeUserCase(caseId);

      if (response.success && response.data != null) {
        state = const AsyncData(null);
        ref.invalidate(caseDetailProvider(caseId));
        ref.invalidate(userCasesProvider(null));
        ref.invalidate(caseTimelineProvider(caseId));
        onSuccess?.call(response.data!);
      } else {
        final error = response.detail ?? response.message ?? 'Failed to close support case';
        state = AsyncError(error, StackTrace.current);
        onError?.call(error);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      AppErrorHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyMessage());
    }
  }

  /// Reopen a support case
  Future<void> reopenCase({
    required String caseId,
    void Function(SupportCase caseItem)? onSuccess,
    void Function(String error)? onError,
  }) async {
    state = const AsyncLoading();
    try {
      final client = ref.read(supportClientProvider);
      final response = await client.reopenUserCase(caseId);

      if (response.success && response.data != null) {
        state = const AsyncData(null);
        ref.invalidate(caseDetailProvider(caseId));
        ref.invalidate(userCasesProvider(null));
        ref.invalidate(caseTimelineProvider(caseId));
        onSuccess?.call(response.data!);
      } else {
        final error = response.detail ?? response.message ?? 'Failed to reopen support case';
        state = AsyncError(error, StackTrace.current);
        onError?.call(error);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
      AppErrorHandler.instance.handleError(e, st);
      onError?.call(e.toFriendlyMessage());
    }
  }
}

final supportActionsProvider =
    AsyncNotifierProvider<SupportActionsNotifier, void>(
  () => SupportActionsNotifier(),
);
