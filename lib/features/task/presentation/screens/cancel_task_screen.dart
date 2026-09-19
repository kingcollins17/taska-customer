import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/designs/widgets/custom_back_button.dart';
import 'package:seeker_app/core/designs/widgets/primary_button.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/task_providers.dart';
import 'package:seeker_app/core/utils/flushbar_message.dart';
import 'package:seeker_app/core/utils/loading_overlay.dart';
import 'package:seeker_app/core/utils/num_extension.dart';

class CancelTaskScreen extends ConsumerStatefulWidget {
  final Task task;

  const CancelTaskScreen({super.key, required this.task});

  static Future<T?> navigate<T>(BuildContext context, {required Task task}) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute(
        builder: (context) => CancelTaskScreen(task: task),
      ),
    );
  }

  @override
  ConsumerState<CancelTaskScreen> createState() => _CancelTaskScreenState();
}

class _CancelTaskScreenState extends ConsumerState<CancelTaskScreen> {
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  String? _selectedReasonOption;
  bool _isSubmitting = false;

  final List<String> _quickReasons = [
    'Schedule conflict / Change of plans',
    'Provider requested cancellation',
    'Found an alternative solution',
    'Price or scope disagreement',
    'Other reason',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleCancelTask() async {
    final customReason = _reasonController.text.trim();
    final combinedReason = _selectedReasonOption != null
        ? (_selectedReasonOption == 'Other reason' && customReason.isNotEmpty
            ? customReason
            : '$_selectedReasonOption${customReason.isNotEmpty ? ': $customReason' : ''}')
        : customReason;

    if (combinedReason.isEmpty) {
      context.showMessage(
        'Please select or enter a cancellation reason',
        type: MessageType.error,
      );
      return;
    }

    final pinText = _pinController.text.trim();
    final status = widget.task.status?.toLowerCase() ?? 'open';
    final isInProgress = status == 'in_progress' || status == 'started';

    if (isInProgress && pinText.isEmpty) {
      context.showMessage(
        'Please enter the cancellation PIN provided by your provider',
        type: MessageType.error,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    FocusScope.of(context).unfocus();
    context.showLoading();

    final isDraft = status == 'draft';

    if (isDraft) {
      await ref.read(taskManagementProvider.notifier).cancelDraft(
            taskId: widget.task.id!,
            onSuccess: () {
              if (!mounted) return;
              context.hideLoading();
              Navigator.of(context).pop();
              context.showMessage(
                'Draft task cancelled successfully',
                type: MessageType.success,
                title: 'Task Cancelled',
              );
            },
            onError: (err) {
              if (!mounted) return;
              context.hideLoading();
              setState(() {
                _isSubmitting = false;
              });
              context.showMessage(
                err,
                type: MessageType.error,
                title: 'Cancellation Failed',
              );
            },
          );
    } else {
      final request = CancelTaskRequest(
        cancellationReason: combinedReason,
        cancellationPin: pinText.isNotEmpty ? pinText : null,
      );

      await ref.read(taskManagementProvider.notifier).cancelTask(
            taskId: widget.task.id!,
            request: request,
            onSuccess: (updatedTask) {
              if (!mounted) return;
              context.hideLoading();
              Navigator.of(context).pop();
              context.showMessage(
                'Task cancelled successfully',
                type: MessageType.success,
                title: 'Task Cancelled',
              );
            },
            onError: (err) {
              if (!mounted) return;
              context.hideLoading();
              setState(() {
                _isSubmitting = false;
              });
              context.showMessage(
                err,
                type: MessageType.error,
                title: 'Cancellation Failed',
              );
            },
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final status = widget.task.status?.toLowerCase() ?? 'open';
    final isInProgress = status == 'in_progress' || status == 'started';
    final isAssigned = status == 'assigned' || status == 'matched' || status == 'booked';
    final isDraft = status == 'draft';

    final priceStr = widget.task.customerTotalPrice != null
        ? widget.task.customerTotalPrice!.toNaira(2)
        : (widget.task.basePrice != null ? widget.task.basePrice!.toNaira(2) : 'TBD');

    String getNoticeText() {
      if (isInProgress) {
        return 'This task is in progress. Enter the cancellation PIN provided by your task provider for mutual cancellation.';
      } else if (isAssigned) {
        return 'Cancelling this assigned task will notify your assigned provider immediately.';
      } else if (isDraft) {
        return 'Cancelling this draft task will remove your draft order.';
      } else {
        return 'Cancelling this task will stop provider matching and cancel your order.';
      }
    }

    final borderColor = isDark ? const Color(0xFF2C2F36) : const Color(0xFFE5E7EB);
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: EdgeInsets.all(8.r),
          child: const CustomBackButton(),
        ),
        centerTitle: true,
        title: Text(
          'Cancel Task',
          style: textTheme.titleMedium?.copyWith(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Overview Summary Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF22252D) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: borderColor, width: 1.w),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.task.title ?? 'Task Details',
                            style: AppTextStyles.label.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15.sp,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 10.w),
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
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.h),

              // Informative Notice Banner
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: (isInProgress ? Colors.amber : Colors.blue).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: (isInProgress ? Colors.amber : Colors.blue).withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedAlertCircle,
                      size: 20.sp,
                      color: isInProgress ? Colors.amber.shade800 : Colors.blue.shade700,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        getNoticeText(),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: textPrimary,
                          fontSize: 12.sp,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),

              // Reason Header
              Text(
                'Reason for Cancellation',
                style: AppTextStyles.label.copyWith(
                  color: textPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10.h),

              // Quick Reasons List
              ..._quickReasons.map((reason) {
                final isSelected = _selectedReasonOption == reason;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedReasonOption = reason;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.08)
                          : (isDark ? const Color(0xFF22252C) : const Color(0xFFF9FAFB)),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : borderColor,
                        width: isSelected ? 1.5.w : 1.w,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                          size: 20.sp,
                          color: isSelected ? AppColors.primary : textSecondary,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            reason,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: textPrimary,
                              fontSize: 13.sp,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              SizedBox(height: 10.h),

              // Custom Reason Input Field
              TextField(
                controller: _reasonController,
                maxLines: 3,
                minLines: 2,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: textPrimary,
                  fontSize: 13.sp,
                ),
                decoration: InputDecoration(
                  hintText: 'Additional details or custom reason...',
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: textSecondary,
                    fontSize: 12.5.sp,
                  ),
                  fillColor: isDark ? const Color(0xFF242730) : const Color(0xFFF3F5F8),
                  filled: true,
                  contentPadding: EdgeInsets.all(14.w),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Cancellation PIN Header & Input
              Row(
                children: [
                  Text(
                    'Cancellation PIN',
                    style: AppTextStyles.label.copyWith(
                      color: textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    isInProgress ? '(Required for Mutual Cancellation)' : '(Optional)',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isInProgress ? AppColors.error : textSecondary,
                      fontSize: 11.5.sp,
                      fontWeight: isInProgress ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: textPrimary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'Enter provider PIN (e.g. 1234)',
                  hintStyle: AppTextStyles.bodySmall.copyWith(
                    color: textSecondary,
                    fontSize: 12.5.sp,
                    letterSpacing: 0,
                  ),
                  prefixIcon: Icon(
                    Icons.lock_outline,
                    size: 20.sp,
                    color: AppColors.primary,
                  ),
                  fillColor: isDark ? const Color(0xFF242730) : const Color(0xFFF3F5F8),
                  filled: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              // Action Button
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Cancel Task',
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  height: 48.h,
                  fontSize: 14.sp,
                  onPressed: _isSubmitting ? null : _handleCancelTask,
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}
