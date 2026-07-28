import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  final String? hintText;
  final IconData? leadingIcon;
  final Widget? prefixIconWidget;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    this.hintText,
    this.leadingIcon,
    this.prefixIconWidget,
    this.isPassword = false,
    this.controller,
    this.keyboardType,
    this.suffix,
    this.readOnly = false,
    this.onTap,
    this.validator,
    this.inputFormatters,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24.r),
      borderSide: BorderSide(
        color: colorScheme.onSurface.withValues(alpha: 0.1),
        width: 1,
      ),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24.r),
      borderSide: BorderSide(
        color: colorScheme.onSurface.withValues(alpha: 0.3),
        width: 1,
      ),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24.r),
      borderSide: BorderSide(
        color: colorScheme.error,
        width: 1,
      ),
    );

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      validator: widget.validator,
      style: GoogleFonts.inter(color: colorScheme.onSurface, fontSize: 14.sp),
      decoration: InputDecoration(
        fillColor: colorScheme.onSurface.withValues(alpha: 0.05),
        filled: true,
        hintText: widget.hintText,
        hintStyle: GoogleFonts.inter(
          color: colorScheme.onSurface.withValues(alpha: 0.5),
          fontSize: 14.sp,
        ),
        prefixIcon: widget.prefixIconWidget ??
            (widget.leadingIcon != null
                ? Icon(
                    widget.leadingIcon,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    size: 20.sp,
                  )
                : null),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 20.sp,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : widget.suffix,
        border: border,
        enabledBorder: border,
        focusedBorder: focusedBorder,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      ),
    );
  }
}
