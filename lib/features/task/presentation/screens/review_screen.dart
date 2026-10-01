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
                  title: 'Ready to submit?',
                  description:
                      'Once confirmed, we\'ll create your task draft and match you with available Taskers.',
                  confirmText: 'Yes, Submit',
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

class _ReviewScreenContent extends StatelessWidget {
  final CreateTaskRequest draft;
  final bool isPosting;
  final VoidCallback onSubmit;

  const _ReviewScreenContent({
    required this.draft,
    required this.isPosting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
              padding: EdgeInsets.only(right: 12.w, top: 8.h, bottom: 8.h),
              child: const _DraftStatusBadge(),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                if (hasHeroImage)
                  _HeroImageCarousel(attachments: imageAttachments)
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
                          colorScheme.surface,
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
                  if (draft.categoryId != null) ...[
                    _CategoryBadge(categoryId: draft.categoryId!),
                    SizedBox(height: 8.h),
                  ],
                  Text(
                    draft.title ?? 'Task Details',
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  if (draft.description != null &&
                      draft.description!.isNotEmpty) ...[
                    Text(
                      draft.description!,
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 13.sp,
                        color: colorScheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
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
                  SizedBox(height: 16.h),
                  if (draft.attachments != null &&
                      draft.attachments!.isNotEmpty) ...[
                    _ReviewAttachmentsSection(
                      attachments: draft.attachments!,
                    ),
                    SizedBox(height: 16.h),
                  ],
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DraftStatusBadge extends StatelessWidget {
  const _DraftStatusBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
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
          Icon(Icons.edit_note_rounded, size: 13.sp, color: Colors.white),
          SizedBox(width: 4.w),
          Text(
            'Draft',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ],
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
            bottom: 30.h,
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

class _CategoryBadge extends ConsumerWidget {
  final String categoryId;

  const _CategoryBadge({required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(categoryByIdProvider(categoryId));
    return categoryAsync.when(
      data: (category) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.category_rounded, size: 13.sp, color: AppColors.primary),
            SizedBox(width: 4.w),
            Text(
              category.name ?? 'Service',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}

class _ReviewAttachmentsSection extends StatelessWidget {
  final List<CreateTaskAttachmentRequest> attachments;

  const _ReviewAttachmentsSection({required this.attachments});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachments (${attachments.length})',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        SizedBox(
          height: 70.h,
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

              return Container(
                width: 70.h,
                height: 70.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  color: colorScheme.surfaceContainerHighest,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
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
              );
            },
          ),
        ),
      ],
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

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(color: colorScheme.surface),
      child: SafeArea(
        child: SizedBox(
          height: 44.h,
          child: ElevatedButton(
            onPressed: isPosting ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isPosting)
                  SizedBox(
                    width: 18.r,
                    height: 18.r,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                else
                  Text(
                    'Confirm Task Order',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
