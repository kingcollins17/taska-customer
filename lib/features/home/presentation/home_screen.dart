import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker_app/core/providers/user_provider.dart';
import 'package:seeker_app/core/providers/notification_providers.dart';
import 'package:seeker_app/core/providers/websocket_provider.dart';
import 'package:seeker_app/core/services/device_tray.dart';
import 'package:seeker_app/core/providers/task_providers.dart';
import 'package:seeker_app/core/providers/services_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'widgets/home_app_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            try {
              await Future.wait([
                ref.refresh(userProvider.future),
                ref.refresh(notificationCountsProvider.future),
                ref.refresh(allTasksAggregatedProvider.future),
                ref.refresh(topServicesProvider.future),
              ]);
            } catch (_) {}
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              left: 24.w,
              right: 24.w,
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
                SizedBox(height: 32.h),
                const _MainHero(),
                SizedBox(height: 32.h),
                const _ActiveWork(),
                SizedBox(height: 32.h),
                const _PopularCategories(),
                SizedBox(height: 32.h),
                const _RecentMessages(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MainHero extends StatelessWidget {
  const _MainHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What do you need help with today?',
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Post a task and get offers from nearby professionals.',
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.push('/task-creation/category');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(
                'Post a Task',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 16.sp,
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

class _ActiveWork extends ConsumerWidget {
  const _ActiveWork();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(allTasksAggregatedProvider);

    return tasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) return const SizedBox.shrink();

        final displayTasks = tasks.take(3).toList();
        final showSeeAll = tasks.length > 3;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Work',
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (showSeeAll)
                  TextButton(
                    onPressed: () {
                      context.go('/tasks');
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'See all',
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),
            ...displayTasks.asMap().entries.map((entry) {
              final index = entry.key;
              final task = entry.value;

              final (
                String statusText,
                Color statusColor,
              ) = switch (task.status) {
                'open' || 'bidding' => (
                  '${task.bidsCount ?? 0} ${task.bidsCount == 1 ? 'Bid' : 'Bids'}',
                  AppColors.primary,
                ),
                'in_progress' => ('In Progress', Colors.orangeAccent),
                'assigned' => (
                  task.scheduledStartAt != null
                      ? 'Provider arriving at ${DateFormat('h:mm a').format(task.scheduledStartAt!.toLocal())}'
                      : 'Booked: Provider arriving soon',
                  Colors.green,
                ),
                _ => ('Assigned', AppColors.primary),
              };

              return Padding(
                padding: EdgeInsets.only(
                  bottom: index < displayTasks.length - 1 ? 12.h : 0,
                ),
                child: _ActiveWorkItem(
                  title: task.title ?? 'N/A',
                  status: statusText,
                  statusColor: statusColor,
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

class _ActiveWorkItem extends StatelessWidget {
  final String title;
  final String status;
  final Color statusColor;

  const _ActiveWorkItem({
    required this.title,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Mock navigation to task details
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.handyman_outlined,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    status,
                    style: GoogleFonts.inter(
                      color: statusColor,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.3),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularCategories extends ConsumerWidget {
  const _PopularCategories();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topServicesAsync = ref.watch(topServicesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Popular Categories',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 16.h),
        topServicesAsync.when(
          data: (services) {
            final displayServices = services.take(6).toList();
            if (displayServices.isEmpty) return const SizedBox.shrink();

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.0,
              ),
              itemCount: displayServices.length,
              itemBuilder: (context, index) {
                final service = displayServices[index];
                return GestureDetector(
                  onTap: () {
                    context.push('/task-creation/category');
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (service.imageUrl != null)
                          CachedNetworkImage(
                            imageUrl: service.imageUrl!,
                            width: 28.sp,
                            height: 28.sp,
                            color: Colors.white,
                            errorWidget: (context, url, error) => Icon(
                              Icons.category_outlined,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                            placeholder: (context, url) => SizedBox(
                              width: 28.sp,
                              height: 28.sp,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          )
                        else
                          Icon(
                            Icons.category_outlined,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                        SizedBox(height: 8.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            service.name ?? '',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
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

class _RecentMessages extends StatelessWidget {
  const _RecentMessages();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Messages',
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'View all',
              style: GoogleFonts.inter(
                color: AppColors.primary,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        const _MessageItem(name: 'Sarah', message: 'I\'m on my way.'),
        SizedBox(height: 12.h),
        const _MessageItem(
          name: 'James',
          message: 'Can you send a photo of the sink?',
        ),
      ],
    );
  }
}

class _MessageItem extends StatelessWidget {
  final String name;
  final String message;

  const _MessageItem({required this.name, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            child: Text(
              name[0],
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
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
                  style: GoogleFonts.inter(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  message,
                  style: GoogleFonts.inter(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13.sp,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveWorkShimmer extends StatelessWidget {
  const _ActiveWorkShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Active Work',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 16.h),
        Shimmer.fromColors(
          baseColor: Colors.white.withValues(alpha: 0.05),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Column(
            children: [
              _buildShimmerItem(),
              SizedBox(height: 12.h),
              _buildShimmerItem(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerItem() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 100.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          Container(
            width: 24.w,
            height: 24.w,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _PopularCategoriesShimmer extends StatelessWidget {
  const _PopularCategoriesShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.white.withValues(alpha: 0.05),
      highlightColor: Colors.white.withValues(alpha: 0.1),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 1.0,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28.sp,
                  height: 28.sp,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 48.w,
                  height: 12.sp,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
