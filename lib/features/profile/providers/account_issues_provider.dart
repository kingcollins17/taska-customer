import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker_app/core/constants.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/user_provider.dart';
import 'package:seeker_app/core/designs/widgets/phone_number_sheet.dart';
import 'package:seeker_app/features/auth/presentation/verify_otp_screen.dart';

class AccountIssue {
  final String title;
  final String description;
  final dynamic icon;
  final void Function(BuildContext context, User user)? handler;

  AccountIssue({
    required this.title,
    required this.description,
    this.icon,
    this.handler,
  });
}

final accountIssuesProvider = Provider<List<AccountIssue>>((ref) {
  final user = ref.watch(userProvider).value;
  final issues = <AccountIssue>[];

  if (user != null) {
    if (user.phoneVerified != true) {
      issues.add(
        AccountIssue(
          title: 'Verify Phone Number',
          description: 'Tap to verify your phone number.',
          icon: Icons.warning_amber_rounded,
          handler: (context, user) => _handleVerifyPhone(context, ref, user),
        ),
      );
    }

    // Add other issues here later, e.g. low credibility
  }

  return issues;
});

Future<void> _handleVerifyPhone(
  BuildContext context,
  Ref ref,
  User user,
) async {
  String? phoneToVerify = user.phoneNumber;

  'Context mounted ${context.mounted}'.debugLog();
  if (phoneToVerify == null || phoneToVerify.isEmpty) {
    phoneToVerify = await PhoneNumberSheet.collect(
      rootNavigatorKey.currentContext ?? context,
    );
    if (phoneToVerify == null || phoneToVerify.isEmpty) return;

    var updateSuccess = false;
    context.showLoading();
    await ref
        .read(userProvider.notifier)
        .updateProfile(
          request: UpdateProfileRequest(phoneNumber: phoneToVerify),
          onSuccess: () {
            updateSuccess = true;
          },
          onError: (err) {
            context.showMessage(err, type: MessageType.error);
          },
        );
    context.hideLoading();
    if (!updateSuccess) return;
  }

  if (!context.mounted) return;
  context.showLoading();

  bool requestSuccess = false;
  await ref
      .read(userProvider.notifier)
      .requestPhoneOtp(
        request: RequestPhoneOtpRequest(phoneNumber: phoneToVerify),
        onSuccess: () {
          requestSuccess = true;
        },
        onError: (msg) {
          context.showMessage(msg, type: MessageType.error);
        },
      );

  if (!context.mounted) return;
  context.hideLoading();

  if (requestSuccess) {
    await VerifyOTPScreen.verify(
      context,
      title: 'Verify Phone Number',
      verifier: (otp) async {
        bool verifySuccess = false;
        await ref
            .read(userProvider.notifier)
            .verifyPhone(
              request: VerifyPhoneRequest(
                phoneNumber: phoneToVerify!,
                code: otp,
              ),
              onSuccess: () {
                verifySuccess = true;

                // If successful,invalidate user profile
                ref.invalidate(userProvider);
              },
              onError: (msg) {
                verifySuccess = false;
              },
            );
        return verifySuccess;
      },
      resender: () async {
        await ref
            .read(userProvider.notifier)
            .requestPhoneOtp(
              request: RequestPhoneOtpRequest(phoneNumber: phoneToVerify!),
              onSuccess: () {
                context.showMessage(
                  'OTP sent successfully',
                  type: MessageType.success,
                );
              },
              onError: (msg) {
                context.showMessage(msg, type: MessageType.error);
              },
            );
      },
    );
  }
}
