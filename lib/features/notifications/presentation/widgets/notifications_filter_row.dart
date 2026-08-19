import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';

class NotificationsFilterRow extends StatelessWidget {
  final bool showUnreadOnly;
  final ValueChanged<bool> onFilterChanged;
  final VoidCallback onMarkAllRead;

  const NotificationsFilterRow({
    super.key,
    required this.showUnreadOnly,
    required this.onFilterChanged,
    required this.onMarkAllRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: !showUnreadOnly,
          onSelected: (_) => onFilterChanged(false),
          backgroundColor: isDark ? AppColors.darkerBackground : Colors.white,
          selectedColor: AppColors.primary,
          labelStyle: AppTextStyles.bodySmall.copyWith(
            fontSize: 12.sp,
            color: !showUnreadOnly
                ? Colors.white
                : (isDark ? Colors.white70 : AppColors.textPrimary),
            fontWeight: !showUnreadOnly ? FontWeight.w600 : FontWeight.normal,
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(
              color: !showUnreadOnly
                  ? AppColors.primary
                  : (isDark ? Colors.white24 : Colors.grey.shade300),
            ),
          ),
          showCheckmark: false,
        ),
        SizedBox(width: 6.w),
        ChoiceChip(
          label: const Text('Unread'),
          selected: showUnreadOnly,
          onSelected: (_) => onFilterChanged(true),
          backgroundColor: isDark ? AppColors.darkerBackground : Colors.white,
          selectedColor: AppColors.primary,
          labelStyle: AppTextStyles.bodySmall.copyWith(
            fontSize: 12.sp,
            color: showUnreadOnly
                ? Colors.white
                : (isDark ? Colors.white70 : AppColors.textPrimary),
            fontWeight: showUnreadOnly ? FontWeight.w600 : FontWeight.normal,
          ),
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          visualDensity: VisualDensity.compact,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
            side: BorderSide(
              color: showUnreadOnly
                  ? AppColors.primary
                  : (isDark ? Colors.white24 : Colors.grey.shade300),
            ),
          ),
          showCheckmark: false,
        ),
        const Spacer(),
        TextButton(
          onPressed: onMarkAllRead,
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'Mark all as read',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
