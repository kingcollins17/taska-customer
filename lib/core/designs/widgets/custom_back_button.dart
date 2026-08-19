import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? margin;
  final Offset? offset;

  const CustomBackButton({
    super.key,
    this.onPressed,
    this.margin,
    this.offset,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Widget child = Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.onSurface.withValues(alpha: 0.05),
      ),
      child: IconButton(
        padding: EdgeInsets.all(10.w),
        constraints: const BoxConstraints(),
        icon: Icon(Icons.arrow_back_ios_new, color: colorScheme.onSurface),
        iconSize: 18.sp,
        onPressed:
            onPressed ??
            () {
              if (context.canPop()) {
                context.pop();
              }
            },
      ),
    );

    if (offset != null) {
      return Transform.translate(
        offset: offset!,
        child: child,
      );
    }

    return child;
  }
}
