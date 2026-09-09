import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:seeker_app/core/constants.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/widgets/custom_text_field.dart';
import 'package:seeker_app/core/designs/widgets/primary_button.dart';
import 'package:seeker_app/core/providers/review_providers.dart';
import 'package:seeker_app/core/providers/task_providers.dart';
import 'package:seeker_app/core/providers/user_provider.dart';
import 'package:seeker_app/core/utils/flushbar_message.dart';

class SubmitReviewSheet extends ConsumerStatefulWidget {
  final String taskId;
  final VoidCallback? onSuccess;

  const SubmitReviewSheet({
    super.key,
    required this.taskId,
    this.onSuccess,
  });

  /// Displays a non-dismissible compact bottom sheet asking the customer to rate & review their tasker.
  /// Uses [rootNavigatorKey] context internally (no [BuildContext] needed from outside).
  static Future<bool?> show({
    required String taskId,
    VoidCallback? onSuccess,
  }) async {
    final context = rootNavigatorKey.currentContext;
    if (context == null) return null;

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SubmitReviewSheet(
          taskId: taskId,
          onSuccess: onSuccess,
        ),
      ),
    );
  }

  @override
  ConsumerState<SubmitReviewSheet> createState() => _SubmitReviewSheetState();
}

class _SubmitReviewSheetState extends ConsumerState<SubmitReviewSheet> {
  int _rating = 0;
  bool _isCommentExpanded = false;
  bool _isSubmitting = false;
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit(String? providerName) async {
    if (_rating == 0) {
      context.showMessage(
        'Please tap a star to give a rating from 1 to 5.',
        type: MessageType.error,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final comment = _commentController.text.trim();
    await ref.read(submitReviewProvider.notifier).submitReview(
          taskId: widget.taskId,
          rating: _rating,
          comment: comment.isNotEmpty ? comment : null,
          onSuccess: () {
            if (mounted) {
              setState(() => _isSubmitting = false);
              Navigator.of(context).pop(true);
              widget.onSuccess?.call();
       
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() => _isSubmitting = false);
              context.showMessage(
                error,
                type: MessageType.error,
              );
            }
          },
        );
  }

  Widget _buildShimmerLoading(bool isDark) {
    final baseColor = isDark ? Colors.grey[850]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 12.h),

          // Header card shimmer
          Container(
            width: double.infinity,
            height: 54.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          SizedBox(height: 16.h),

          // Rating title & subtitle shimmer
          Container(
            width: 180.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: 220.w,
            height: 12.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 16.h),

          // Stars shimmer row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: 34.r,
                height: 34.r,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Comment toggle bar shimmer
          Container(
            width: double.infinity,
            height: 42.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
          SizedBox(height: 18.h),

          // Submit button shimmer
          Container(
            width: double.infinity,
            height: 44.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));
    final taskVal = taskAsync.value;
    final assignedProviderId =
        taskVal?.assignedProviderId ?? taskVal?.assignment?.providerId;

    final publicProfileAsync =
        (assignedProviderId != null && assignedProviderId.isNotEmpty)
            ? ref.watch(publicProviderProfileProvider(assignedProviderId))
            : null;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.surface;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final cardColor =
        isDark ? AppColors.darkerBackground : AppColors.background;

    return PopScope(
      canPop: false,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: taskAsync.when(
            data: (task) {
              String providerName =
                  task.assignment?.provider?.fullname ?? 'Tasker';
              String? providerPhoto =
                  task.assignment?.provider?.profilePictureUrl ??
                      task.assignment?.provider?.selfieUrl;

              if (publicProfileAsync != null &&
                  publicProfileAsync.hasValue &&
                  publicProfileAsync.value != null) {
                final publicProfile = publicProfileAsync.value!;
                if (publicProfile.fullname.isNotEmpty &&
                    publicProfile.fullname != 'Tasker') {
                  providerName = publicProfile.fullname;
                }
                if (publicProfile.profile?.selfieUrl != null &&
                    publicProfile.profile!.selfieUrl!.isNotEmpty) {
                  providerPhoto = publicProfile.profile!.selfieUrl;
                }
              }

              final taskTitle = task.title ?? 'Completed Task';

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Bar with Centered Handle Bar & Prominent Right 'X' Button
                    SizedBox(
                      height: 36.h,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Handle Bar
                          Center(
                            child: Container(
                              width: 36.w,
                              height: 4.h,
                              decoration: BoxDecoration(
                                color: isDark ? Colors.white30 : Colors.black26,
                                borderRadius: BorderRadius.circular(2.r),
                              ),
                            ),
                          ),
                          // Prominent Close 'X' Button
                          Positioned(
                            right: 0,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () async {
                                  await ref
                                      .read(
                                        taskReviewPromptHistoryProvider
                                            .notifier,
                                      )
                                      .updatePromptShown(widget.taskId);
                                  if (context.mounted) {
                                    Navigator.of(context).pop(false);
                                  }
                                },
                                borderRadius: BorderRadius.circular(20.r),
                                child: Container(
                                  width: 32.r,
                                  height: 32.r,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark
                                        ? Colors.white.withValues(alpha: 0.15)
                                        : Colors.black.withValues(alpha: 0.08),
                                    border: Border.all(
                                      color: isDark
                                          ? Colors.white.withValues(alpha: 0.2)
                                          : Colors.black.withValues(alpha: 0.1),
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 18.sp,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Compact Provider Banner Card
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: isDark
                              ? Colors.white12
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Row(
                        children: [
                          // Provider Avatar
                          Container(
                            width: 42.r,
                            height: 42.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.12),
                            ),
                            child: ClipOval(
                              child: providerPhoto != null &&
                                      providerPhoto.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: providerPhoto,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) =>
                                          const Center(
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Center(
                                        child: Text(
                                          providerName.isNotEmpty
                                              ? providerName[0].toUpperCase()
                                              : 'T',
                                          style: GoogleFonts.inter(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Center(
                                      child: Text(
                                        providerName.isNotEmpty
                                            ? providerName[0].toUpperCase()
                                            : 'T',
                                        style: GoogleFonts.inter(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  providerName,
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  taskTitle,
                                  style: GoogleFonts.inter(
                                    fontSize: 11.5.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Text(
                              'Completed',
                              style: GoogleFonts.inter(
                                fontSize: 10.5.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF059669),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Compact Rating Header & Question
                    Text(
                      'How was your experience?',
                      style: GoogleFonts.inter(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Please take a moment to rate $providerName',
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 14.h),

                    // Interactive 5 Star Rating Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starValue = index + 1;
                        final isSelected = starValue <= _rating;

                        return GestureDetector(
                          onTap: () {
                            setState(() => _rating = starValue);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutCubic,
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: Icon(
                              isSelected
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              size: 36.sp,
                              color: isSelected
                                  ? const Color(0xFFFFB800)
                                  : (isDark ? Colors.white24 : Colors.black12),
                            ),
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 14.h),

                    // Collapsible Comment Bar
                    GestureDetector(
                      onTap: () {
                        setState(() => _isCommentExpanded = !_isCommentExpanded);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isDark
                                ? Colors.white12
                                : Colors.black.withValues(alpha: 0.05),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 16.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'Type review... (optional)',
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                            AnimatedRotation(
                              turns: _isCommentExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 20.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Expandable Comment Input Box
                    AnimatedCrossFade(
                      firstChild: const SizedBox.shrink(),
                      secondChild: Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: CustomTextField(
                          controller: _commentController,
                          hintText: 'Share more details about your experience...',
                          maxLines: 3,
                        ),
                      ),
                      crossFadeState: _isCommentExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 220),
                    ),

                    SizedBox(height: 18.h),

                    // Primary Submit Button
                    PrimaryButton(
                      text: 'Submit review',
                      height: 44.h,
                      isLoading: _isSubmitting,
                      onPressed: () => _submit(providerName),
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              );
            },
            loading: () => _buildShimmerLoading(isDark),
            error: (error, stack) => Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline_rounded,
                      color: Colors.red, size: 36.sp),
                  SizedBox(height: 8.h),
                  Text(
                    'Failed to load task details',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: isDark ? Colors.white70 : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
