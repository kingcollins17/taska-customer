import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/models/tasks/assignment.dart';
import 'package:seeker_app/core/providers/task_providers.dart';
import 'package:seeker_app/core/routes/route_names.dart';

class MatchingScreen extends ConsumerStatefulWidget {
  final String taskId;

  const MatchingScreen({super.key, required this.taskId});

  @override
  ConsumerState<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends ConsumerState<MatchingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(minutes: 2), (timer) {
      final task = ref.read(taskDetailProvider(widget.taskId));
      if (task.value?.status?.toLowerCase().contains('assigned') == true) {
        timer.cancel();
      } else {
        ref.invalidate(taskDetailProvider(widget.taskId));
        ref.invalidate(taskAssignmentProvider(widget.taskId));
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskDetailProvider(widget.taskId));
    final assignmentAsync = ref.watch(taskAssignmentProvider(widget.taskId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bool isAssigned =
        taskAsync.hasValue &&
        (taskAsync.value?.status?.toLowerCase().contains('assigned') ??
            false) &&
        (taskAsync.value?.assignment != null || assignmentAsync.value != null);

    // Get assignment data from either source
    final assignment = assignmentAsync.value ?? taskAsync.value?.assignment;
    final provider = assignment?.provider;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              const Spacer(),
              // Radar spinner — shrinks when assigned
              _RadarSpinner(isAssigned: isAssigned),
              SizedBox(height: isAssigned ? 32.h : 48.h),
              // Timeline — always visible, text changes on assignment
              _TimelineSection(
                isAssigned: isAssigned,
                provider: provider,
                isDark: isDark,
              ),
              // Provider info card — slides in below timeline when assigned
              if (isAssigned && provider != null)
                _ProviderInfoCard(provider: provider, isDark: isDark)
                    .animate()
                    .fadeIn(duration: 400.ms, delay: 200.ms)
                    .slideY(
                      begin: 0.15,
                      end: 0,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic,
                    ),
              const Spacer(),
              // Bottom action
              if (isAssigned)
                Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: ElevatedButton(
                    onPressed: () {
                      context.pushReplacementNamed(
                        RouteNames.taskDetail.name,
                        pathParameters: {'taskId': widget.taskId},
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
                    child: Text(
                      'View Task Details',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 400.ms),
                )
              else
                Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: TextButton(
                    onPressed: () => context.pop(),
                    child: Text(
                      'Go Back',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isDark
                            ? Colors.redAccent[100]
                            : Colors.redAccent,
                        fontSize: 13.sp,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Radar Spinner — scales down when assigned
// ---------------------------------------------------------------------------
class _RadarSpinner extends StatelessWidget {
  final bool isAssigned;

  const _RadarSpinner({required this.isAssigned});

  @override
  Widget build(BuildContext context) {
    final double size = isAssigned ? 100.0 : 160.0;
    final double padding = isAssigned ? 28.0 : 48.0;

    return AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: isAssigned
              ? Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.primary,
                      size: size * 0.6,
                    )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.0, 1.0),
                      duration: 400.ms,
                      curve: Curves.elasticOut,
                    )
              : SpinKitRipple(
                  color: AppColors.primary,
                  size: size,
                  borderWidth: 8.0,
                ),
        )
        .animate(onPlay: isAssigned ? null : (c) => c.repeat(reverse: true))
        .scale(
          begin: isAssigned ? const Offset(1.0, 1.0) : const Offset(0.95, 0.95),
          end: isAssigned ? const Offset(1.0, 1.0) : const Offset(1.05, 1.05),
          duration: 1500.ms,
          curve: Curves.easeInOut,
        );
  }
}

// ---------------------------------------------------------------------------
// Timeline Section — text evolves on assignment
// ---------------------------------------------------------------------------
class _TimelineSection extends StatelessWidget {
  final bool isAssigned;
  final TaskAssignmentProvider? provider;
  final bool isDark;

  const _TimelineSection({
    required this.isAssigned,
    required this.provider,
    required this.isDark,
  });

  String _firstName() {
    final name = provider?.fullname;
    if (name == null || name.isEmpty) return 'Tasker';
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
          children: [
            _buildStep(
              title: 'Finding your Tasker',
              subtitle: 'Scanning network for the nearest qualified Tasker.',
              isCompleted: true,
              isActive: false,
              isLast: false,
            ),
            _buildStep(
              title: isAssigned
                  ? '${_firstName()} accepted your task'
                  : 'Awaiting confirmation',
              subtitle: isAssigned
                  ? 'Your task has been booked and is now assigned.'
                  : 'A Tasker has been matched. Awaiting their response...',
              isCompleted: isAssigned,
              isActive: !isAssigned,
              isLast: true,
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 600.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
  }

  Widget _buildStep({
    required String title,
    required String subtitle,
    required bool isCompleted,
    required bool isActive,
    required bool isLast,
  }) {
    final color = (isCompleted || isActive)
        ? AppColors.primary
        : (isDark ? Colors.white24 : Colors.black26);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline dot + line
          Column(
            children: [
              Container(
                width: 22.r,
                height: 22.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted ? AppColors.primary : Colors.transparent,
                  border: Border.all(
                    color: color,
                    width: isCompleted || isActive ? 2 : 1.5,
                  ),
                ),
                child: isCompleted
                    ? Icon(
                        Icons.check_rounded,
                        size: 13.sp,
                        color: Colors.white,
                      )
                    : isActive
                    ? Center(
                        child: SpinKitPulse(
                          color: AppColors.primary,
                          size: 10.0,
                        ),
                      )
                    : null,
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isCompleted
                        ? AppColors.primary
                        : (isDark ? Colors.white12 : Colors.black12),
                  ),
                ),
            ],
          ),
          SizedBox(width: 14.w),
          // Text content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontSize: 14.sp,
                      fontWeight: (isActive || isCompleted)
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: (isActive || isCompleted)
                          ? (isDark ? Colors.white : AppColors.textPrimary)
                          : (isDark ? Colors.white38 : Colors.black38),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11.5.sp,
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Provider Info Card — compact, appears inline after assignment
// ---------------------------------------------------------------------------
class _ProviderInfoCard extends StatelessWidget {
  final TaskAssignmentProvider provider;
  final bool isDark;

  const _ProviderInfoCard({required this.provider, required this.isDark});

  String _initials() {
    final name = provider.fullname ?? '';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final rating = provider.averageRatings;
    final tasksCompleted = provider.totalTasksCompleted;
    final credibility = provider.credibilityScore;

    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.1 : 0.05),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.12),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Avatar row
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 22.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                backgroundImage: provider.profilePictureUrl != null
                    ? NetworkImage(provider.profilePictureUrl!)
                    : null,
                child: provider.profilePictureUrl == null
                    ? Text(
                        _initials(),
                        style: AppTextStyles.heading3.copyWith(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 12.w),
              // Name + rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.fullname ?? 'Tasker',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    if (rating != null)
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 14.sp,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 3.w),
                          Text(
                            rating.toStringAsFixed(1),
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'rating',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 10.5.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              // Verified badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedShield01,
                      size: 12.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Verified',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Stats row
          Container(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                _StatItem(
                  icon: Icons.star_rounded,
                  value: rating != null ? rating.toStringAsFixed(1) : '—',
                  label: 'Rating',
                  isDark: isDark,
                ),
                _divider(isDark),
                _StatItem(
                  icon: Icons.check_circle_outline_rounded,
                  value: tasksCompleted != null ? '$tasksCompleted' : '—',
                  label: 'Completed',
                  isDark: isDark,
                ),
                _divider(isDark),
                _StatItem(
                  icon: Icons.verified_user_outlined,
                  value: credibility != null
                      ? '${credibility.toStringAsFixed(0)}%'
                      : '—',
                  label: 'Trust',
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Container(
      width: 1,
      height: 28.h,
      color: isDark ? Colors.white12 : Colors.black12,
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool isDark;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13.sp, color: AppColors.primary),
              SizedBox(width: 4.w),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 10.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
