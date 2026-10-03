import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import 'package:seeker_app/core/constants.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/services_provider.dart';
import 'package:seeker_app/core/providers/task_creation_provider.dart';
import 'package:seeker_app/core/providers/task_providers.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  bool _isPosting = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final draftState = ref.watch(taskCreationProvider);
    final draft = draftState.value;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: draft == null
          ? const Center(child: CircularProgressIndicator())
          : _ReviewScreenContent(
              draft: draft,
              isPosting: _isPosting,
              onSubmit: _handleSubmit,
            ),
      bottomNavigationBar: draft != null
          ? _ReviewBottomActionBar(
              isPosting: _isPosting,
              onSubmit: () async {
                final confirm = await ConfirmationDialog.show(
                  context: context,
                  title: 'Submit Task Request?',
                  description:
                      'Once confirmed, your task will be published and we\'ll match you with available taskers in your area.',
                  confirmText: 'Confirm & Submit',
                  icon: Icons.check_circle_outline_rounded,
                );
                if (confirm) {
                  _handleSubmit();
                }
              },
            )
          : null,
    );
  }

  Future<void> _handleSubmit() async {
    setState(() => _isPosting = true);
    context.showLoading();

    try {
      await ref.read(taskCreationProvider.notifier).submit(
        onSuccess: (taskId) async {
          ref.invalidate(tasksProvider);

          if (mounted) {
            context.hideLoading();
            context.go('/');
            Future.delayed(const Duration(seconds: 1), () {
              final rc = rootNavigatorKey.currentContext;
              if (rc != null && rc.mounted) {
                if (taskId != null) {
                  ConfirmTaskSheet.show(rc, taskId);
                }
              }
            });
          }
        },
        onError: (msg) {
          if (mounted) {
            context.hideLoading();
            context.showMessage(msg, type: MessageType.error);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        context.hideLoading();
        context.showMessage(e.toString(), type: MessageType.error);
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }
}

class _ReviewScreenContent extends ConsumerWidget {
  final CreateTaskRequest draft;
  final bool isPosting;
  final VoidCallback onSubmit;

  const _ReviewScreenContent({
    required this.draft,
    required this.isPosting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final imageAttachments = (draft.attachments ?? []).where((att) {
      final url = att.url?.toLowerCase() ?? '';
      return url.endsWith('.jpg') ||
          url.endsWith('.jpeg') ||
          url.endsWith('.png') ||
          url.endsWith('.webp') ||
          att.type == 'image';
    }).toList();

    final hasHeroImage =
        imageAttachments.isNotEmpty && imageAttachments.first.url != null;

    final dateStr = draft.scheduledStartAt != null
        ? DateFormat('EEE, MMM d, yyyy • h:mm a').format(draft.scheduledStartAt!)
        : 'Flexible Start Time';

    String locationStr = 'Location not specified';
    final primaryLocation = draft.locations?.firstOrNull;
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
          expandedHeight: 220.h,
          pinned: true,
          elevation: 0,
          backgroundColor: colorScheme.surface,
          leading: Padding(
            padding: EdgeInsets.all(8.r),
            child: const CustomBackButton(),
          ),
          title: Text(
            'Review Request',
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
            ),
          ),
          centerTitle: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (hasHeroImage)
                  _HeroImageCarousel(attachments: imageAttachments)
                else
                  _HeroFallback(categoryId: draft.categoryId),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          colorScheme.surface,
                        ],
                        stops: const [0.0, 0.45, 1.0],
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
            transform: Matrix4.translationValues(0, -16.h, 0),
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

                  // Header Badge Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                              size: 13.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Final Step: Review',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Section 1: Category & Service
                  _ReviewSectionCard(
                    title: 'Category & Service',
                    icon: HugeIcons.strokeRoundedTask01,
                    onEdit: () => context.push('/task-creation/category'),
                    child: _CategoryAndServiceContent(
                      categoryId: draft.categoryId,
                      serviceId: draft.serviceId,
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Section 2: Task Details & Description
                  _ReviewSectionCard(
                    title: 'Task Details',
                    icon: HugeIcons.strokeRoundedNote01,
                    onEdit: () => context.push('/task-creation/description'),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          draft.title ?? 'Untitled Task',
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                            height: 1.25,
                          ),
                        ),
                        if (draft.description != null &&
                            draft.description!.trim().isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.25)
                                  : colorScheme.surfaceContainerHighest
                                      .withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: colorScheme.outlineVariant.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Text(
                              draft.description!,
                              style: textTheme.bodyMedium?.copyWith(
                                fontSize: 13.sp,
                                color: colorScheme.onSurfaceVariant,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Section 3: Schedule & Location
                  _ReviewSectionCard(
                    title: 'Schedule & Location',
                    icon: HugeIcons.strokeRoundedCalendar01,
                    onEdit: () => context.push('/task-creation/schedule'),
                    child: Column(
                      children: [
                        _ReviewInfoRow(
                          icon: HugeIcons.strokeRoundedCalendar01,
                          title: 'Date & Time',
                          subtitle: dateStr,
                          onEdit: () =>
                              context.push('/task-creation/schedule'),
                        ),
                        Divider(
                          height: 20.h,
                          thickness: 1,
                          color: colorScheme.outlineVariant.withValues(
                            alpha: 0.2,
                          ),
                        ),
                        _ReviewInfoRow(
                          icon: HugeIcons.strokeRoundedLocation01,
                          title: 'Service Address',
                          subtitle: locationStr,
                          onEdit: () =>
                              context.push('/task-creation/location'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Section 4: Attachments (if any)
                  if (draft.attachments != null &&
                      draft.attachments!.isNotEmpty) ...[
                    _ReviewSectionCard(
                      title: 'Attachments (${draft.attachments!.length})',
                      icon: HugeIcons.strokeRoundedImage01,
                      onEdit: () => context.push('/task-creation/description'),
                      child: _ReviewAttachmentsGrid(
                        attachments: draft.attachments!,
                      ),
                    ),
                    SizedBox(height: 14.h),
                  ],

                  // Section 5: Process Info Card
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedInformationCircle,
                            size: 18.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'What happens after submission?',
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Your task request will be published to available taskers nearby. You will receive offers and can choose the best provider for your task.',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: colorScheme.onSurfaceVariant,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewSectionCard extends StatelessWidget {
  final String title;
  final dynamic icon;
  final VoidCallback? onEdit;
  final Widget child;

  const _ReviewSectionCard({
    required this.title,
    required this.icon,
    this.onEdit,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.2)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: HugeIcon(
                  icon: icon,
                  color: AppColors.primary,
                  size: 15.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (onEdit != null)
                InkWell(
                  onTap: onEdit,
                  borderRadius: BorderRadius.circular(8.r),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        HugeIcon(
                          icon: HugeIcons.strokeRoundedPencilEdit01,
                          color: AppColors.primary,
                          size: 13.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'Edit',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }
}

class _CategoryAndServiceContent extends ConsumerWidget {
  final String? categoryId;
  final String? serviceId;

  const _CategoryAndServiceContent({
    this.categoryId,
    this.serviceId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    final categoryAsync = categoryId != null
        ? ref.watch(categoryByIdProvider(categoryId!))
        : const AsyncValue<ServiceCategory?>.data(null);

    final serviceAsync = serviceId != null
        ? ref.watch(serviceByIdProvider(serviceId!))
        : const AsyncValue<Service?>.data(null);

    final categoryName = categoryAsync.when(
      data: (cat) => cat?.name ?? 'Category',
      loading: () => 'Loading...',
      error: (err, stack) => 'Category',
    );

    final serviceName = serviceAsync.when(
      data: (srv) => srv?.name,
      loading: () => 'Loading...',
      error: (err, stack) => null,
    );

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.grid_view_rounded,
                size: 13.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 5.w),
              Text(
                categoryName,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        if (serviceName != null)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.build_circle_outlined,
                  size: 13.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
                SizedBox(width: 5.w),
                Text(
                  serviceName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _ReviewInfoRow extends StatelessWidget {
  final dynamic icon;
  final String title;
  final String subtitle;
  final VoidCallback? onEdit;

  const _ReviewInfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HugeIcon(
          icon: icon,
          color: colorScheme.onSurfaceVariant,
          size: 18.sp,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReviewAttachmentsGrid extends StatelessWidget {
  final List<CreateTaskAttachmentRequest> attachments;

  const _ReviewAttachmentsGrid({required this.attachments});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 72.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: attachments.length,
        separatorBuilder: (ctx, idx) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final att = attachments[index];
          final url = att.url ?? '';
          final isImage = url.endsWith('.jpg') ||
              url.endsWith('.jpeg') ||
              url.endsWith('.png') ||
              url.endsWith('.webp') ||
              att.type == 'image';

          return GestureDetector(
            onTap: () {
              if (url.isNotEmpty && isImage) {
                showDialog(
                  context: context,
                  builder: (ctx) => Dialog(
                    backgroundColor: Colors.transparent,
                    insetPadding: EdgeInsets.all(16.r),
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Image.network(url, fit: BoxFit.contain),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
            child: Container(
              width: 72.h,
              height: 72.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: colorScheme.surfaceContainerHighest,
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: isImage
                    ? Image.network(url, fit: BoxFit.cover)
                    : Center(
                        child: Icon(
                          Icons.insert_drive_file_rounded,
                          size: 24.sp,
                          color: colorScheme.primary,
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _HeroImageCarousel extends StatefulWidget {
  final List<CreateTaskAttachmentRequest> attachments;

  const _HeroImageCarousel({required this.attachments});

  @override
  State<_HeroImageCarousel> createState() => _HeroImageCarouselState();
}

class _HeroImageCarouselState extends State<_HeroImageCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PageView.builder(
          itemCount: widget.attachments.length,
          onPageChanged: (index) => setState(() => _currentIndex = index),
          itemBuilder: (context, index) {
            final url = widget.attachments[index].url ?? '';
            return Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const _HeroFallback(),
            );
          },
        ),
        if (widget.attachments.length > 1)
          Positioned(
            bottom: 24.h,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.attachments.length,
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 3.w),
                  width: _currentIndex == index ? 16.w : 6.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3.r),
                    color: _currentIndex == index
                        ? AppColors.primary
                        : Colors.white54,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HeroFallback extends ConsumerWidget {
  final String? categoryId;

  const _HeroFallback({this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categoryAsync = categoryId != null
        ? ref.watch(categoryByIdProvider(categoryId!))
        : const AsyncValue<ServiceCategory?>.data(null);

    final categoryName = categoryAsync.asData?.value?.name ?? 'Task Review';

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
                  AppColors.primary.withValues(alpha: 0.15),
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedTask01,
                color: AppColors.primary,
                size: 38.sp,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              categoryName,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewBottomActionBar extends StatelessWidget {
  final bool isPosting;
  final VoidCallback onSubmit;

  const _ReviewBottomActionBar({
    required this.isPosting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.25),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 48.h,
          child: ElevatedButton(
            onPressed: isPosting ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isPosting) ...[
                  SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Submitting Request...',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ] else ...[
                  Text(
                    'Confirm & Submit Request',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

