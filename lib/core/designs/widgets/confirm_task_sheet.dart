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
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 14.h,
          bottom: MediaQuery.of(context).padding.bottom + 16.h,
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

                  // Task Summary Card with Category Name
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(
                        alpha: isDark ? 0.12 : 0.06,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w,
                                vertical: 3.h,
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
                            Text(
                              priceStr,
                              style: AppTextStyles.heading3.copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
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
                    title: 'Flexible Payment',
                    subtitle: 'Pay via online (recommended) or cash offline.',
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
                          .read(taskDraftActionProvider.notifier)
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
            error: (error, _) => Center(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Text(
                  'Failed to load task details',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
                ),
              ),
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
