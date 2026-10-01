import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/task_providers.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import 'package:seeker_app/core/utils/flushbar_message.dart';

import 'package:seeker_app/core/utils/num_extension.dart';

import 'package:seeker_app/features/task/presentation/screens/cancel_task_screen.dart';

class TaskDetailOptionsSheet extends ConsumerWidget {
  final Task task;

  const TaskDetailOptionsSheet({super.key, required this.task});

  static Future<T?> show<T>(BuildContext context, {required Task task}) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      builder: (context) => TaskDetailOptionsSheet(task: task),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final status = task.status?.toLowerCase() ?? 'open';
    final isDraft = status == 'draft';
    final isNoMatch = status == 'no_match' || status == 'no match' || status == 'nomatch';
    final isCompleted = status == 'completed';
    final isCancelled = status == 'cancelled';
    final showPinActions = const {
      'assigned',
      'booked',
      'in_progress',
      'started',
      'completed',
    }.contains(status);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle Bar
                Center(
                  child: Container(
                    width: 36.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                // Task Summary Header Tile
                _TaskHeaderSummary(task: task),

                SizedBox(height: 14.h),

                Text(
                  'Task Actions',
                  style: textTheme.titleSmall?.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 6.h),

                // Option Tiles List
                _OptionTiles(
                  children: [
                    if (isDraft)
                      _OptionTile(
                        icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                        title: 'Confirm Task Order',
                        subtitle:
                            'Proceed to publish and match with a provider',
                        iconBgColor: AppColors.primary.withValues(alpha: 0.12),
                        iconColor: AppColors.primary,
                        onTap: () {
                          Navigator.of(context).pop();
                          if (task.id != null) {
                            ref
                                .read(taskManagementProvider.notifier)
                                .confirmDraft(
                                  taskId: task.id!,
                                  onSuccess: () {
                                    ref.invalidate(
                                      taskDetailProvider(task.id!),
                                    );
                                  },
                                );
                          }
                        },
                      ),

                    if (showPinActions) ...[
                      _OptionTile(
                        icon: HugeIcons.strokeRoundedTask01,
                        title: 'Get Start Pin',
                        subtitle: '****',
                        iconBgColor: AppColors.primary.withValues(alpha: 0.12),
                        iconColor: AppColors.primary,
                        onTap: () {
                          Navigator.of(context).pop();
                          PinDisplaySheet.show(context, pin: task.startPin);
                        },
                      ),

                      _OptionTile(
                        icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                        title: 'Get Completion Pin',
                        subtitle: '****',
                        iconBgColor: Colors.orange.withValues(alpha: 0.12),
                        iconColor: Colors.orange.shade700,
                        onTap: () {
                          Navigator.of(context).pop();
                          PinDisplaySheet.show(
                            context,
                            pin: task.completionPin,
                          );
                        },
                      ),
                    ],

                    _OptionTile(
                      icon: HugeIcons.strokeRoundedShield01,
                      title: 'Verify Provider Identity',
                      subtitle: 'Verify provider PIN for security & access',
                      iconBgColor: colorScheme.primaryContainer.withValues(
                        alpha: 0.6,
                      ),
                      iconColor: colorScheme.primary,
                      onTap: () {
                        Navigator.of(context).pop();
                        if (task.id != null) {
                          context.pushNamed(
                            RouteNames.verifyProvider.name,
                            pathParameters: {'taskId': task.id!},
                          );
                        }
                      },
                    ),

                    _OptionTile(
                      icon: HugeIcons.strokeRoundedCopy01,
                      title: 'Copy Task ID',
                      subtitle: task.id ?? 'No ID available',
                      iconBgColor: colorScheme.surfaceContainerHighest,
                      iconColor: colorScheme.onSurface,
                      onTap: () {
                        final taskId = task.id;
                        Navigator.of(context).pop();
                        if (taskId != null) {
                          Clipboard.setData(ClipboardData(text: taskId));
                          context.showMessage(
                            'Task ID copied to clipboard',
                            type: MessageType.success,
                            title: 'Copied',
                          );
                        }
                      },
                    ),

                    _OptionTile(
                      icon: HugeIcons.strokeRoundedCustomerSupport,
                      title: 'Contact Customer Support',
                      subtitle: 'Get help or report an issue with this task',
                      iconBgColor: Colors.blue.withValues(alpha: 0.12),
                      iconColor: Colors.blue.shade700,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.pushNamed(
                          RouteNames.createSupportCase.name,
                          queryParameters: {
                            if (task.id != null) 'taskId': task.id!,
                          },
                        );
                      },
                    ),

                    if (!isCompleted && !isCancelled && !isNoMatch)
                      _OptionTile(
                        icon: HugeIcons.strokeRoundedCancel01,
                        title: 'Cancel Task',
                        subtitle: 'Stop this task and request cancellation',
                        isDestructive: true,
                        iconBgColor: Colors.orange.withValues(alpha: 0.12),
                        iconColor: Colors.orange.shade800,
                        onTap: () {
                          Navigator.of(context).pop();
                          if (task.id != null) {
                            CancelTaskScreen.navigate(context, task: task);
                          }
                        },
                      ),

                    _OptionTile(
                      icon: HugeIcons.strokeRoundedAlert01,
                      title: 'Report Provider / Issue',
                      subtitle:
                          'Flag inappropriate behavior or safety concerns',
                      isDestructive: true,
                      iconBgColor: colorScheme.error.withValues(alpha: 0.12),
                      iconColor: colorScheme.error,
                      onTap: () {
                        Navigator.of(context).pop();
                        context.pushNamed(
                          RouteNames.createSupportCase.name,
                          queryParameters: {
                            'type': 'DISPUTE',
                            'subject': 'Provider Issue',
                            if (task.id != null) 'taskId': task.id!,
                            if (task.assignment?.id != null)
                              'assignmentId': task.assignment!.id!,
                          },
                        );
                      },
                    ),
                  ],
                ),

                SizedBox(height: 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PinDisplaySheet extends StatelessWidget {
  final String? pin;

  const PinDisplaySheet({super.key, this.pin});

  static Future<void> show(BuildContext context, {required String? pin}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PinDisplaySheet(pin: pin),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pinValue = pin?.trim();
    final hasPin = pinValue != null && pinValue.isNotEmpty;
    final safePin = pinValue ?? '';

    void copyPin() {
      if (!hasPin) return;
      Clipboard.setData(ClipboardData(text: safePin));
      context.showMessage(
        'Pin copied to clipboard',
        type: MessageType.success,
        title: 'Copied',
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hasPin ? 'Task Verification PIN' : 'PIN Unavailable',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
            SizedBox(height: 4.h),
            Text(
              hasPin
                  ? 'Share this code with your service provider when needed.'
                  : 'PIN is not available yet.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 14.h),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: hasPin ? copyPin : null,
                borderRadius: BorderRadius.circular(14.r),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(
                      alpha: isDark ? 0.12 : 0.06,
                    ),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(
                      color: AppColors.primary.withValues(
                        alpha: isDark ? 0.3 : 0.2,
                      ),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        hasPin ? safePin : '—',
                        style: AppTextStyles.heading1.copyWith(
                          color: AppColors.primary,
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 4.0,
                        ),
                      ),
                      if (hasPin) ...[
                        SizedBox(width: 12.w),
                        Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedCopy01,
                            color: AppColors.primary,
                            size: 16.sp,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }
}

// Task Header Summary inside bottom sheet
class _TaskHeaderSummary extends StatelessWidget {
  final Task task;

  const _TaskHeaderSummary({required this.task});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final priceStr = task.customerTotalPrice != null
        ? task.customerTotalPrice!.toNaira(2)
        : (task.basePrice != null ? task.basePrice!.toNaira(2) : 'TBD');

    final statusText = (task.status ?? 'OPEN').toUpperCase();

    Color statusBgColor() {
      final s = statusText.toLowerCase();
      if (s.contains('cancel')) return Colors.red.withValues(alpha: 0.15);
      if (s.contains('draft')) return Colors.orange.withValues(alpha: 0.15);
      return AppColors.primary.withValues(alpha: 0.15);
    }

    Color statusTextColor() {
      final s = statusText.toLowerCase();
      if (s.contains('cancel')) return Colors.red;
      if (s.contains('draft')) return Colors.orange.shade800;
      return AppColors.primary;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Container(
            width: 38.r,
            height: 38.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedTask01,
                color: AppColors.primary,
                size: 18.sp,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  task.title ?? 'Task Details',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 3.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: statusBgColor(),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    statusText,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: statusTextColor(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            priceStr,
            style: textTheme.titleMedium?.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// Container for grouping option tiles
class _OptionTiles extends StatelessWidget {
  final List<Widget> children;

  const _OptionTiles({required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(children: children);
  }
}

// Individual option tile widget
class _OptionTile extends StatelessWidget {
  final dynamic icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconBgColor;
  final Color iconColor;
  final bool isDestructive;

  const _OptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.iconBgColor,
    required this.iconColor,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final titleColor = isDestructive
        ? colorScheme.error
        : colorScheme.onSurface;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 7.h),
          child: Row(
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: HugeIcon(icon: icon, color: iconColor, size: 18.sp),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
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
