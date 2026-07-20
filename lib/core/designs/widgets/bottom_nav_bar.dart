import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:hugeicons/hugeicons.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.surface;
    final activeColor = AppColors.primary;
    final inactiveColor = isDark ? Colors.white54 : AppColors.textSecondary;

    return Container(
      padding: EdgeInsets.only(
        top: 12.h,
        bottom: 24.h,
      ), // Extra padding for bottom safe area
      decoration: BoxDecoration(
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            0,
            HugeIcons.strokeRoundedHome01,
            HugeIcons.strokeRoundedHome01,
            'Home',
            activeColor,
            inactiveColor,
          ),
          _buildNavItem(
            1,
            HugeIcons.strokeRoundedTask01, // Trying Task01
            HugeIcons.strokeRoundedTask01,
            'Tasks',
            activeColor,
            inactiveColor,
          ),
          _buildNavItem(
            2,
            HugeIcons.strokeRoundedUser,
            HugeIcons.strokeRoundedUser,
            'Account',
            activeColor,
            inactiveColor,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    dynamic outlineIcon,
    dynamic filledIcon,
    String label,
    Color activeColor,
    Color inactiveColor,
  ) {
    final isActive = currentIndex == index;
    final color = isActive ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HugeIcon(
            icon: isActive ? filledIcon : outlineIcon,
            color: color,
            size: 24.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12.sp,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
