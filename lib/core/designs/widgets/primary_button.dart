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

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final bg = backgroundColor ?? colorScheme.primary;
    final fg = foregroundColor ?? colorScheme.onPrimary;

    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        color: gradient == null ? bg : null,
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: bg.withValues(alpha: 0.2),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: fg.withValues(alpha: 0.5),
        ),
        child: isLoading
            ? SizedBox(
                height: 24.h,
                width: 24.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: fg,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    // You may need to tint the icon if it's not a pre-tinted widget
                    // But if it's an Icon widget it inherits the IconTheme, so let's wrap it
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
    );
  }
}
