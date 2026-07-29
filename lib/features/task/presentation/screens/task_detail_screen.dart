import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:seeker_app/core/designs/designs.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import 'package:shimmer/shimmer.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/task_providers.dart';
import 'package:seeker_app/core/utils/num_extension.dart';
import 'package:seeker_app/core/designs/widgets/confirm_task_sheet.dart';
import '../widgets/task_detail_options_sheet.dart';

class TaskDetailScreen extends ConsumerWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final taskAsync = ref.watch(taskDetailProvider(taskId));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: taskAsync.when(
        data: (task) => _TaskDetailContent(task: task),
        loading: () => const _TaskDetailShimmerLoading(),
        error: (error, stack) =>
            _TaskDetailErrorState(taskId: taskId, error: error),
      ),
      bottomNavigationBar: taskAsync.whenOrNull(
        data: (task) => _BottomActionBar(task: task),
        loading: () => const _BottomShimmerBar(),
      ),
    );
  }
}

class _TaskDetailContent extends StatelessWidget {
  final Task task;

  const _TaskDetailContent({required this.task});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final imageAttachments =
        task.attachments?.where((att) {
          final mime = att.mimeType?.toLowerCase() ?? '';
          final url = att.url?.toLowerCase() ?? '';
          return mime.startsWith('image/') ||
              url.endsWith('.jpg') ||
              url.endsWith('.jpeg') ||
              url.endsWith('.png') ||
              url.endsWith('.webp') ||
              att.type == 'image';
        }).toList() ??
        [];

    final hasHeroImage =
        imageAttachments.isNotEmpty && imageAttachments.first.url != null;
    final heroImageUrl = hasHeroImage ? imageAttachments.first.url : null;

    final dateStr = task.scheduledStartAt != null
        ? DateFormat('EEE, MMM d, yyyy • h:mm a').format(task.scheduledStartAt!)
        : 'Flexible Start Time';

    final priceStr = task.customerTotalPrice != null
        ? task.customerTotalPrice!.toNaira(2)
        : (task.basePrice != null ? task.basePrice!.toNaira(2) : 'TBD');

    final primaryLocation = task.locations?.firstWhere(
      (loc) =>
          (loc.address != null && loc.address!.trim().isNotEmpty) ||
          (loc.city != null && loc.city!.trim().isNotEmpty),
      orElse: () => TaskLocation(),
    );

    String locationStr = 'Location not specified';
    if (primaryLocation != null) {
      final addr = primaryLocation.address?.trim() ?? '';
      final city = primaryLocation.city?.trim() ?? '';
      final state = primaryLocation.state?.trim() ?? '';

      final cityState = [
        if (city.isNotEmpty) city,
        if (state.isNotEmpty) state,
      ].join(', ');

      if (addr.isNotEmpty && cityState.isNotEmpty) {
        if (!addr.toLowerCase().contains(city.toLowerCase())) {
          locationStr = '$addr, $cityState';
        } else {
          locationStr = addr;
        }
      } else if (addr.isNotEmpty) {
        locationStr = addr;
      } else if (cityState.isNotEmpty) {
        locationStr = cityState;
      }
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300.h,
          pinned: true,
          elevation: 0,
          backgroundColor: colorScheme.surface,
          leading: Padding(
            padding: EdgeInsets.all(8.r),
            child: CustomBackButton(),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(top: 8.h, bottom: 8.h),
              child: _StatusPill(status: task.status ?? 'open'),
            ),
            Padding(
              padding: EdgeInsets.only(right: 12.w, top: 8.h, bottom: 8.h),
              child: CircleAvatar(
                backgroundColor: colorScheme.surface.withValues(alpha: 0.85),
                child: IconButton(
                  icon: HugeIcon(
                    icon: HugeIcons.strokeRoundedMoreVertical,
                    color: colorScheme.onSurface,
                    size: 20.sp,
                  ),
                  onPressed: () {
                    TaskDetailOptionsSheet.show(context, task: task);
                  },
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (hasHeroImage)
                  Image.network(
                    heroImageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const _HeroFallback(),
                  )
                else
                  const _HeroFallback(),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            transform: Matrix4.translationValues(0, -20.h, 0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.6,
                        ),
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        priceStr,
                        style: textTheme.headlineMedium?.copyWith(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    task.title ?? 'Task Details',
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  if (task.description != null &&
                      task.description!.isNotEmpty) ...[
                    Text(
                      task.description!,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 14.sp,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                  Text(
                    'Task Details',
                    style: textTheme.titleMedium?.copyWith(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  _InfoOptionCard(
                    title: 'Scheduled Time',
                    subtitle: dateStr,
                    icon: HugeIcons.strokeRoundedCalendar01,
                  ),
                  SizedBox(height: 10.h),
                  _InfoOptionCard(
                    title: 'Location',
                    subtitle: locationStr,
                    icon: HugeIcons.strokeRoundedLocation01,
                  ),
                  SizedBox(height: 24.h),
                  _PriceBreakdownCard(task: task),
                  SizedBox(height: 24.h),
                  _AttachmentsSection(attachments: task.attachments ?? []),
                  if (task.assignment != null) ...[
                    SizedBox(height: 24.h),
                    _AssignmentCard(assignment: task.assignment!),
                  ],
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroFallback extends StatelessWidget {
  const _HeroFallback();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppColors.darkerBackground,
                  colorScheme.surfaceContainerHighest,
                ]
              : [
                  colorScheme.primaryContainer,
                  colorScheme.surfaceContainerHighest,
                ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedTask01,
                color: colorScheme.primary,
                size: 54.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Color badgeColor;
    Color textColor;

    switch (status.toLowerCase()) {
      case 'draft':
        badgeColor = Colors.grey.shade800;
        textColor = Colors.white;
        break;
      case 'open':
        badgeColor = AppColors.primary;
        textColor = Colors.white;
        break;
      case 'matched':
        badgeColor = Colors.amber.shade700;
        textColor = Colors.white;
        break;
      case 'in progress':
      case 'inprogress':
        badgeColor = Colors.purple.shade600;
        textColor = Colors.white;
        break;
      case 'completed':
        badgeColor = Colors.green.shade600;
        textColor = Colors.white;
        break;
      case 'cancelled':
        badgeColor = Colors.red.shade600;
        textColor = Colors.white;
        break;
      default:
        badgeColor = colorScheme.onSurface;
        textColor = colorScheme.surface;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _InfoOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final dynamic icon;

  const _InfoOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              HugeIcon(icon: icon, color: colorScheme.primary, size: 16.sp),
              SizedBox(width: 6.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceBreakdownCard extends StatelessWidget {
  final Task task;

  const _PriceBreakdownCard({required this.task});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalPriceStr = task.customerTotalPrice != null
        ? task.customerTotalPrice!.toNaira(2)
        : (task.basePrice != null ? task.basePrice!.toNaira(2) : 'TBD');

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.2)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Price',
            style: textTheme.titleMedium?.copyWith(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            totalPriceStr,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AttachmentsSection extends StatelessWidget {
  final List<TaskAttachment> attachments;

  const _AttachmentsSection({required this.attachments});

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16.w),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: Image.network(imageUrl, fit: BoxFit.contain),
            ),
            Padding(
              padding: EdgeInsets.all(8.r),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.7),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Attachments (${attachments.length})',
              style: textTheme.titleMedium?.copyWith(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            if (attachments.isNotEmpty)
              Text(
                'Tap image to expand',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 11.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        SizedBox(height: 10.h),
        if (attachments.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20.h),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.15)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              ),
            ),
            child: Center(
              child: Text(
                'No attachment images uploaded',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 110.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: attachments.length,
              itemBuilder: (context, index) {
                final item = attachments[index];
                final url = item.url;
                final isImage =
                    item.mimeType?.startsWith('image/') == true ||
                    item.type == 'image' ||
                    (url != null &&
                        (url.endsWith('.jpg') ||
                            url.endsWith('.png') ||
                            url.endsWith('.jpeg') ||
                            url.endsWith('.webp')));

                return GestureDetector(
                  onTap: () {
                    if (isImage && url != null) {
                      _showImageDialog(context, url);
                    }
                  },
                  child: Container(
                    width: 110.w,
                    margin: EdgeInsets.only(right: 12.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: colorScheme.outlineVariant.withValues(
                          alpha: 0.4,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: isImage && url != null
                        ? Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                url,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stack) => Center(
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedImage01,
                                    color: colorScheme.onSurfaceVariant,
                                    size: 28.sp,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 6.w,
                                bottom: 6.h,
                                child: Container(
                                  padding: EdgeInsets.all(4.r),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedView,
                                    color: Colors.white,
                                    size: 14.sp,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              HugeIcon(
                                icon: HugeIcons.strokeRoundedFile01,
                                color: colorScheme.primary,
                                size: 28.sp,
                              ),
                              SizedBox(height: 6.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6.w),
                                child: Text(
                                  item.fileName ?? 'File',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final Assignment assignment;

  const _AssignmentCard({required this.assignment});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            radius: 20.r,
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedUser,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Task Provider Assigned',
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  assignment.status != null
                      ? 'Status: ${assignment.status}'
                      : 'Provider is active on this task',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomActionBar extends ConsumerWidget {
  final Task task;

  const _BottomActionBar({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final status = task.status?.toLowerCase() ?? 'open';
    String actionText = 'Back to Tasks';

    if (status == 'draft') {
      actionText = 'Confirm Task Order';
    } else if (status == 'open') {
      actionText = 'Searching Provider...';
    } else if (status == 'matched' || status == 'in progress') {
      actionText = 'Track Progress';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 48.h,
          child: ElevatedButton(
            onPressed: () {
              if (status == 'draft') {
                if (task.id != null) {
                  ConfirmTaskSheet.show(context, task.id!);
                }
              } else if (status == 'open') {
                context.pushNamed(
                  RouteNames.taskMatching.name,
                  pathParameters: {if (task.id != null) 'taskId': task.id!},
                  queryParameters: {if (task.id != null) 'taskId': task.id!},
                );
              } else {
                context.pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              shadowColor: AppColors.primary.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  actionText,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(width: 6.w),
                HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowRight01,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskDetailShimmerLoading extends StatelessWidget {
  const _TaskDetailShimmerLoading();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return SingleChildScrollView(
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          children: [
            Container(
              height: 280.h,
              width: double.infinity,
              color: Colors.white,
            ),
            Container(
              transform: Matrix4.translationValues(0, -20.h, 0),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 140.w,
                        height: 26.h,
                        color: Colors.white,
                      ),
                      Container(width: 80.w, height: 20.h, color: Colors.white),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(width: 220.w, height: 22.h, color: Colors.white),
                  SizedBox(height: 12.h),
                  Container(
                    width: double.infinity,
                    height: 14.h,
                    color: Colors.white,
                  ),
                  SizedBox(height: 6.h),
                  Container(width: 260.w, height: 14.h, color: Colors.white),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 70.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Container(
                          height: 70.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Container(
                    height: 120.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Container(width: 120.w, height: 16.h, color: Colors.white),
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 100.h,
                    child: Row(
                      children: [
                        Container(
                          width: 100.w,
                          height: 100.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Container(
                          width: 100.w,
                          height: 100.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomShimmerBar extends StatelessWidget {
  const _BottomShimmerBar();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
      color: colorScheme.surface,
      child: SafeArea(
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            height: 52.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26.r),
            ),
          ),
        ),
      ),
    );
  }
}

class _TaskDetailErrorState extends ConsumerWidget {
  final String taskId;
  final Object error;

  const _TaskDetailErrorState({required this.taskId, required this.error});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedAlert01,
                color: colorScheme.error,
                size: 48.sp,
              ),
              SizedBox(height: 16.h),
              Text(
                'Unable to load task details',
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(taskDetailProvider(taskId));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 12.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
