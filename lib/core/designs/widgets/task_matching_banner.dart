import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';

import '../app_colors.dart';
import '../app_text_styles.dart';
import '../../models/tasks/task_matching_state.dart';
import '../../providers/task_matching_provider.dart';
import '../../routes/route_names.dart';

class TaskMatchingBanner extends ConsumerStatefulWidget {
  const TaskMatchingBanner({super.key});

  @override
  ConsumerState<TaskMatchingBanner> createState() => _TaskMatchingBannerState();
}

class _TaskMatchingBannerState extends ConsumerState<TaskMatchingBanner> {
  bool _isExpanded = true;

  void _closeBanner() {
    ref.read(showTaskMatchingBannerProvider.notifier).state = false;
    ref.read(taskMatchingProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    final showBanner = ref.watch(showTaskMatchingBannerProvider);
    if (!showBanner) return const SizedBox.shrink();

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
        SpinKitRipple(color: AppColors.primary, size: 20.r, borderWidth: 2.0),
      ),
      MatchingStatus.success => (
        'Tasker Found!',
        'Tap to view assigned provider details',
        Colors.green.shade500,
        Icon(
          Icons.check_circle_rounded,
          color: Colors.green.shade500,
          size: 18.sp,
        ),
      ),
      MatchingStatus.cancelled => (
        'Matching Cancelled',
        'Tap to view task status',
        Colors.red.shade500,
        Icon(Icons.cancel_rounded, color: Colors.red.shade500, size: 18.sp),
      ),
    };

    final shortTitle = switch (status) {
      MatchingStatus.pending => 'Finding Tasker...',
      MatchingStatus.success => 'Tasker Found!',
      MatchingStatus.cancelled => 'Cancelled',
    };

    return Material(
      color: Colors.transparent,
      child: Align(
        alignment: Alignment.centerRight,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF222222) : Colors.white,
            borderRadius: BorderRadius.circular(_isExpanded ? 16.r : 20.r),
            border: Border.all(
              color: accentColor.withValues(alpha: isDark ? 0.25 : 0.18),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            firstCurve: Curves.easeInOutCubic,
            secondCurve: Curves.easeInOutCubic,
            sizeCurve: Curves.easeInOutCubic,
            crossFadeState: _isExpanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: _buildExpandedView(
              context: context,
              matchingState: matchingState,
              title: title,
              subtitle: subtitle,
              accentColor: accentColor,
              iconWidget: iconWidget,
              isDark: isDark,
            ),
            secondChild: _buildCollapsedView(
              context: context,
              matchingState: matchingState,
              shortTitle: shortTitle,
              accentColor: accentColor,
              iconWidget: iconWidget,
              isDark: isDark,
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildExpandedView({
    required BuildContext context,
    required TaskMatchingState matchingState,
    required String title,
    required String subtitle,
    required Color accentColor,
    required Widget iconWidget,
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Row(
        children: [
          // Tapping body navigates to matching detail screen
          Expanded(
            child: InkWell(
              onTap: () {
                context.pushNamed(
                  RouteNames.taskMatching.name,
                  pathParameters: {'taskId': matchingState.taskId!},
                );
              },
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2.h),
                child: Row(
                  children: [
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: iconWidget),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
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
                                  ? Colors.white.withValues(alpha: 0.5)
                                  : AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          // Action controls: Collapse arrow & Close button
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = false;
                  });
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                    size: 20.sp,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              InkWell(
                onTap: _closeBanner,
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                    size: 18.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsedView({
    required BuildContext context,
    required TaskMatchingState matchingState,
    required String shortTitle,
    required Color accentColor,
    required Widget iconWidget,
    required bool isDark,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              context.pushNamed(
                RouteNames.taskMatching.name,
                pathParameters: {'taskId': matchingState.taskId!},
              );
            },
            borderRadius: BorderRadius.circular(16.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 24.r,
                    height: 24.r,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Center(child: iconWidget),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    shortTitle,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    _isExpanded = true;
                  });
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                    size: 18.sp,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              InkWell(
                onTap: _closeBanner,
                borderRadius: BorderRadius.circular(12.r),
                child: Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Icon(
                    Icons.close_rounded,
                    color: isDark ? Colors.white54 : AppColors.textSecondary,
                    size: 16.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



