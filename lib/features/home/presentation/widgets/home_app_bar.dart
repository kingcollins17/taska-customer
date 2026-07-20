import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import 'package:seeker_app/core/designs/app_colors.dart';

class HomeAppBar extends StatelessWidget {
  final String name;
  final String greeting;
  final int unreadCount;

  const HomeAppBar({
    super.key,
    required this.name,
    required this.greeting,
    required this.unreadCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: Colors.white.withValues(alpha: 0.1),
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: 24.sp,
          ), // Placeholder for image
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isNotEmpty ? name : 'Guest',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                greeting,
                style: GoogleFonts.inter(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            context.push('/notifications');
          },
          child: Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            child: badges.Badge(
              showBadge: unreadCount > 0,
              badgeStyle: badges.BadgeStyle(badgeColor: AppColors.primary),
              badgeContent: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: TextStyle(color: Colors.white, fontSize: 10.sp),
              ),
              child: Icon(
                Icons.notifications_none_outlined,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
