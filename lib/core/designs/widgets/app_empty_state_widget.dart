import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';

/// A visually appealing, theme-aware empty state widget.
///
/// Displays a centered illustration area with an icon, a title, an optional
/// subtitle, and an optional action button. Automatically adapts to light/dark
/// mode and is highly customizable.
class AppEmptyStateWidget extends StatelessWidget {
  /// The primary icon displayed in the illustration circle.
  final IconData icon;

  /// Main heading text.
  final String title;

  /// Optional description shown below the title.
  final String? subtitle;

  /// Label for the optional action button. If null, no button is shown.
  final String? actionLabel;

  /// Callback when the action button is tapped.
  final VoidCallback? onAction;

  /// Accent color used for the icon tint, the illustration background, and the
  /// action button. Defaults to [AppColors.primary].
  final Color? accentColor;

  /// Override icon size. Defaults to 40.
  final double? iconSize;

  /// Whether to compact the widget (smaller paddings & font sizes).
  final bool compact;

  const AppEmptyStateWidget({
    super.key,
    this.icon = Icons.inbox_rounded,
    this.title = 'Nothing here yet',
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.accentColor,
    this.iconSize,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? AppColors.primary;
    final effectiveIconSize = iconSize ?? (compact ? 32.0 : 40.0);
    final circleDiameter = compact ? 72.0 : 96.0;

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 24.w : 32.w,
          vertical: compact ? 16.h : 32.h,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Illustration ──────────────────────────────────────────
            Container(
              width: circleDiameter.w,
              height: circleDiameter.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: isDark ? 0.18 : 0.12),
                    accent.withValues(alpha: isDark ? 0.06 : 0.03),
                  ],
                ),
                border: Border.all(
                  color: accent.withValues(alpha: isDark ? 0.12 : 0.08),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: effectiveIconSize.sp,
                  color: accent.withValues(alpha: 0.7),
                ),
              ),
            ),

            SizedBox(height: compact ? 16.h : 24.h),

            // ── Title ─────────────────────────────────────────────────
            Text(
              title,
              textAlign: TextAlign.center,
              style: (compact ? AppTextStyles.bodyLarge : AppTextStyles.heading3)
                  .copyWith(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),

            // ── Subtitle ──────────────────────────────────────────────
            if (subtitle != null) ...[
              SizedBox(height: compact ? 6.h : 8.h),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],

            // ── Action Button ─────────────────────────────────────────
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: compact ? 16.h : 24.h),
              FilledButton.tonal(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: accent.withValues(alpha: isDark ? 0.15 : 0.1),
                  foregroundColor: accent,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
