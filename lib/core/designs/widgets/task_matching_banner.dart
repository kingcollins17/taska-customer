import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';
import '../../models/tasks/task_matching_state.dart';
import '../../providers/task_matching_provider.dart';
import '../../routes/route_names.dart';

class TaskMatchingBanner extends ConsumerWidget {
  const TaskMatchingBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchingAsync = ref.watch(taskMatchingProvider);
    final matchingState = matchingAsync.value;

    if (matchingState == null ||
        matchingState.taskId == null ||
        matchingState.taskId!.isEmpty) {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = matchingState.status;

    final (
      String title,
      String subtitle,
      Color accentColor,
      Widget iconWidget,
    ) = switch (status) {
      MatchingStatus.pending => (
        'Finding your Tasker...',
        'Tap to view live matching status',
        AppColors.primary,
        SpinKitRipple(color: AppColors.primary, size: 24.r, borderWidth: 3.0),
      ),
      MatchingStatus.success => (
        'Tasker Found!',
        'Tap to view assigned provider details',
        Colors.green.shade600,
        Icon(
          Icons.check_circle_rounded,
          color: Colors.green.shade600,
          size: 24.sp,
        ),
      ),
      MatchingStatus.cancelled => (
        'Matching Cancelled',
        'Tap to view task status',
        Colors.red.shade600,
        Icon(Icons.cancel_rounded, color: Colors.red.shade600, size: 24.sp),
      ),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.pushNamed(
            RouteNames.taskMatching.name,
            pathParameters: {'taskId': matchingState.taskId!},
          );
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: accentColor.withValues(alpha: isDark ? 0.4 : 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.12),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (status == MatchingStatus.cancelled ||
                      status == MatchingStatus.success) {
                    ref.read(taskMatchingProvider.notifier).clear();
                  }
                },
                child: Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: iconWidget),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.sp,
                        color: isDark
                            ? Colors.white60
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                color: accentColor,
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }
}
