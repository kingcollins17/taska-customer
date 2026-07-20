import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    
    return Row(
      children: [
        FilterChip(
          label: const Text('All'),
          selected: !showUnreadOnly,
          onSelected: (_) => onFilterChanged(false),
          backgroundColor: theme.scaffoldBackgroundColor,
          selectedColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          labelStyle: TextStyle(
            color: !showUnreadOnly ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            fontWeight: !showUnreadOnly ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
            side: BorderSide(
              color: !showUnreadOnly ? theme.colorScheme.primary : theme.dividerColor,
            )
          ),
          showCheckmark: false,
        ),
        SizedBox(width: 8.w),
        FilterChip(
          label: const Text('Unread'),
          selected: showUnreadOnly,
          onSelected: (_) => onFilterChanged(true),
          backgroundColor: theme.scaffoldBackgroundColor,
          selectedColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          labelStyle: TextStyle(
            color: showUnreadOnly ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            fontWeight: showUnreadOnly ? FontWeight.bold : FontWeight.normal,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
            side: BorderSide(
              color: showUnreadOnly ? theme.colorScheme.primary : theme.dividerColor,
            )
          ),
          showCheckmark: false,
        ),
        const Spacer(),
        TextButton(
          onPressed: onMarkAllRead,
          child: Text(
            'Mark all as read',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
