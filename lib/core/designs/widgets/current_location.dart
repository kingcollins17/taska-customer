import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/providers/location_provider.dart';
import 'package:shimmer/shimmer.dart';

class CurrentLocation extends ConsumerWidget {
  const CurrentLocation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    final isLive = ref.watch(useLiveLocationProvider);
    final locationAsync = ref.watch(locationProvider);

    void toggleLocationMode() {
      final newLive = !isLive;
      ref.read(useLiveLocationProvider.notifier).state = newLive;
      ref.invalidate(locationProvider);
      context.showToast(
        newLive ? 'Switched to Live Location' : 'Switched to Mock Location',
        type: newLive ? MessageType.success : MessageType.info,
        icon: newLive ? Icons.my_location_rounded : Icons.location_on_outlined,
      );
    }

    final iconData = isLive
        ? Icons.location_on_rounded
        : Icons.location_on_outlined;

    final iconColor = isLive
        ? AppColors.primary
        : textColor.withValues(alpha: 0.5);

    Widget content = locationAsync.when(
      data: (address) {
        final locationText = (address?.city != null && address?.state != null)
            ? '${address!.city}, ${address.state}'
            : (isLive ? 'Fetching Location...' : 'Location unavailable');

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              locationText,
              style: AppTextStyles.bodyMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              iconData,
              color: iconColor,
              size: 18.sp,
            ),
          ],
        );
      },
      loading: () => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Shimmer.fromColors(
            baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
            highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
            child: Container(
              width: 100.w,
              height: 14.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            iconData,
            color: iconColor,
            size: 18.sp,
          ),
        ],
      ),
      error: (_, __) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isLive ? 'Live Location Error' : 'Location unavailable',
            style: AppTextStyles.bodyMedium.copyWith(
              color: textColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(
            iconData,
            color: iconColor,
            size: 18.sp,
          ),
        ],
      ),
    );

    return GestureDetector(
      onLongPress: toggleLocationMode,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.only(right: 16.w),
        child: content,
      ),
    );
  }
}
