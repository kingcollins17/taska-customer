import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;

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
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: colorScheme.onSurface.withValues(alpha: 0.08),
          child: Icon(
            Icons.person,
            color: colorScheme.onSurface,
            size: 24.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isNotEmpty ? name : 'Guest',
                style: GoogleFonts.inter(
                  color: colorScheme.onSurface,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                greeting,
                style: GoogleFonts.inter(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
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
              border: Border.all(
                color: colorScheme.onSurface.withValues(alpha: 0.15),
              ),
            ),
            child: badges.Badge(
              showBadge: unreadCount > 0,
              badgeStyle: badges.BadgeStyle(badgeColor: colorScheme.primary),
              badgeContent: Text(
                unreadCount > 99 ? '99+' : unreadCount.toString(),
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Icon(
                Icons.notifications_none_outlined,
                color: colorScheme.onSurface,
                size: 20.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
