import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/task_providers.dart';
import 'package:seeker_app/core/utils/num_extension.dart';

class TaskDetailOptionsSheet extends ConsumerWidget {
  final Task task;

  const TaskDetailOptionsSheet({super.key, required this.task});

  static Future<T?> show<T>(BuildContext context, {required Task task}) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle Bar
              Center(
                child: Container(
                  width: 44.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(2.5.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

              // Task Summary Header Tile
              _TaskHeaderSummary(task: task),

              SizedBox(height: 20.h),

              Text(
                'Task Actions',
                style: textTheme.titleSmall?.copyWith(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 10.h),

              // Option Tiles List
              _OptionTiles(
                children: [
                  if (isDraft)
                    _OptionTile(
                      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                      title: 'Confirm Task Order',
                      subtitle: 'Proceed to publish and match with a provider',
                      iconBgColor: AppColors.primary.withValues(alpha: 0.12),
                      iconColor: AppColors.primary,
                      onTap: () {
                        Navigator.of(context).pop();
                        if (task.id != null) {
                          ref
                              .read(taskDraftActionProvider.notifier)
                              .confirmDraft(
                                taskId: task.id!,
                                onSuccess: () {
                                  ref.invalidate(taskDetailProvider(task.id!));
                                },
                              );
                        }
                      },
                    ),

                  _OptionTile(
                    icon: HugeIcons.strokeRoundedShare01,
                    title: 'Share Task Details',
                    subtitle: 'Send task details link or summary',
                    iconBgColor: colorScheme.primaryContainer.withValues(
                      alpha: 0.6,
                    ),
                    iconColor: colorScheme.primary,
                    onTap: () {
                      Navigator.of(context).pop();
                      final text =
                          'Task: ${task.title ?? 'Service'}\nStatus: ${task.status}\nID: ${task.id}';
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task summary copied for sharing'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),

                  _OptionTile(
                    icon: HugeIcons.strokeRoundedCopy01,
                    title: 'Copy Task ID',
                    subtitle: task.id ?? 'No ID available',
                    iconBgColor: colorScheme.surfaceContainerHighest,
                    iconColor: colorScheme.onSurface,
                    onTap: () {
                      if (task.id != null) {
                        Clipboard.setData(ClipboardData(text: task.id!));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Task ID copied to clipboard'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                      Navigator.of(context).pop();
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Connecting to customer support...'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),

                  if (status != 'completed' && status != 'cancelled')
                    _OptionTile(
                      icon: HugeIcons.strokeRoundedCancel01,
                      title: 'Cancel Task',
                      subtitle: 'Stop this task and request cancellation',
                      isDestructive: true,
                      iconBgColor: Colors.orange.withValues(alpha: 0.12),
                      iconColor: Colors.orange.shade800,
                      onTap: () {
                        Navigator.of(context).pop();
                        if (task.id != null && isDraft) {
                          ref
                              .read(taskDraftActionProvider.notifier)
                              .cancelDraft(taskId: task.id!);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Task cancellation request submitted',
                              ),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                    ),

                  _OptionTile(
                    icon: HugeIcons.strokeRoundedAlert01,
                    title: 'Report Provider / Issue',
                    subtitle: 'Flag inappropriate behavior or safety concerns',
                    isDestructive: true,
                    iconBgColor: colorScheme.error.withValues(alpha: 0.12),
                    iconColor: colorScheme.error,
                    onTap: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Report submitted for review'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 16.h),
            ],
          ),
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

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedTask01,
              color: AppColors.primary,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title ?? 'Task Details',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  'Status: ${(task.status ?? 'Open').toUpperCase()}',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            priceStr,
            style: textTheme.titleMedium?.copyWith(
              fontSize: 16.sp,
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
      margin: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Row(
            children: [
              Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: HugeIcon(icon: icon, color: iconColor, size: 20.sp),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 12.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                color: colorScheme.outlineVariant,
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
