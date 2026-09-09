import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:seeker_app/core/constants.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/widgets/primary_button.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/task_providers.dart';
import 'package:seeker_app/core/providers/user_provider.dart';
import 'package:seeker_app/core/utils/flushbar_message.dart';
import 'package:seeker_app/core/utils/loading_overlay.dart';
import 'package:seeker_app/core/utils/num_extension.dart';

class ReviewPriceAdjustmentSheet extends ConsumerStatefulWidget {
  final PriceAdjustment adjustment;
  final VoidCallback? onSuccess;
  final void Function(String error)? onError;

  const ReviewPriceAdjustmentSheet({
    super.key,
    required this.adjustment,
    this.onSuccess,
    this.onError,
  });

  /// Displays a bottom sheet asking the customer to accept or decline a price adjustment request.
  static Future<bool?> show(
    BuildContext? context, {
    required PriceAdjustment adjustment,
    VoidCallback? onSuccess,
    void Function(String error)? onError,
  }) async {
    final ctx = context ?? rootNavigatorKey.currentContext;
    if (ctx == null) return null;

    return showModalBottomSheet<bool>(
      context: ctx,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: ReviewPriceAdjustmentSheet(
          adjustment: adjustment,
          onSuccess: onSuccess,
          onError: onError,
        ),
      ),
    );
  }

  @override
  ConsumerState<ReviewPriceAdjustmentSheet> createState() =>
      _ReviewPriceAdjustmentSheetState();
}

class _ReviewPriceAdjustmentSheetState
    extends ConsumerState<ReviewPriceAdjustmentSheet> {
  bool _isProcessing = false;

  Future<void> _handleRespond(bool approved) async {
    final taskId = widget.adjustment.taskId;
    final adjustmentId = widget.adjustment.id;

    if (taskId == null ||
        taskId.isEmpty ||
        adjustmentId == null ||
        adjustmentId.isEmpty) {
      context.showMessage(
        'Invalid task or price adjustment identifier.',
        type: MessageType.error,
      );
      return;
    }

    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    context.showLoading();

    try {
      await ref.read(respondPriceAdjustmentProvider.notifier).respond(
            taskId: taskId,
            adjustmentId: adjustmentId,
            approved: approved,
            onSuccess: (result) {
              if (mounted) {
                context.hideLoading();
                Navigator.of(context).pop(approved);
                widget.onSuccess?.call();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final navContext = rootNavigatorKey.currentContext;
                  if (navContext != null && navContext.mounted) {
                    navContext.showMessage(
                      approved
                          ? 'Price adjustment accepted successfully.'
                          : 'Price adjustment declined.',
                      type: approved ? MessageType.success : MessageType.info,
                    );
                  }
                });
              }
            },
            onError: (error) {
              if (mounted) {
                context.hideLoading();
                context.showMessage(error, type: MessageType.error);
                widget.onError?.call(error);
              }
            },
          );
    } catch (e) {
      if (mounted) {
        context.hideLoading();
        context.showMessage(e.toString(), type: MessageType.error);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Widget _buildShimmer(bool isDark) {
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
          SizedBox(height: 14.h),
          Container(
            width: 180.w,
            height: 18.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            width: 220.w,
            height: 12.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            width: double.infinity,
            height: 52.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            width: double.infinity,
            height: 110.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            height: 46.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: 80.w,
            height: 16.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.surface;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final cardColor =
        isDark ? AppColors.darkerBackground : AppColors.background;

    final taskId = widget.adjustment.taskId ?? '';
    final taskAsync = taskId.isNotEmpty
        ? ref.watch(taskDetailProvider(taskId))
        : AsyncValue<Task>.data(Task());

    if (taskAsync.isLoading) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: SafeArea(
          top: false,
          child: _buildShimmer(isDark),
        ),
      );
    }
    final task = taskAsync.value;

    final assignedProviderId =
        task?.assignedProviderId ?? task?.assignment?.providerId;
    final publicProfileAsync =
        (assignedProviderId != null && assignedProviderId.isNotEmpty)
            ? ref.watch(publicProviderProfileProvider(assignedProviderId))
            : null;

    String providerName = task?.assignment?.provider?.fullname ?? 'Tasker';
    String? providerPhoto = task?.assignment?.provider?.profilePictureUrl ??
        task?.assignment?.provider?.selfieUrl;

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

    final taskTitle = task?.title ?? 'Active Task';
    final originalPrice = task?.customerTotalPrice ??
        task?.assignment?.acceptedPrice ??
        task?.basePrice;
    final adjustmentAmount = widget.adjustment.amount ?? 0;
    final newPrice = (originalPrice ?? 0) + adjustmentAmount;
    final description = widget.adjustment.description ?? 'No reason provided';

    return PopScope(
      canPop: false,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Bar with Handle & Close Button
                SizedBox(
                  height: 32.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
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
                      Positioned(
                        right: 0,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(null),
                            borderRadius: BorderRadius.circular(20.r),
                            child: Container(
                              width: 30.r,
                              height: 30.r,
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
                                  size: 16.sp,
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
                SizedBox(height: 8.h),

                // Title Section
                Text(
                  'Price Adjustment Request',
                  style: GoogleFonts.inter(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 2.h),
                Text(
                  'Review the requested price change for your task.',
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),

                // Provider & Task Banner Card
                Container(
                  padding: EdgeInsets.all(12.w),
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
                      Container(
                        width: 40.r,
                        height: 40.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withValues(alpha: 0.12),
                        ),
                        child: ClipOval(
                          child: providerPhoto != null && providerPhoto.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: providerPhoto,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  ),
                                  errorWidget: (context, url, error) => Center(
                                    child: Text(
                                      providerName.isNotEmpty
                                          ? providerName[0].toUpperCase()
                                          : 'T',
                                      style: GoogleFonts.inter(
                                        fontSize: 16.sp,
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
                                      fontSize: 16.sp,
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
                                fontSize: 13.5.sp,
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
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF59E0B)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Text(
                          widget.adjustment.status?.toUpperCase() ?? 'PENDING',
                          style: GoogleFonts.inter(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFFD97706),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                // Price Breakdown Card
                Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isDark
                          ? Colors.white12
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Original Amount
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Original Price',
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                originalPrice != null
                                    ? originalPrice.toNaira()
                                    : '—',
                                style: GoogleFonts.inter(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                  decoration: originalPrice != null
                                      ? TextDecoration.lineThrough
                                      : null,
                                  decorationColor: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),

                          // Arrow Indicator
                          Container(
                            padding: EdgeInsets.all(6.r),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary.withValues(alpha: 0.1),
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 16.sp,
                              color: AppColors.primary,
                            ),
                          ),

                          // New Requested Price
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'New Requested Price',
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                newPrice.toNaira(),
                                style: GoogleFonts.inter(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (originalPrice != null && adjustmentAmount != 0) ...[
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: (adjustmentAmount > 0
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF10B981))
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                adjustmentAmount > 0
                                    ? Icons.arrow_upward_rounded
                                    : Icons.arrow_downward_rounded,
                                size: 13.sp,
                                color: adjustmentAmount > 0
                                    ? const Color(0xFFEF4444)
                                    : const Color(0xFF10B981),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                adjustmentAmount > 0
                                    ? 'Increase: +${adjustmentAmount.toNaira()}'
                                    : 'Decrease: -${adjustmentAmount.abs().toNaira()}',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w700,
                                  color: adjustmentAmount > 0
                                      ? const Color(0xFFEF4444)
                                      : const Color(0xFF10B981),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (description.isNotEmpty) ...[
                        SizedBox(height: 12.h),
                        Divider(
                          height: 1,
                          color: isDark ? Colors.white12 : Colors.black12,
                        ),
                        SizedBox(height: 12.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reason for Request',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                description,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5.sp,
                                  color: textColor,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(height: 20.h),

                // Action Buttons: Accept (Emphasized) & Decline (Subtle)
                PrimaryButton(
                  text: 'Accept Adjustment',
                  height: 44.h,
                  isLoading: _isProcessing,
                  onPressed: () => _handleRespond(true),
                ),
                SizedBox(height: 8.h),
                TextButton(
                  onPressed: _isProcessing ? null : () => _handleRespond(false),
                  style: TextButton.styleFrom(
                    minimumSize: Size(double.infinity, 42.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Decline',
                    style: GoogleFonts.inter(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                SizedBox(height: 4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
