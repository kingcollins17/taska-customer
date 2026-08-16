import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/widgets/primary_button.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/task_providers.dart';
import 'package:url_launcher/url_launcher.dart';

class ProviderIdentityResultSheet extends ConsumerWidget {
  final String taskId;
  final String pin;

  const ProviderIdentityResultSheet({
    super.key,
    required this.taskId,
    required this.pin,
  });

  static Future<T?> show<T>(
    BuildContext context, {
    required String taskId,
    required String pin,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          ProviderIdentityResultSheet(taskId: taskId, pin: pin),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final verificationState = ref.watch(
      verifyProviderPinProvider((taskId: taskId, pin: pin)),
    );

    return Container(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 12.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Row with Drag Handle & Close 'X' Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 24.w),
                Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedCancel01,
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    size: 20.sp,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Provider State Content
            verificationState.when(
              data: (provider) => _buildSuccessContent(context, provider),
              loading: () => _buildLoadingContent(context),
              error: (error, stackTrace) =>
                  _buildErrorContent(context, ref, error.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        children: [
          CircularProgressIndicator(color: AppColors.primary, strokeWidth: 3),
          SizedBox(height: 14.h),
          Text(
            'Verifying provider identity...',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(
    BuildContext context,
    TaskAssignmentProvider provider,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success Header Badge
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                color: AppColors.primary,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Identity Verified!',
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  Text(
                    'Safe and authorized provider',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      color: colorScheme.onSurface.withValues(alpha: 0.65),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),

        // Compact Provider Details Card
        Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    backgroundImage:
                        provider.profilePictureUrl != null &&
                            provider.profilePictureUrl!.isNotEmpty
                        ? NetworkImage(provider.profilePictureUrl!)
                        : null,
                    child:
                        (provider.profilePictureUrl == null ||
                            provider.profilePictureUrl!.isEmpty)
                        ? Text(
                            (provider.fullname ?? 'P')[0].toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          provider.fullname ?? 'Assigned Provider',
                          style: GoogleFonts.inter(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        if (provider.phoneNumber != null ||
                            provider.email != null) ...[
                          SizedBox(height: 2.h),
                          Text(
                            provider.phoneNumber ?? provider.email!,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: colorScheme.onSurface.withValues(
                                alpha: 0.65,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (provider.phoneNumber != null &&
                      provider.phoneNumber!.isNotEmpty) ...[
                    SizedBox(width: 8.w),
                    InkWell(
                      onTap: () async {
                        final tel = Uri(
                          scheme: 'tel',
                          path: provider.phoneNumber,
                        );
                        if (await canLaunchUrl(tel)) {
                          await launchUrl(tel);
                        }
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Container(
                        padding: EdgeInsets.all(9.r),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedCall,
                          color: AppColors.primary,
                          size: 18.sp,
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Badges
              SizedBox(height: 10.h),
              Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: [
                  if (provider.averageRatings != null)
                    _buildBadge(
                      context,
                      icon: HugeIcons.strokeRoundedStar,
                      iconColor: Colors.amber,
                      label: '${provider.averageRatings!.toStringAsFixed(1)} ★',
                    ),
                  if (provider.credibilityScore != null)
                    _buildBadge(
                      context,
                      icon: HugeIcons.strokeRoundedShield01,
                      iconColor: AppColors.primary,
                      label: '${provider.credibilityScore}% Score',
                    ),
                  if (provider.totalTasksCompleted != null)
                    _buildBadge(
                      context,
                      icon: HugeIcons.strokeRoundedTask01,
                      iconColor: Colors.blue,
                      label: '${provider.totalTasksCompleted} Tasks',
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorContent(
    BuildContext context,
    WidgetRef ref,
    String rawError,
  ) {
    final cleanError = rawError.replaceAll('Exception: ', '').trim();
    final isNetworkError =
        cleanError.contains('Network connection error') ||
        cleanError.contains('DioException') ||
        cleanError.contains('SocketException') ||
        cleanError.contains('connection error') ||
        cleanError.contains('Connection reset') ||
        cleanError.contains('tasker-api-40zn.onrender.com');

    if (isNetworkError) {
      return _buildNetworkErrorContent(context, ref);
    }
    return _buildSecurityWarningContent(context, cleanError);
  }

  Widget _buildSecurityWarningContent(BuildContext context, String error) {
    final colorScheme = Theme.of(context).colorScheme;

    final isTechnicalMessage =
        error.contains('DioException') ||
        error.contains('SocketException') ||
        error.contains('Connection reset');

    final displayMessage = isTechnicalMessage || error.isEmpty
        ? 'The PIN provided is incorrect. For your safety, do NOT grant access.'
        : error;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Security Warning Header
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: colorScheme.error.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedAlert02,
                color: colorScheme.error,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'SECURITY WARNING',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: colorScheme.error,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: colorScheme.error.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DO NOT ALLOW THIS PROVIDER IN!',
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.error,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                displayMessage,
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: colorScheme.onSurface.withValues(alpha: 0.8),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),

        PrimaryButton(
          text: 'Try Again',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildNetworkErrorContent(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Network Error Header
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedAlert01,
                color: Colors.orange.shade800,
                size: 24.sp,
              ),
            ),
            SizedBox(width: 10.w),
            Text(
              'Connection Error',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Text(
          'Unable to verify PIN due to a network issue. Please check your internet connection.',
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            color: colorScheme.onSurface.withValues(alpha: 0.75),
            height: 1.3,
          ),
        ),
        SizedBox(height: 16.h),

        PrimaryButton(
          text: 'Retry Connection',
          onPressed: () {
            ref.invalidate(
              verifyProviderPinProvider((taskId: taskId, pin: pin)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBadge(
    BuildContext context, {
    required dynamic icon,
    required Color iconColor,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(icon: icon, color: iconColor, size: 13.sp),
          SizedBox(width: 4.w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
