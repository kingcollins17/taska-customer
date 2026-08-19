import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/utils/num_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker_app/core/providers/user_provider.dart';
import 'package:seeker_app/core/providers/notification_providers.dart';
import 'package:seeker_app/core/providers/websocket_provider.dart';
import 'package:seeker_app/core/providers/task_providers.dart';
import 'package:seeker_app/core/providers/services_provider.dart';
import 'package:seeker_app/core/providers/task_creation_provider.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:seeker_app/core/utils/category_icon_helper.dart';
import 'package:shimmer/shimmer.dart';
import 'package:seeker_app/core/designs/widgets/task_matching_banner.dart';
import 'widgets/home_app_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning 👋';
    if (hour < 17) return 'Good Afternoon 👋';
    return 'Good Evening 👋';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(userProvider);
    final notificationCountsAsync = ref.watch(notificationCountsProvider);
    final user = userAsync.value;
    ref.watch(deviceTrayNotificationsProvider);

    final String name = user?.customerProfile != null
        ? '${user!.customerProfile!.firstName ?? ''} ${user.customerProfile!.lastName ?? ''}'
              .trim()
        : 'Guest';
    final String greeting = _getGreeting();
    final int unreadCount = notificationCountsAsync.value?.unread ?? 0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              color: theme.colorScheme.primary,
              onRefresh: () async {
                try {
                  await Future.wait([
                    ref.refresh(userProvider.future),
                    ref.refresh(notificationCountsProvider.future),
                    ref.refresh(activeTasksProvider.future),
                    ref.refresh(categoriesProvider(null).future),
                    ref.refresh(tasksProvider.future),
                  ]);
                } catch (_) {}
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 16.h,
                  bottom: 100.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HomeAppBar(
                      name: name,
                      greeting: greeting,
                      unreadCount: unreadCount,
                    ),
                    SizedBox(height: 20.h),
                    const _SearchBar(),
                    SizedBox(height: 24.h),
                    const _ActiveWork(),
                    SizedBox(height: 28.h),
                    const _MainHero(),
                    SizedBox(height: 28.h),
                    const _PopularCategories(),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 16.h,
              left: 20.w,
              right: 20.w,
              child: const TaskMatchingBanner(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return GestureDetector(
      onTap: () {
        context.pushNamed(RouteNames.taskCategory.name);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.08),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: colorScheme.primary, size: 20.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                'Search services, e.g. Courier, Cleaning...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainHero extends StatelessWidget {
  const _MainHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: cardBg,
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E1E1E), const Color(0xFF262626)]
              : [Colors.white, const Color(0xFFF0FDF4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : colorScheme.primary.withValues(alpha: 0.15),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.bolt_rounded,
                  color: colorScheme.primary,
                  size: 14.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  'INSTANT MATCHING',
                  style: AppTextStyles.label.copyWith(
                    color: colorScheme.primary,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Get work done in real-time',
            style: AppTextStyles.heading2.copyWith(
              color: colorScheme.onSurface,
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Get matched with top-rated local pros in seconds. Fast, effortless, and reliable.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              fontSize: 13.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.pushNamed(RouteNames.taskCategory.name);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              icon: Icon(
                Icons.bolt_rounded,
                color: colorScheme.onPrimary,
                size: 20.sp,
              ),
              label: Text(
                'Get Started Now',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: colorScheme.onPrimary,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PopularCategories extends ConsumerWidget {
  const _PopularCategories();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoriesProvider(null));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular Categories',
              style: AppTextStyles.heading3.copyWith(
                color: colorScheme.onSurface,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () {
                context.pushNamed(RouteNames.taskCategory.name);
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'See all',
                style: AppTextStyles.bodySmall.copyWith(
                  color: colorScheme.primary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14.h),
        categoriesAsync.when(
          data: (categories) {
            final displayCategories = categories.take(4).toList();
            if (displayCategories.isEmpty) return const SizedBox.shrink();

            final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 2.4,
              ),
              itemCount: displayCategories.length,
              itemBuilder: (context, index) {
                final category = displayCategories[index];
                return GestureDetector(
                  onTap: () async {
                    if (category.id != null) {
                      await ref
                          .read(taskCreationProvider.notifier)
                          .updateCategory(category.id!);
                      if (context.mounted) {
                        context.pushNamed(
                          RouteNames.taskService.name,
                          queryParameters: {'categoryId': category.id!},
                        );
                      }
                    } else {
                      context.pushNamed(RouteNames.taskCategory.name);
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: 0.08),
                      ),
                      boxShadow: isDark
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: HugeIcon(
                              icon: getCategoryIcon(category.name),
                              color: colorScheme.primary,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              category.name ?? '',
                              textAlign: TextAlign.left,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: colorScheme.onSurface,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const _PopularCategoriesShimmer(),
          error: (e, st) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ActiveWork extends ConsumerWidget {
  const _ActiveWork();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tasksAsync = ref.watch(activeTasksProvider);

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) return const SizedBox.shrink();

        final displayTasks = tasks.take(1).toList();
        final showSeeAll = tasks.length > 1;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Work',
                  style: AppTextStyles.heading3.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (showSeeAll)
                  TextButton(
                    onPressed: () {
                      context.go('/tasks', extra: ['assigned', 'in_progress']);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'See all',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: colorScheme.primary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 14.h),
            ...displayTasks.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;

              final (
                String statusText,
                Color statusColor,
                Color chipColor,
              ) = switch (task.status) {
                'open' || 'pending' => (
                  'Searching',
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.12),
                ),
                'in_progress' || 'inprogress' => (
                  'In Progress',
                  Colors.purple.shade600,
                  Colors.purple.withValues(alpha: 0.12),
                ),
                'assigned' || 'matched' => (
                  'Booked',
                  Colors.orange.shade700,
                  Colors.orange.withValues(alpha: 0.12),
                ),
                'completed' => (
                  'Completed',
                  Colors.green.shade600,
                  Colors.green.withValues(alpha: 0.12),
                ),
                'cancelled' => (
                  'Cancelled',
                  Colors.red.shade600,
                  Colors.red.withValues(alpha: 0.12),
                ),
                _ => (
                  'Assigned',
                  colorScheme.primary,
                  colorScheme.primary.withValues(alpha: 0.12),
                ),
              };

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < displayTasks.length - 1 ? 10.h : 0,
                ),
                child: _ActiveWorkItem(
                  task: task,
                  status: statusText,
                  statusColor: statusColor,
                  statusChipColor: chipColor,
                ),
              );
            }),
          ],
        );
      },
      loading: () => const _ActiveWorkShimmer(),
      error: (e, st) => const SizedBox.shrink(),
    );
  }
}

class _ActiveWorkItem extends ConsumerWidget {
  final TaskLite task;
  final String status;
  final Color statusColor;
  final Color statusChipColor;

  const _ActiveWorkItem({
    required this.task,
    required this.status,
    required this.statusColor,
    required this.statusChipColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final priceStr =
        task.customerTotalPrice?.toNaira(2) ?? task.basePrice?.toNaira(2);

    final categoryName = task.category?.name;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (task.id != null) {
            context.pushNamed(
              RouteNames.taskDetail.name,
              pathParameters: {'taskId': task.id!},
            );
          }
        },
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: isDark ? 0.10 : 0.05),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: isDark ? 0.18 : 0.10),
            ),
          ),
          child: Row(
            children: [
              // Left Icon Badge
              Container(
                width: 40.r,
                height: 40.r,
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
              SizedBox(width: 12.w),

              // Task Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      task.title ?? 'Task',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: colorScheme.onSurface,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        // Status Chip
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: statusChipColor,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            status,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: statusColor,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (categoryName != null) ...[
                          SizedBox(width: 6.w),
                          Text(
                            '•',
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 10.sp,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              categoryName,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // Right side Price & Chevron
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (priceStr != null)
                    Text(
                      priceStr,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveWorkShimmer extends StatelessWidget {
  const _ActiveWorkShimmer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseColor = colorScheme.onSurface.withValues(alpha: 0.06);
    final highlightColor = colorScheme.onSurface.withValues(alpha: 0.15);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Work',
          style: AppTextStyles.heading3.copyWith(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 14.h),
        Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            width: double.infinity,
            height: 64.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
      ],
    );
  }
}

class _PopularCategoriesShimmer extends StatelessWidget {
  const _PopularCategoriesShimmer();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = colorScheme.onSurface.withValues(alpha: 0.06);
    final highlightColor = colorScheme.onSurface.withValues(alpha: 0.15);
    final cardBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 2.4,
        ),
        itemCount: 4,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.08),
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              child: Row(
                children: [
                  Container(
                    width: 24.sp,
                    height: 24.sp,
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 12.sp,
                          decoration: BoxDecoration(
                            color: colorScheme.onSurface.withValues(alpha: 0.1),
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
        },
      ),
    );
  }
}
