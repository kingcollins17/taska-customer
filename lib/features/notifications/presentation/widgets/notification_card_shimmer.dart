import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class NotificationCardShimmer extends StatelessWidget {
  final double titleWidth;
  final double bodyWidth;

  const NotificationCardShimmer({
    super.key,
    this.titleWidth = 130,
    this.bodyWidth = 160,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final baseColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.grey.shade300.withValues(alpha: 0.6);
    final highlightColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.grey.shade100;

    final blockColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.grey.shade300;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.04)
              : Colors.black.withValues(alpha: 0.03),
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Notification Icon Circle Skeleton
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: blockColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 12.w),
            // Text Skeletons
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Title Skeleton
                      Container(
                        width: titleWidth.w,
                        height: 12.h,
                        decoration: BoxDecoration(
                          color: blockColor,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      // Time Ago Skeleton
                      Container(
                        width: 42.w,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: blockColor,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  // Body Line 1 Skeleton
                  Container(
                    height: 10.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: blockColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  // Body Line 2 Skeleton
                  Container(
                    width: bodyWidth.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: blockColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NotificationsListShimmer extends StatelessWidget {
  const NotificationsListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final baseColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.grey.shade300.withValues(alpha: 0.6);
    final highlightColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.grey.shade100;

    final blockColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.grey.shade300;

    final itemConfigs = [
      (titleWidth: 140.0, bodyWidth: 180.0, hasGroupHeader: true, headerWidth: 55.0),
      (titleWidth: 105.0, bodyWidth: 130.0, hasGroupHeader: false, headerWidth: 0.0),
      (titleWidth: 155.0, bodyWidth: 195.0, hasGroupHeader: false, headerWidth: 0.0),
      (titleWidth: 120.0, bodyWidth: 150.0, hasGroupHeader: true, headerWidth: 75.0),
      (titleWidth: 145.0, bodyWidth: 170.0, hasGroupHeader: false, headerWidth: 0.0),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Filter Chips Skeleton Row
        Padding(
          padding: EdgeInsets.only(bottom: 6.h),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Row(
              children: [
                Container(
                  width: 50.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    color: blockColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 65.w,
                  height: 28.h,
                  decoration: BoxDecoration(
                    color: blockColor,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 90.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: blockColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Grouped Items Skeletons
        ...itemConfigs.map((config) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (config.hasGroupHeader)
                Padding(
                  padding: EdgeInsets.only(top: 10.h, bottom: 8.h, left: 4.w),
                  child: Shimmer.fromColors(
                    baseColor: baseColor,
                    highlightColor: highlightColor,
                    child: Container(
                      width: config.headerWidth.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: blockColor,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: NotificationCardShimmer(
                  titleWidth: config.titleWidth,
                  bodyWidth: config.bodyWidth,
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}
