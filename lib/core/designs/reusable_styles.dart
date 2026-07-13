import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

class ReusableStyles {
  ReusableStyles._();

  static final BorderRadius defaultBorderRadius = BorderRadius.circular(12.r);
  
  static final EdgeInsets defaultPadding = EdgeInsets.all(16.w);
  static final EdgeInsets defaultPaddingHorizontal = EdgeInsets.symmetric(horizontal: 16.w);
  static final EdgeInsets defaultPaddingVertical = EdgeInsets.symmetric(vertical: 16.h);

  static final BoxDecoration cardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: defaultBorderRadius,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10.r,
        offset: const Offset(0, 4),
      ),
    ],
  );
}
