import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import 'notification_icon.dart';

class NotificationDetailSheet extends StatelessWidget {
  final NotificationItem notification;

  const NotificationDetailSheet({super.key, required this.notification});

  static Future<void> show(
    BuildContext context, {
    required NotificationItem notification,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationDetailSheet(notification: notification),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final createdAt = notification.createdAt;
    final formattedDate = createdAt != null
        ? DateFormat('EEEE, MMM d, y • h:mm a').format(createdAt)
        : null;

    final taskId = notification.data?['task_id'] ??
        notification.data?['taskId'];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 10.h,
        bottom: 16.h + MediaQuery.of(context).viewPadding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
            // Drag Handle Bar
            Center(
              child: Container(
                width: 32.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 10.h),

            // Top Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Notification Detail',
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
            SizedBox(height: 12.h),

            // Title & Icon Header Card
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  NotificationIcon(type: notification.type ?? 'unknown'),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title ?? 'Notification',
                          style: AppTextStyles.heading3.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                        if (formattedDate != null) ...[
                          SizedBox(height: 3.h),
                          Text(
                            formattedDate,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 10.5.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // Notification Message Body Card
            Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06),
                ),
              ),
              child: Text(
                notification.body ?? 'No message body available.',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12.5.sp,
                  height: 1.5,
                  color: isDark ? Colors.white70 : AppColors.textPrimary,
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Action Button
            if (taskId != null && taskId is String && taskId.isNotEmpty)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pushNamed(
                    RouteNames.taskDetail.name,
                    pathParameters: {'taskId': taskId},
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
                      'View Task Details',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Icon(Icons.arrow_forward_rounded, size: 16.sp, color: Colors.white),
                  ],
                ),
              )
            else
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 44.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  side: BorderSide(
                    color: isDark
                        ? Colors.white24
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  'Close',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
          ],
        ),
    );
  }
}
