import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:seeker_app/core/constants.dart';
import 'package:seeker_app/core/designs/widgets/confirmation_dialog.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/utils/flushbar_message.dart';
import 'package:seeker_app/core/utils/loading_overlay.dart';
import 'package:seeker_app/features/auth/presentation/verify_otp_screen.dart';
import 'package:seeker_app/features/profile/providers/account_issues_provider.dart';
import '../../../../core/designs/app_colors.dart';
import '../../../../core/providers/user_provider.dart';
import '../../../../core/designs/widgets/phone_number_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  String _getInitials(String? firstName, String? lastName) {
    String first = (firstName != null && firstName.isNotEmpty)
        ? firstName[0]
        : '';
    String last = (lastName != null && lastName.isNotEmpty) ? lastName[0] : '';
    String initials = '$first$last'.toUpperCase();
    return initials.isNotEmpty ? initials : 'U';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final cardColor = isDark ? AppColors.darkerBackground : AppColors.surface;

    final userState = ref.watch(userProvider);
    final user = userState.value;

    final name = user?.customerProfile != null
        ? '${user!.customerProfile!.firstName} ${user.customerProfile!.lastName}'
        : 'User';
    final email = user?.email ?? '';
    final accountIssues = ref.watch(accountIssuesProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My profile',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'View and manage your profile details below.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 32.h),

              if (accountIssues.isNotEmpty && user != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: Column(
                    children: accountIssues
                        .map((issue) => _buildIssueBanner(context, issue, user))
                        .toList(),
                  ),
                ),

              // Profile Card with Banner
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2A0845), Color(0xFF6441A5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const _StatCard(
                              label: 'Total Tasks',
                              value: '0',
                              color: Colors.white,
                            ),
                            SizedBox(width: 16.w),
                            const _StatCard(
                              label: 'Average Rating',
                              value: '0.0',
                              color: Colors.white,
                            ),
                            SizedBox(width: 16.w),
                            const _StatCard(
                              label: 'Credibility',
                              value: '0',
                              color: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h), // space for avatar overlapping
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: -30.h,
                    left: 20.w,
                    child: Container(
                      width: 60.w,
                      height: 60.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: bgColor, width: 3),
                        color: AppColors.primary,
                      ),
                      child: Text(
                        _getInitials(
                          user?.customerProfile?.firstName,
                          user?.customerProfile?.lastName,
                        ),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              // Menu Items
              _MenuItem(
                icon: Icons.person_outline,
                title: 'Update profile',
                iconColor: Colors.blue,
                onTap: () {
                  context.push('/profile-details');
                },
              ),
              _MenuItem(
                icon: Icons.account_balance_wallet_outlined,
                title: 'Update Bank Details',
                iconColor: Colors.green,
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.payments_outlined,
                title: 'See Transactions',
                iconColor: Colors.orange,
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.support_agent_outlined,
                title: 'Customer support',
                iconColor: Colors.pink,
                onTap: () {},
              ),
              _MenuItem(
                icon: Icons.info_outline,
                title: 'About us',
                iconColor: Colors.purple,
                onTap: () {},
              ),

              SizedBox(height: 24.h),

              // Log Out
              _MenuItem(
                icon: Icons.logout,
                title: 'Logout',
                iconColor: Colors.red,
                isLogout: true,
                onTap: () async {
                  final confirm = await ConfirmationDialog.show(
                    context: context,
                    title: 'Logout',
                    description: 'Are you sure you want to logout',
                  );
                  if (!confirm) return;
                  ref
                      .read(userProvider.notifier)
                      .logout(onSuccess: () => context.go('/login'));
                },
              ),

              SizedBox(height: 80.h), // Spacing for bottom nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIssueBanner(
    BuildContext context,
    AccountIssue issue,
    User user,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: () {
          rootNavigatorKey.currentContext;
          issue.handler?.call(context, user);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(isDark ? 0.2 : 0.1),
            border: Border.all(color: Colors.orange.withOpacity(0.5)),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              if (issue.icon != null)
                Icon(issue.icon, color: Colors.orange, size: 24.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      issue.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      issue.description,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isDark
                            ? Colors.white70
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.orange, size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, color: color.withOpacity(0.8)),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color iconColor;
  final bool isLogout;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.iconColor,
    this.isLogout = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isLogout
        ? Colors.red
        : (isDark ? Colors.white : AppColors.textPrimary);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isLogout
                  ? Colors.red
                  : AppColors.textSecondary.withOpacity(0.5),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }
}
