import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker_app/core/providers/user_provider.dart';
import 'package:seeker_app/core/providers/notification_providers.dart';
import 'package:seeker_app/core/providers/websocket_provider.dart';
import 'package:seeker_app/core/services/device_tray.dart';
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
        child: SingleChildScrollView(
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

class _ActiveWork extends StatelessWidget {
  const _ActiveWork();

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
        const _ActiveWorkItem(
          title: 'Fix leaking kitchen sink',
          status: '3 offers',
          statusColor: AppColors.primary,
        ),
        SizedBox(height: 12.h),
        const _ActiveWorkItem(
          title: 'Apartment cleaning',
          status: 'In Progress',
          statusColor: Colors.orangeAccent,
        ),
        SizedBox(height: 12.h),
        const _ActiveWorkItem(
          title: 'Generator repair',
          status: 'Provider arriving at 2:00 PM',
          statusColor: Colors.green,
        ),
      ],
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

class _PopularCategories extends StatelessWidget {
  const _PopularCategories();

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'icon': Icons.plumbing, 'label': 'Plumbing'},
      {'icon': Icons.cleaning_services, 'label': 'Cleaning'},
      {'icon': Icons.electrical_services, 'label': 'Electrical'},
      {'icon': Icons.local_shipping, 'label': 'Moving'},
      {'icon': Icons.face_retouching_natural, 'label': 'Beauty'},
      {'icon': Icons.delivery_dining, 'label': 'Delivery'},
    ];

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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.0,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
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
                    Icon(
                      category['icon'] as IconData,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      category['label'] as String,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
