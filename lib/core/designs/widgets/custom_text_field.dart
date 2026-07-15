import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  final String? hintText;
  final IconData? leadingIcon;
  final bool isPassword;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?)? validator;

  const CustomTextField({
    super.key,
    this.hintText,
    this.leadingIcon,
    this.isPassword = false,
    this.controller,
    this.keyboardType,
    this.suffix,
    this.readOnly = false,
    this.onTap,
    this.validator,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24.r),
      borderSide: BorderSide(
        color: Colors.white.withValues(alpha: 0.1),
        width: 1,
      ),
    );

    final errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(24.r),
      borderSide: BorderSide(
        color: Theme.of(context).colorScheme.error,
        width: 1,
      ),
    );

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : false,
      keyboardType: widget.keyboardType,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      validator: widget.validator,
      style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp),
      decoration: InputDecoration(
        fillColor: const Color(0xFF1E1E1E),
        filled: true,
        hintText: widget.hintText,
        hintStyle: GoogleFonts.inter(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 14.sp,
        ),
        prefixIcon: widget.leadingIcon != null
            ? Icon(
                widget.leadingIcon,
                color: Colors.white.withValues(alpha: 0.5),
                size: 20.sp,
              )
            : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white.withValues(alpha: 0.5),
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
        focusedBorder: border,
        errorBorder: errorBorder,
        focusedErrorBorder: errorBorder,
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      ),
    );
  }
}
