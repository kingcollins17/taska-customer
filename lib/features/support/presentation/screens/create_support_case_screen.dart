import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/support_providers.dart';
import 'package:seeker_app/core/utils/flushbar_message.dart';
import 'package:seeker_app/core/utils/loading_overlay.dart';

class CreateSupportCaseScreen extends ConsumerStatefulWidget {
  final String? taskId;
  final String? assignmentId;
  final String? payoutId;
  final String? type;
  final String? subject;
  final String? description;

  const CreateSupportCaseScreen({
    super.key,
    this.taskId,
    this.assignmentId,
    this.payoutId,
    this.type,
    this.subject,
    this.description,
  });

  @override
  ConsumerState<CreateSupportCaseScreen> createState() =>
      _CreateSupportCaseScreenState();
}

class _CreateSupportCaseScreenState
    extends ConsumerState<CreateSupportCaseScreen> {
  int _currentStep = 1;
  String _selectedType = 'GENERAL';

  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.type != null && widget.type!.trim().isNotEmpty) {
      _selectedType = widget.type!.trim().toUpperCase();
      _currentStep = 2;
    }
    if (widget.subject != null && widget.subject!.isNotEmpty) {
      _subjectController.text = widget.subject!;
    }
    if (widget.description != null && widget.description!.isNotEmpty) {
      _descriptionController.text = widget.description!;
    }
  }

  final List<({String type, String title, String description, List<Color> colors, dynamic icon})>
      _issueCategories = [
    (
      type: 'GENERAL',
      title: 'General Inquiry',
      description: 'Questions about usage, features, or policies',
      colors: [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
      icon: HugeIcons.strokeRoundedCustomerSupport,
    ),
    (
      type: 'DISPUTE',
      title: 'Dispute / Provider',
      description: 'Issues with provider conduct or task delivery',
      colors: [const Color(0xFFEF4444), const Color(0xFFB91C1C)],
      icon: HugeIcons.strokeRoundedAlertCircle,
    ),
    (
      type: 'PAYMENT',
      title: 'Payment & Billing',
      description: 'Charges, refunds, or payment issues',
      colors: [const Color(0xFF10B981), const Color(0xFF047857)],
      icon: HugeIcons.strokeRoundedCreditCard,
    ),
    (
      type: 'TASK_ISSUE',
      title: 'Task Issue',
      description: 'Trouble scheduling or executing a task',
      colors: [const Color(0xFFF59E0B), const Color(0xFFB45309)],
      icon: HugeIcons.strokeRoundedTask01,
    ),
    (
      type: 'ACCOUNT',
      title: 'Account & Security',
      description: 'Login, password, or security settings',
      colors: [const Color(0xFF8B5CF6), const Color(0xFF6D28D9)],
      icon: HugeIcons.strokeRoundedUser,
    ),
    (
      type: 'TECHNICAL',
      title: 'Technical Support',
      description: 'App errors, crashes, or glitches',
      colors: [const Color(0xFFEC4899), const Color(0xFFBE185D)],
      icon: HugeIcons.strokeRoundedSmartPhone01,
    ),
    (
      type: 'OTHER',
      title: 'Other Issue',
      description: 'Any other question or request',
      colors: [const Color(0xFF6B7280), const Color(0xFF374151)],
      icon: HugeIcons.strokeRoundedMoreHorizontal,
    ),
  ];

  /// Priority is automatically determined by system based on issue type
  String _getAutoPriority(String type) {
    switch (type) {
      case 'DISPUTE':
      case 'PAYMENT':
        return 'HIGH';
      case 'TASK_ISSUE':
      case 'TECHNICAL':
      case 'ACCOUNT':
        return 'NORMAL';
      case 'GENERAL':
      case 'OTHER':
      default:
        return 'NORMAL';
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitCase() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();
    context.showLoading();

    try {
      final autoPriority = _getAutoPriority(_selectedType);
      final request = CreateSupportCaseRequest(
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        priority: autoPriority,
        taskId: widget.taskId,
        assignmentId: widget.assignmentId,
        payoutId: widget.payoutId,
      );

      await ref.read(supportActionsProvider.notifier).createCase(
            request: request,
            onSuccess: (supportCase) {
              if (!mounted) return;
              context.hideLoading();
              context.showMessage(
                'Support ticket #${supportCase.caseNumber ?? ""} created successfully.',
                type: MessageType.success,
                title: 'Request Submitted',
              );
              context.pop();
            },
            onError: (error) {
              if (!mounted) return;
              context.hideLoading();
              context.showMessage(
                error,
                type: MessageType.error,
                title: 'Submission Failed',
              );
            },
          );
    } catch (e) {
      if (!mounted) return;
      context.hideLoading();
      context.showMessage(
        'An unexpected error occurred. Please try again.',
        type: MessageType.error,
        title: 'Error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 48.h,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorScheme.onSurface,
            size: 18.sp,
          ),
          onPressed: () {
            if (_currentStep == 2) {
              setState(() {
                _currentStep = 1;
              });
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          'Customer Support',
          style: AppTextStyles.heading3.copyWith(
            color: colorScheme.onSurface,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Compact step header indicator
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: Row(
                children: [
                  Expanded(
                    child: _StepProgressIndicator(
                      stepNumber: 1,
                      label: 'Category',
                      isActive: _currentStep >= 1,
                      isCompleted: _currentStep > 1,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _StepProgressIndicator(
                      stepNumber: 2,
                      label: 'Details',
                      isActive: _currentStep >= 2,
                      isCompleted: false,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),

            // Animated step view
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _currentStep == 1
                    ? _buildStepOne(colorScheme, isDark)
                    : _buildStepTwo(colorScheme, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepOne(ColorScheme colorScheme, bool isDark) {
    return Column(
      key: const ValueKey(1),
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Issue Category',
                  style: AppTextStyles.heading2.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.08, end: 0),
                SizedBox(height: 2.h),
                Text(
                  'Choose the topic that best matches your support request.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 12.sp,
                  ),
                ),
                SizedBox(height: 12.h),

                // Compact 2-column Grid of Categories
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.w,
                    mainAxisSpacing: 10.h,
                    mainAxisExtent: 112.h,
                  ),
                  itemCount: _issueCategories.length,
                  itemBuilder: (context, index) {
                    final item = _issueCategories[index];
                    final isSelected = _selectedType == item.type;
                    final cardBg =
                        isDark ? const Color(0xFF1E1E1E) : Colors.white;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedType = item.type;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.onSurface
                                    .withValues(alpha: 0.08),
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: colorScheme.primary
                                        .withValues(alpha: 0.15),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ]
                              : isDark
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: Colors.black
                                            .withValues(alpha: 0.03),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width: 30.r,
                                  height: 30.r,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: item.colors,
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(9.r),
                                  ),
                                  child: Center(
                                    child: HugeIcon(
                                      icon: item.icon,
                                      color: Colors.white,
                                      size: 16.sp,
                                    ),
                                  ),
                                ),
                                Container(
                                  width: 18.r,
                                  height: 18.r,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? colorScheme.primary
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected
                                          ? colorScheme.primary
                                          : colorScheme.onSurface
                                              .withValues(alpha: 0.25),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check_rounded,
                                          color: colorScheme.onPrimary,
                                          size: 11.sp,
                                        )
                                      : null,
                                ),
                              ],
                            ),
                            SizedBox(height: 6.h),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: colorScheme.onSurface,
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  item.description,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: colorScheme.onSurface
                                        .withValues(alpha: 0.5),
                                    fontSize: 10.sp,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(
                          duration: 200.ms,
                          delay: (index * 35).ms,
                        ).slideY(begin: 0.08, end: 0);
                  },
                ),
              ],
            ),
          ),
        ),

        // Bottom Action Button
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            border: Border(
              top: BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStep = 2;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Continue to Details',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onPrimary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepTwo(ColorScheme colorScheme, bool isDark) {
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final selectedCategory = _issueCategories.firstWhere(
      (c) => c.type == _selectedType,
      orElse: () => _issueCategories.first,
    );

    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey(2),
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Describe Your Issue',
                    style: AppTextStyles.heading2.copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.08, end: 0),
                  SizedBox(height: 2.h),
                  Text(
                    'Provide clear details so we can resolve your request.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Selected Category summary tag
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: selectedCategory.colors.first
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: selectedCategory.colors.first
                            .withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: selectedCategory.icon,
                          color: selectedCategory.colors.first,
                          size: 15.sp,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          'Category: ${selectedCategory.title}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: selectedCategory.colors.first,
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Associated context info badge if taskId exists
                  if (widget.taskId != null && widget.taskId!.isNotEmpty) ...[
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedTag01,
                            color: colorScheme.primary,
                            size: 15.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'Linked Task: #${widget.taskId}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: colorScheme.primary,
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.h),
                  ],

                  // Subject Input Field
                  Text(
                    'Subject *',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: _subjectController,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 13.sp,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Brief summary of your issue',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 12.5.sp,
                      ),
                      filled: true,
                      fillColor: cardBg,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: colorScheme.onSurface.withValues(alpha: 0.1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: colorScheme.onSurface.withValues(alpha: 0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Subject is required';
                      }
                      if (value.trim().length < 3) {
                        return 'Subject must be at least 3 characters';
                      }
                      if (value.trim().length > 255) {
                        return 'Subject cannot exceed 255 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 14.h),

                  // Description Input Field
                  Text(
                    'Description *',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: colorScheme.onSurface,
                      fontSize: 13.sp,
                    ),
                    decoration: InputDecoration(
                      hintText:
                          'Please provide details on what happened and how we can help...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                        fontSize: 12.5.sp,
                      ),
                      filled: true,
                      fillColor: cardBg,
                      contentPadding: EdgeInsets.all(12.w),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: colorScheme.onSurface.withValues(alpha: 0.1),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: colorScheme.onSurface.withValues(alpha: 0.1),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: colorScheme.primary,
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required';
                      }
                      if (value.trim().length < 5) {
                        return 'Description must be at least 5 characters';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: cardBg,
              border: Border(
                top: BorderSide(
                  color: colorScheme.onSurface.withValues(alpha: 0.08),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _currentStep = 1;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      side: BorderSide(
                        color: colorScheme.onSurface.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Text(
                      'Back',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: 13.5.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _submitCase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Submit Request',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onPrimary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepProgressIndicator extends StatelessWidget {
  final int stepNumber;
  final String label;
  final bool isActive;
  final bool isCompleted;

  const _StepProgressIndicator({
    required this.stepNumber,
    required this.label,
    required this.isActive,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 20.r,
          height: 20.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? colorScheme.primary : Colors.transparent,
            border: Border.all(
              color: isActive
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.25),
              width: 1.5,
            ),
          ),
          child: Center(
            child: isCompleted
                ? Icon(
                    Icons.check_rounded,
                    color: colorScheme.onPrimary,
                    size: 12.sp,
                  )
                : Text(
                    '$stepNumber',
                    style: AppTextStyles.label.copyWith(
                      color: isActive
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
        SizedBox(width: 6.w),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isActive
                  ? colorScheme.onSurface
                  : colorScheme.onSurface.withValues(alpha: 0.4),
              fontSize: 11.5.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
