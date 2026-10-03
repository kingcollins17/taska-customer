import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shimmer/shimmer.dart';

import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/providers/services_provider.dart';
import 'package:seeker_app/core/providers/task_providers.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import 'package:seeker_app/core/utils/flushbar_message.dart';
import 'package:seeker_app/core/utils/loading_overlay.dart';
import 'package:seeker_app/core/utils/num_extension.dart';

class ConfirmTaskSheet extends ConsumerWidget {
  final String taskId;

  const ConfirmTaskSheet({super.key, required this.taskId});

  static Future<void> show(BuildContext context, String taskId) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ConfirmTaskSheet(taskId: taskId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailProvider(taskId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final colorScheme = Theme.of(context).colorScheme;

    Widget buildShimmer() {
      final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
      final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(height: 8.h),
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: 140.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: double.infinity,
              height: 64.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: double.infinity,
              height: 44.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      );
    }

    return PopScope(
      canPop: false,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
        child: SafeArea(
          top: false,
          child: taskAsync.when(
            data: (task) {
              final categoryAsync = task.categoryId != null
                  ? ref.watch(categoryByIdProvider(task.categoryId!))
                  : const AsyncValue.data(null);
              final categoryName =
                  categoryAsync.asData?.value?.name ?? 'Service';

              final priceStr = task.customerTotalPrice != null
                  ? task.customerTotalPrice!.toNaira(2)
                  : (task.basePrice != null
                        ? task.basePrice!.toNaira(2)
                        : 'TBD');

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Confirm Task Order',
                        style: AppTextStyles.heading3.copyWith(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: AppColors.textSecondary,
                          size: 20.sp,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // Task Summary Card with Category Name & Estimated Price
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: isDark ? 0.12 : 0.06,
                      ),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: AppColors.primary.withValues(
                          alpha: isDark ? 0.25 : 0.15,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 4.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(
                                  alpha: 0.15,
                                ),
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                categoryName,
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 10.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  priceStr,
                                  style: AppTextStyles.heading3.copyWith(
                                    fontSize: 17.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                                Text(
                                  'Est. Starting Price',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? Colors.white60
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          task.title ?? 'Untitled Task',
                          style: AppTextStyles.heading3.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 10.h),

                  // Price Renegotiation Disclaimer Card
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.3)
                          : colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color:
                            colorScheme.outlineVariant.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(5.r),
                          decoration: BoxDecoration(
                            color: Colors.blue
                                .withValues(alpha: isDark ? 0.2 : 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedInformationCircle,
                            color:
                                isDark ? Colors.blue[300]! : Colors.blue[700]!,
                            size: 15.sp,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Price Subject to Negotiation',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? Colors.blue[200]
                                          : Colors.blue[900],
                                    ),
                                  ),
                                  SizedBox(width: 5.w),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 5.w,
                                      vertical: 1.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue
                                          .withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4.r),
                                    ),
                                    child: Text(
                                      'Not Final',
                                      style: TextStyle(
                                        fontSize: 8.5.sp,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.blue[300]
                                            : Colors.blue[800],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'This initial price is an estimate. You and your assigned provider can discuss and renegotiate the final quote after evaluating full task details.',
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 10.sp,
                                  color: isDark
                                      ? Colors.white70
                                      : AppColors.textSecondary,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // What Happens Next Flow
                  Text(
                    'What Happens Next',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  _StepRow(
                    stepNumber: '1',
                    title: 'Get Matched',
                    subtitle: 'Matched with a verified professional Tasker.',
                    isDark: isDark,
                  ),
                  SizedBox(height: 6.h),
                  _StepRow(
                    stepNumber: '2',
                    title: 'Service Delivery',
                    subtitle:
                        'Tasker arrives at your location and completes the job.',
                    isDark: isDark,
                  ),
                  SizedBox(height: 6.h),
                  _StepRow(
                    stepNumber: '3',
                    title: 'Agree Price & Pay',
                    subtitle:
                        'Confirm final price with Tasker and pay online or cash.',
                    isDark: isDark,
                  ),

                  SizedBox(height: 10.h),

                  // Safety Identity Verification Alert Box
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(
                        alpha: isDark ? 0.15 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: Colors.amber.withValues(
                          alpha: isDark ? 0.3 : 0.25,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedShield01,
                          color: isDark
                              ? Colors.amber[300]!
                              : Colors.amber[800]!,
                          size: 16.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Safety Tip: Always verify the provider\'s identity before allowing them in.',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? Colors.amber[300]
                                  : Colors.amber[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 14.h),

                  // Primary Action Button
                  ElevatedButton(
                    onPressed: () {
                      context.showLoading();
                      ref
                          .read(taskManagementProvider.notifier)
                          .confirmDraft(
                            taskId: taskId,
                            onSuccess: () {
                              ref.invalidate(taskDetailProvider(taskId));
                              context.hideLoading();
                              context.pop();
                              context.pushNamed(
                                RouteNames.taskMatching.name,
                                pathParameters: {'taskId': taskId},
                              );
                            },
                            onError: (error) {
                              context.hideLoading();
                              context.showMessage(
                                error,
                                type: MessageType.error,
                              );
                            },
                          );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: Size(double.infinity, 44.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Confirm & Match Tasker',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: Colors.white,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => buildShimmer(),
            error: (error, _) => Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Confirm Task Order',
                      style: AppTextStyles.heading3.copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: 20.sp,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: isDark ? 0.12 : 0.06),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: isDark ? 0.25 : 0.15),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 44.r,
                        height: 44.r,
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.error_outline_rounded,
                            color: Colors.red,
                            size: 24.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Failed to load task details',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        error.toString().contains('Exception:')
                            ? error.toString().replaceAll('Exception:', '').trim()
                            : 'Something went wrong while fetching task details.',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12.sp,
                          color: isDark ? Colors.white70 : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => ref.invalidate(taskDetailProvider(taskId)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                          icon: Icon(Icons.refresh_rounded, size: 18.sp),
                          label: Text(
                            'Retry',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String stepNumber;
  final String title;
  final String subtitle;
  final bool isDark;

  const _StepRow({
    required this.stepNumber,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20.r,
          height: 20.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Text(
            stepNumber,
            style: TextStyle(
              fontSize: 10.5.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 1.h),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
