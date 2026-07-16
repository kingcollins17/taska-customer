import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker_app/core/clients/user_client.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/services/local_storage_service.dart';

final userProvider = AsyncNotifierProvider<UserNotifier, User?>(
  UserNotifier.new,
);

class UserNotifier extends AsyncNotifier<User?> {
  @override
  FutureOr<User?> build() async {
    // Attempt to load the user profile on initialization if a token exists
    final token = await appStorage.get(StorageKey.accessToken);
    if (token != null && token.toString().isNotEmpty) {
      return _fetchUser();
    }
    return null;
  }

  Future<User?> _fetchUser() async {
    try {
      final client = ref.read(userClientProvider);
      final response = await client.getMe();
      if (response.success && response.data != null) {
        return response.data;
      }
    } catch (_) {
      // Ignore errors on initial load or background fetch
    }
    return null;
  }

  /// Logs in the user, saves the token, and fetches their profile.
  Future<void> login({
    required String username,
    required String password,
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      final client = ref.read(userClientProvider);
      final response = await client.login(username, password);

      if (response.accessToken != null) {
        await appStorage.set(StorageKey.accessToken, response.accessToken!);
        final user = await _fetchUser();
        state = AsyncData(user);
        onSuccess?.call();
      } else {
        throw response.detail ?? 'Login failed: No access token received.';
      }
    } catch (e, st) {
      onError?.call(e.toFriendlyMessage());

      AppErrorHandler.instance.handleError(e, st);
    }
  }

  /// Registers a new user.
  Future<void> register({
    required RegisterRequest request,
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      final client = ref.read(userClientProvider);
      final response = await client.registerUser(request);

      if (response.success) {
        onSuccess?.call();
      } else {
        throw response.detail ?? 'Registration failed.';
      }
    } catch (e, st) {
      onError?.call(e.toFriendlyMessage());

      AppErrorHandler.instance.handleError(e, st);
    }
  }

  Future<void> requestEmailOtp({
    required RequestEmailOtpRequest request,
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      final client = ref.read(userClientProvider);
      final response = await client.requestEmailOtp(request);

      if (response.success) {
        onSuccess?.call();
      } else {
        throw response.detail ?? 'Failed to request email OTP.';
      }
    } catch (e, st) {
      onError?.call(e.toFriendlyMessage());

      AppErrorHandler.instance.handleError(e, st);
    }
  }

  Future<void> verifyEmail({
    required VerifyEmailRequest request,
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      final client = ref.read(userClientProvider);
      final response = await client.verifyEmail(request);

      if (response.success) {
        final user = await _fetchUser();
        state = AsyncData(user);
        onSuccess?.call();
      } else {
        throw response.detail ?? 'Failed to verify email.';
      }
    } catch (e, st) {
      onError?.call(e.toFriendlyMessage());

      AppErrorHandler.instance.handleError(e, st);
    }
  }

  Future<void> requestPhoneOtp({
    required RequestPhoneOtpRequest request,
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      final client = ref.read(userClientProvider);
      final response = await client.requestPhoneOtp(request);

      if (response.success) {
        onSuccess?.call();
      } else {
        throw response.detail ?? 'Failed to request phone OTP.';
      }
    } catch (e, st) {
      onError?.call(e.toFriendlyMessage());

      AppErrorHandler.instance.handleError(e, st);
    }
  }

  Future<void> verifyPhone({
    required VerifyPhoneRequest request,
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      final client = ref.read(userClientProvider);
      final response = await client.verifyPhone(request);

      if (response.success) {
        final user = await _fetchUser();
        state = AsyncData(user);
        onSuccess?.call();
      } else {
        throw response.detail ?? 'Failed to verify phone.';
      }
    } catch (e, st) {
      onError?.call(e.toFriendlyMessage());

      AppErrorHandler.instance.handleError(e, st);
    }
  }

  Future<void> updateProfile({
    required UpdateProfileRequest request,
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      final client = ref.read(userClientProvider);
      final response = await client.updateSeekerProfile(request);

      if (response.success) {
        final user = await _fetchUser();
        state = AsyncData(user);
        onSuccess?.call();
      } else {
        throw response.detail ?? 'Failed to update profile.';
      }
    } catch (e, st) {
      onError?.call(e.toFriendlyMessage());
      AppErrorHandler.instance.handleError(e, st);
    }
  }

  /// Logs out the user and clears the token.
  Future<void> logout({
    void Function()? onSuccess,
    void Function(String message)? onError,
  }) async {
    try {
      await appStorage.delete(StorageKey.accessToken);
      state = const AsyncData(null);
      onSuccess?.call();
    } catch (e, st) {
      onError?.call(e.toFriendlyMessage());

      AppErrorHandler.instance.handleError(e, st);
    }
  }
}

final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final user = await ref.watch(userProvider.future);
  return user != null;
});
