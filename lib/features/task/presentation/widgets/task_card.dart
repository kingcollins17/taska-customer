import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/utils/num_extension.dart';

class TaskCard extends StatelessWidget {
  final TaskLite task;
  final VoidCallback? onTap;

  const TaskCard({super.key, required this.task, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Improved contrast using theme and AppColors
    final cardColor = isDark ? AppColors.darkerBackground : theme.colorScheme.surface;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? Colors.white70 : AppColors.textSecondary;
    final priceColor = isDark ? Colors.white : AppColors.primary;

    final dateStr = task.scheduledStartAt != null
        ? DateFormat('MMM d, y h:mm a').format(task.scheduledStartAt!)
        : 'Flexible time';

    final priceStr = task.customerTotalPrice != null
        ? task.customerTotalPrice!.toNaira(2)
        : 'TBD';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isDark ? Colors.white12 : Colors.grey.shade200,
            width: 1,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCategoryAvatar(task.category?.imageUrl),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              task.title ?? 'No title provided',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              '${task.category?.name ?? 'General'} • $dateStr',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontSize: 13.sp,
                                color: textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _buildStatusBadge(context, task.status ?? 'open'),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        priceStr,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: priceColor,
                        ),
                      ),
                      if (task.distanceKm != null)
                        Row(
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedLocation01,
                              color: textSecondary,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '${task.distanceKm!.toStringAsFixed(1)} km away',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 13.sp,
                                color: textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryAvatar(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 20.r,
        backgroundImage: NetworkImage(imageUrl),
        backgroundColor: Colors.transparent,
      );
    }
    return CircleAvatar(
      radius: 20.r,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: HugeIcon(
        icon: HugeIcons.strokeRoundedTask01,
        color: AppColors.primary,
        size: 20.sp,
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color bgColor;
    Color textColor;
    String displayStatus;

    switch (status.toLowerCase()) {
      case 'draft':
        bgColor = Colors.grey.withValues(alpha: 0.2);
        textColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;
        displayStatus = 'Draft';
        break;
      case 'open':
        bgColor = Colors.blue.withValues(alpha: 0.2);
        textColor = isDark ? Colors.blue.shade300 : Colors.blue.shade700;
        displayStatus = 'Open';
        break;
      case 'matched':
        bgColor = Colors.orange.withValues(alpha: 0.2);
        textColor = isDark ? Colors.orange.shade300 : Colors.orange.shade800;
        displayStatus = 'Matched';
        break;
      case 'in progress':
      case 'inprogress':
        bgColor = Colors.purple.withValues(alpha: 0.2);
        textColor = isDark ? Colors.purple.shade300 : Colors.purple.shade700;
        displayStatus = 'In Progress';
        break;
      case 'completed':
        bgColor = Colors.green.withValues(alpha: 0.2);
        textColor = isDark ? Colors.green.shade300 : Colors.green.shade700;
        displayStatus = 'Completed';
        break;
      case 'cancelled':
        bgColor = Colors.red.withValues(alpha: 0.2);
        textColor = isDark ? Colors.red.shade300 : Colors.red.shade700;
        displayStatus = 'Cancelled';
        break;
      default:
        bgColor = Colors.grey.withValues(alpha: 0.2);
        textColor = isDark ? Colors.grey.shade400 : Colors.grey.shade700;
        displayStatus = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        displayStatus,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
