import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/models/models.dart';
import 'notification_icon.dart';

class NotificationListItem extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;

  const NotificationListItem({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isUnread = notification.readAt == null;

    final createdAt = notification.createdAt ?? DateTime.now();
    final timeDiff = DateTime.now().difference(createdAt);
    String timeAgo;
    if (timeDiff.inMinutes < 1) {
      timeAgo = 'Just now';
    } else if (timeDiff.inMinutes < 60) {
      final mins = timeDiff.inMinutes;
      timeAgo = '$mins ${mins == 1 ? 'min' : 'mins'} ago';
    } else if (timeDiff.inHours < 24) {
      final hours = timeDiff.inHours;
      timeAgo = '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else {
      final days = timeDiff.inDays;
      timeAgo = '$days ${days == 1 ? 'day' : 'days'} ago';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
          decoration: BoxDecoration(
            color: isUnread
                ? AppColors.primary.withValues(alpha: isDark ? 0.10 : 0.05)
                : (isDark
                    ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25)
                    : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isUnread
                  ? AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.12)
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.04)),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NotificationIcon(type: notification.type ?? 'unknown'),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  notification.title ?? 'No title',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontSize: 13.sp,
                                    fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                                    color: isDark ? Colors.white : AppColors.textPrimary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isUnread) ...[
                                SizedBox(width: 6.w),
                                Container(
                                  width: 6.r,
                                  height: 6.r,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          timeAgo,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10.5.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      notification.body ?? '',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.5.sp,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
