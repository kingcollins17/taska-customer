import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/designs/widgets/primary_button.dart';
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
      backgroundColor: Colors.transparent,
      builder: (context) => ConfirmTaskSheet(taskId: taskId),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskDetailProvider(taskId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buildHandle() {
      return Center(
        child: Container(
          width: 48.w,
          height: 5.h,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.2)
                : Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(2.5.r),
          ),
        ),
      );
    }

    Widget buildShimmer() {
      final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
      final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          buildHandle(),
          SizedBox(height: 20.h),
          Row(
            children: [
              Shimmer.fromColors(
                baseColor: baseColor,
                highlightColor: highlightColor,
                child: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      child: Container(
                        width: double.infinity,
                        height: 16.h,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Shimmer.fromColors(
                      baseColor: baseColor,
                      highlightColor: highlightColor,
                      child: Container(
                        width: 100.w,
                        height: 12.h,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: double.infinity,
              height: 72.h,
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
              height: 16.h,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 20.h),
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: double.infinity,
              height: 32.h,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 24.h),
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              width: double.infinity,
              height: 56.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32.r),
              ),
            ),
          ),
        ],
      );
    }

    Widget buildTimelineItem({
      required String text,
      required bool isIncluded,
      required bool isLast,
    }) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Container(
                  width: 16.w,
                  height: 16.w,
                  margin: EdgeInsets.only(top: 2.h),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isIncluded ? AppColors.primary : Colors.transparent,
                    border: isIncluded
                        ? null
                        : Border.all(
                            color: isDark
                                ? Colors.grey[600]!
                                : Colors.grey[400]!,
                            width: 1.5.w,
                          ),
                    boxShadow: isIncluded
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 6,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isIncluded
                      ? Icon(Icons.check, size: 10.sp, color: Colors.white)
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5.w,
                      margin: EdgeInsets.symmetric(vertical: 4.h),
                      color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                    ),
                  ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 20.h),
                child: Text(
                  text,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isIncluded
                        ? (isDark ? Colors.white : Colors.black87)
                        : (isDark ? Colors.grey[600] : Colors.grey[400]),
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(
        left: 24.w,
        right: 24.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32.h,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: taskAsync.when(
        data: (task) {
          final categoryAsync = task.categoryId != null
              ? ref.watch(categoryByIdProvider(task.categoryId!))
              : const AsyncValue.data(null);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildHandle(),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Confirm Task',
                    style: AppTextStyles.heading3.copyWith(
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 20.sp,
                    ),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                task.title ?? 'Untitled Task',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16.sp,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'These details encompass the task you requested. You will be matched with a verified Tasker for this service.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 24.h),
              Builder(
                builder: (context) {
                  final items = [
                    if (categoryAsync.asData?.value != null)
                      {
                        'text': '${categoryAsync.asData!.value!.name}',
                        'isIncluded': true,
                      },
                    {
                      'text': 'Matched with a verified Tasker',
                      'isIncluded': true,
                    },
                    {'text': 'Price open to renegotiation', 'isIncluded': true},
                    {'text': 'Secure online/cash payment', 'isIncluded': true},
                    {'text': 'Hidden task fees', 'isIncluded': false},
                  ];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(items.length, (index) {
                      final item = items[index];
                      return buildTimelineItem(
                        text: item['text'] as String,
                        isIncluded: item['isIncluded'] as bool,
                        isLast: index == items.length - 1,
                      );
                    }),
                  );
                },
              ),
              SizedBox(height: 32.h),
              GestureDetector(
                onTap: () {
                  context.showLoading();
                  ref
                      .read(taskDraftActionProvider.notifier)
                      .confirmDraft(
                        taskId: taskId,
                        onSuccess: () {
                          context.hideLoading();
                          context.pop();
                          context.pushNamed(
                            RouteNames.taskMatching.name,
                            pathParameters: {'taskId': taskId},
                          );
                        },
                        onError: (error) {
                          context.hideLoading();
                          context.showMessage(error, type: MessageType.error);
                        },
                      );
                },
                child: Container(
                  height: 52.h,
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Continue',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        (task.customerTotalPrice ?? 0).toNaira(2),
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => buildShimmer(),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              'Failed to load task details',
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }
}
