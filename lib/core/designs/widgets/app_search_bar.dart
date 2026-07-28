import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:seeker_app/core/designs/app_colors.dart';

class AppSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color? backgroundColor;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? contentPadding;
  final double? height;
  final double? borderRadius;
  final VoidCallback? onTap;
  final bool readOnly;
  final bool autofocus;
  final FocusNode? focusNode;

  const AppSearchBar({
    super.key,
    this.controller,
    this.onChanged,
    this.hintText = 'Search...',
    this.prefixIcon,
    this.suffixIcon,
    this.backgroundColor,
    this.borderColor,
    this.padding,
    this.contentPadding,
    this.height,
    this.borderRadius,
    this.onTap,
    this.readOnly = false,
    this.autofocus = false,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      child: Container(
        height: height ?? 48.h,
        decoration: BoxDecoration(
          color: backgroundColor ?? (isDark ? AppColors.darkerBackground : Colors.white),
          borderRadius: BorderRadius.circular(borderRadius ?? 16.r),
          border: Border.all(
            color: borderColor ?? (isDark ? Colors.white12 : Colors.grey.shade200),
            width: 1,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          onTap: onTap,
          readOnly: readOnly,
          autofocus: autofocus,
          focusNode: focusNode,
          style: TextStyle(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontSize: 14.sp,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDark ? Colors.white54 : AppColors.textSecondary,
              fontSize: 14.sp,
            ),
            prefixIcon: prefixIcon ?? Padding(
              padding: EdgeInsets.all(12.r),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedSearch01,
                color: isDark ? Colors.white54 : AppColors.textSecondary,
                size: 20.sp,
              ),
            ),
            suffixIcon: suffixIcon,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: contentPadding ?? EdgeInsets.symmetric(
              vertical: 14.h,
              horizontal: 16.w,
            ),
          ),
        ),
      ),
    );
  }
}
