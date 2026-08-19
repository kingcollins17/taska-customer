import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';

class NotificationGroupHeader extends StatelessWidget {
  final String title;

  const NotificationGroupHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(top: 14.h, bottom: 6.h, left: 2.w),
      child: Text(
        title,
        style: AppTextStyles.heading3.copyWith(
          fontSize: 13.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white70 : AppColors.textPrimary,
        ),
      ),
    );
  }
}
