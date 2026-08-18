import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:seeker_app/core/constants.dart';
import 'package:seeker_app/core/designs/widgets/confirmation_dialog.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/features/profile/providers/account_issues_provider.dart';
import 'package:seeker_app/core/providers/theme_provider.dart';
import '../../../../core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import '../../../../core/providers/user_provider.dart';
import 'package:seeker_app/core/designs/widgets/current_location.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter/foundation.dart';
import 'package:seeker_app/core/designs/widgets/debug_console_view.dart';

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My profile',
                          style: AppTextStyles.heading1.copyWith(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const CurrentLocation(),
                ],
              ),
              SizedBox(height: 12.h),

              if (accountIssues.isNotEmpty && user != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 24.h),
                  child: Column(
                    children: accountIssues
                        .map(
                          (issue) =>
                              _buildIssueBanner(context, ref, issue, user),
                        )
                        .toList(),
                  ),
                ),

              SizedBox(height: 24.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: userState.isLoading
                    ? _HeaderShimmer()
                    : Row(
                        children: [
                          Container(
                            width: 72.w,
                            height: 72.w,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkerBackground
                                    : AppColors.surface,
                                width: 3.w,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              _getInitials(
                                user?.customerProfile?.firstName,
                                user?.customerProfile?.lastName,
                              ),
                              style: AppTextStyles.heading1.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24.sp,
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: AppTextStyles.heading2.copyWith(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                if (email.isNotEmpty) ...[
                                  SizedBox(height: 2.h),
                                  Text(
                                    email,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      fontSize: 14.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                                SizedBox(height: 6.h),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(
                                      alpha: isDark ? 0.15 : 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12.r),
                                    border: Border.all(
                                      color: Colors.amber.withValues(
                                        alpha: isDark ? 0.3 : 0.2,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 14.sp,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        user?.averageRatings?.toStringAsFixed(
                                              1,
                                            ) ??
                                            '0.0',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: isDark
                                                  ? Colors.amber[300]
                                                  : Colors.amber[800],
                                              fontSize: 12.sp,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),

              SizedBox(height: 24.h),

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
              _MenuItem(
                icon: isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                title: 'Dark Mode',
                iconColor: Colors.deepPurple,
                trailing: Consumer(
                  builder: (context, ref, child) {
                    final themeMode = ref.watch(themeProvider);
                    final isDarkMode =
                        themeMode == ThemeMode.dark ||
                        (themeMode == ThemeMode.system &&
                            MediaQuery.platformBrightnessOf(context) ==
                                Brightness.dark);
                    return Switch(
                      value: isDarkMode,
                      onChanged: (val) {
                        ref.read(themeProvider.notifier).toggleTheme();
                      },
                      activeColor: AppColors.primary,
                    );
                  },
                ),
                onTap: () {
                  ref.read(themeProvider.notifier).toggleTheme();
                },
              ),

              SizedBox(height: 24.h),

              if (kDebugMode)
                _MenuItem(
                  icon: Icons.bug_report_outlined,
                  title: 'Debug Console',
                  iconColor: Colors.teal,
                  onTap: () {
                    DebugConsoleView.show(context);
                  },
                ),

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
    WidgetRef ref,
    AccountIssue issue,
    User user,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: () {
          rootNavigatorKey.currentContext;
          issue.handler?.call(context, ref, user);
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: isDark ? 0.2 : 0.1),
            border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
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
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    Text(
                      issue.description,
                      style: AppTextStyles.bodySmall.copyWith(
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

class _HeaderShimmer extends StatelessWidget {
  const _HeaderShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Row(
        children: [
          Container(
            width: 72.w,
            height: 72.w,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 150.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 200.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 60.w,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
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
    this.trailing,
  });

  final Widget? trailing;

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
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: isLogout
                      ? Colors.red
                      : AppColors.textSecondary.withValues(alpha: 0.5),
                  size: 24.sp,
                ),
          ],
        ),
      ),
    );
  }
}
