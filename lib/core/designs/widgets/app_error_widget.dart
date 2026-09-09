import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/utils/error_handler.dart';

/// A visually appealing, theme-aware error state widget.
///
/// Converts any raw error into a user-friendly message via
/// [FriendlyErrorMessageExtension.toFriendlyMessage] so that verbose stack
/// traces, DioExceptions, and other internals are never shown to users.
///
/// Features a soft-red tinted illustration circle, a title, the friendly
/// message, and an optional retry button. Adapts to light/dark mode.
class AppErrorWidget extends StatelessWidget {
  /// The raw error object. Its `.toFriendlyMessage()` will be shown.
  /// If null, a generic fallback message is used.
  final Object? error;

  /// Heading text. Defaults to a friendly generic title.
  final String title;

  /// Override the auto-generated message entirely. When set, [error] is
  /// ignored for display purposes.
  final String? messageOverride;

  /// Label for the retry button. Defaults to `'Try Again'`.
  /// Set to null to hide the button.
  final String? retryLabel;

  /// Callback when the retry button is tapped.
  final VoidCallback? onRetry;

  /// Primary icon displayed in the illustration. Defaults to a rounded
  /// warning icon.
  final IconData icon;

  /// Accent color for the error illustration. Defaults to a soft red.
  final Color? accentColor;

  /// Override icon size. Defaults to 36.
  final double? iconSize;

  /// Whether to render in compact mode (smaller paddings & fonts).
  final bool compact;

  const AppErrorWidget({
    super.key,
    this.error,
    this.title = 'Something went wrong',
    this.messageOverride,
    this.retryLabel = 'Try Again',
    this.onRetry,
    this.icon = Icons.warning_amber_rounded,
    this.accentColor,
    this.iconSize,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = accentColor ?? const Color(0xFFE53935); // soft red
    final effectiveIconSize = iconSize ?? (compact ? 28.0 : 36.0);
    final circleDiameter = compact ? 64.0 : 88.0;

    final message = messageOverride ?? error.toFriendlyMessage();

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
                    accent.withValues(alpha: isDark ? 0.20 : 0.12),
                    accent.withValues(alpha: isDark ? 0.06 : 0.03),
                  ],
                ),
                border: Border.all(
                  color: accent.withValues(alpha: isDark ? 0.15 : 0.10),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: effectiveIconSize.sp,
                  color: accent.withValues(alpha: 0.8),
                ),
              ),
            ),

            SizedBox(height: compact ? 14.h : 20.h),

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

            SizedBox(height: compact ? 4.h : 8.h),

            // ── Friendly Message ──────────────────────────────────────
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : AppColors.textSecondary,
                height: 1.45,
              ),
            ),

            // ── Retry Button ──────────────────────────────────────────
            if (retryLabel != null && onRetry != null) ...[
              SizedBox(height: compact ? 16.h : 24.h),
              FilledButton.icon(
                onPressed: onRetry,
                style: FilledButton.styleFrom(
                  backgroundColor: accent.withValues(alpha: isDark ? 0.18 : 0.1),
                  foregroundColor: accent,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                icon: Icon(Icons.refresh_rounded, size: 18.sp),
                label: Text(
                  retryLabel!,
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
