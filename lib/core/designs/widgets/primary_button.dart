import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Gradient? gradient;
  final double? height;
  final EdgeInsetsGeometry? margin;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
    this.height,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bg = backgroundColor ?? colorScheme.primary;
    final fg = foregroundColor ?? colorScheme.onPrimary;
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: SizedBox(
        width: double.infinity,
        height: height ?? 52.h,
        child: FilledButton(
          onPressed: isLoading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: bg,
            foregroundColor: fg,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28.r),
            ),
          ),
          child: isLoading
              ? SizedBox(
                  height: 24.h,
                  width: 24.h,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      IconTheme(
                        data: IconThemeData(color: fg, size: 24.sp),
                        child: icon!,
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Text(
                      text,
                      style: GoogleFonts.inter(
                        color: fg,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
