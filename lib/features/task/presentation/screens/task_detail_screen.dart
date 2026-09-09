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
import 'package:url_launcher/url_launcher.dart';
import '../widgets/task_detail_options_sheet.dart';

class TaskDetailScreen extends ConsumerWidget {
  final String taskId;

  const TaskDetailScreen({super.key, required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final taskAsync = ref.watch(taskDetailProvider(taskId));
    final fabAllowedStatus = ['draft', 'open', 'searching'];
    final shouldShouldFab =
        taskAsync.hasValue &&
        taskAsync.value != null &&
        fabAllowedStatus.any(
          (i) => i.contains(taskAsync.value?.status ?? 'N/A'),
        );
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: taskAsync.when(
        data: (task) => _TaskDetailContent(task: task),
        loading: () => const _TaskDetailShimmerLoading(),
        error: (error, stack) =>
            _TaskDetailErrorState(taskId: taskId, error: error),
      ),
      bottomNavigationBar: taskAsync.whenOrNull(
        data: (task) => shouldShouldFab
            ? _BottomActionBar(task: task)
            : const SizedBox.shrink(),
        loading: () => const _BottomShimmerBar(),
      ),
    );
  }
}

class _TaskDetailContent extends ConsumerWidget {
  final Task task;

  const _TaskDetailContent({required this.task});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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

    return RefreshIndicator(
      color: colorScheme.primary,
      onRefresh: () async {
        final id = task.id;
        if (id != null && id.isNotEmpty) {
          ref.invalidate(taskDetailProvider(id));
          ref.invalidate(taskAssignmentProvider(id));
          try {
            await Future.wait([
              ref.read(taskDetailProvider(id).future),
              ref.read(taskAssignmentProvider(id).future),
            ]);
          } catch (_) {}
        }
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 240.h,
            pinned: true,
            elevation: 0,
            backgroundColor: colorScheme.surface,
            leading: Padding(
              padding: EdgeInsets.all(8.r),
              child: const CustomBackButton(),
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
                      size: 18.sp,
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
                            Colors.black.withValues(alpha: 0.35),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.25),
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 36.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.2,
                          ),
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          priceStr,
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      task.title ?? 'Task Details',
                      style: textTheme.titleLarge?.copyWith(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                        height: 1.25,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    if (task.description != null &&
                        task.description!.isNotEmpty) ...[
                      Text(
                        task.description!,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 13.sp,
                          color: colorScheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      SizedBox(height: 14.h),
                    ],
                    if (task.status?.toLowerCase() == 'assigned') ...[
                      _TaskAssignmentDisplay(taskId: task.id ?? ''),
                      SizedBox(height: 14.h),
                    ],
                    Text(
                      'Task Details',
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoOptionCard(
                            title: 'Scheduled Time',
                            subtitle: dateStr,
                            icon: HugeIcons.strokeRoundedCalendar01,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: _InfoOptionCard(
                            title: 'Location',
                            subtitle: locationStr,
                            icon: HugeIcons.strokeRoundedLocation01,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    _PriceBreakdownCard(task: task),
                    SizedBox(height: 16.h),
                    _AttachmentsSection(attachments: task.attachments ?? []),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
                  colorScheme.primaryContainer.withValues(alpha: 0.5),
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedTask01,
                color: colorScheme.primary,
                size: 42.sp,
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
    final s = status.toLowerCase().replaceAll(' ', '_');

    final (
      String label,
      IconData iconData,
      Color badgeColor,
      Color textColor,
    ) = switch (s) {
      'draft' => (
        'Draft',
        Icons.edit_note_rounded,
        Colors.grey.shade800,
        Colors.white,
      ),
      'open' => (
        'Open',
        Icons.brightness_low_rounded,
        AppColors.primary,
        Colors.white,
      ),
      'searching' || 'pending' => (
        'Searching',
        Icons.radar_rounded,
        Colors.blue.shade700,
        Colors.white,
      ),
      'assigned' || 'matched' || 'booked' => (
        'Assigned',
        Icons.person_pin_circle_rounded,
        Colors.amber.shade800,
        Colors.white,
      ),
      'in_progress' || 'inprogress' => (
        'In Progress',
        Icons.play_circle_fill_rounded,
        Colors.purple.shade600,
        Colors.white,
      ),
      'completed' => (
        'Completed',
        Icons.check_circle_rounded,
        Colors.green.shade700,
        Colors.white,
      ),
      'cancelled' => (
        'Cancelled',
        Icons.cancel_rounded,
        Colors.red.shade700,
        Colors.white,
      ),
      'expired' => (
        'Expired',
        Icons.timer_off_rounded,
        Colors.deepOrange.shade700,
        Colors.white,
      ),
      _ => (
        s.replaceAll('_', ' ').toUpperCase(),
        Icons.info_outline_rounded,
        AppColors.primary,
        Colors.white,
      ),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 13.sp, color: textColor),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
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
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: HugeIcon(
                  icon: icon,
                  color: colorScheme.primary,
                  size: 14.sp,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
              fontSize: 12.sp,
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
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Price',
            style: textTheme.titleMedium?.copyWith(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          Text(
            totalPriceStr,
            style: textTheme.titleLarge?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
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
                fontSize: 14.sp,
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
        SizedBox(height: 8.h),
        if (attachments.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.15)
                  : colorScheme.surfaceContainerHighest.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                'No attachment images uploaded',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 90.h,
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
                    width: 90.w,
                    margin: EdgeInsets.only(right: 10.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
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
                                    size: 24.sp,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 4.w,
                                bottom: 4.h,
                                child: Container(
                                  padding: EdgeInsets.all(3.r),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedView,
                                    color: Colors.white,
                                    size: 12.sp,
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
                                size: 24.sp,
                              ),
                              SizedBox(height: 4.h),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: Text(
                                  item.fileName ?? 'File',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.sp,
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

class _TaskAssignmentDisplay extends ConsumerWidget {
  final String taskId;

  const _TaskAssignmentDisplay({required this.taskId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final assignmentAsync = ref.watch(taskAssignmentProvider(taskId));

    return assignmentAsync.when(
      data: (assignment) {
        if (assignment?.provider == null) {
          return const SizedBox.shrink();
        }
        return _AssignmentCard(assignment: assignment!);
      },
      loading: () => const _AssignmentCardShimmer(),
      error: (error, stack) => const SizedBox.shrink(),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final TaskAssignment assignment;

  const _AssignmentCard({required this.assignment});

  Future<void> _makeCall(String phoneNumber) async {
    final tel = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(tel)) {
      await launchUrl(tel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = assignment.provider;

    if (provider == null) {
      return const SizedBox.shrink();
    }

    final totalTasks = provider.totalTasksCompleted ?? 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: isDark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
            child: provider.profilePictureUrl != null
                ? ClipOval(
                    child: Image.network(
                      provider.profilePictureUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedUser,
                          color: AppColors.primary,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedUser,
                      color: AppColors.primary,
                      size: 20.sp,
                    ),
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  provider.fullname ?? 'Provider',
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    if (provider.averageRatings != null) ...[
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedStar,
                        color: Colors.amber,
                        size: 12.sp,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        '${provider.averageRatings?.toStringAsFixed(1) ?? '0.0'} rating',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11.sp,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Text(
                      '$totalTasks Tasks',
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11.sp,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (provider.phoneNumber != null &&
              provider.phoneNumber!.isNotEmpty) ...[
            SizedBox(width: 8.w),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _makeCall(provider.phoneNumber!),
                borderRadius: BorderRadius.circular(20.r),
                child: Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedCall,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AssignmentCardShimmer extends StatelessWidget {
  const _AssignmentCardShimmer();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = colorScheme.onSurface.withValues(alpha: 0.06);
    final highlightColor = colorScheme.onSurface.withValues(alpha: 0.12);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.3)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 22.r, backgroundColor: Colors.white),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 12.h,
                        width: 100.w,
                        color: Colors.white,
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        height: 14.h,
                        width: 130.w,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              height: 40.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ],
        ),
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
      decoration: BoxDecoration(color: colorScheme.surface),
      child: SafeArea(
        child: SizedBox(
          height: 44.h,
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
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              actionText,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;
    final shimmerColor = isDark ? Colors.grey[700]! : Colors.white;

    return SingleChildScrollView(
      child: Column(
        children: [
          Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Container(
              height: 240.h,
              width: double.infinity,
              color: shimmerColor,
            ),
          ),
          Container(
            transform: Matrix4.translationValues(0, -20.h, 0),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Shimmer.fromColors(
              baseColor: baseColor,
              highlightColor: highlightColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 36.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: shimmerColor,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 120.w,
                        height: 22.h,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                      Container(
                        width: 70.w,
                        height: 18.h,
                        decoration: BoxDecoration(
                          color: shimmerColor,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Container(
                    width: 200.w,
                    height: 18.h,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    width: double.infinity,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    width: 240.w,
                    height: 12.h,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 60.h,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Container(
                          height: 60.h,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    height: 90.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: 110.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: shimmerColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  SizedBox(
                    height: 90.h,
                    child: Row(
                      children: [
                        Container(
                          width: 90.w,
                          height: 90.h,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          width: 90.w,
                          height: 90.h,
                          decoration: BoxDecoration(
                            color: shimmerColor,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      color: colorScheme.surface,
      child: SafeArea(
        child: Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            height: 44.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
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
            mainAxisAlignment: Checkbox.width > 0
                ? MainAxisAlignment.center
                : MainAxisAlignment.center,
            children: [
              HugeIcon(
                icon: HugeIcons.strokeRoundedAlert01,
                color: colorScheme.error,
                size: 40.sp,
              ),
              SizedBox(height: 14.h),
              Text(
                'Unable to load task details',
                style: textTheme.titleMedium?.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(taskDetailProvider(taskId));
                  ref.invalidate(taskAssignmentProvider(taskId));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
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
