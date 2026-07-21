import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/designs/widgets/current_location.dart';
import 'package:seeker_app/core/models/tasks/task.dart';
import 'package:seeker_app/core/providers/task_creation_provider.dart';
import 'package:seeker_app/core/providers/services_provider.dart';
import 'package:seeker_app/core/providers/task_attachment_upload_provider.dart';
import 'package:seeker_app/core/utils/flushbar_message.dart';
import 'package:seeker_app/core/utils/loading_overlay.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/designs/app_colors.dart';
import '../../../../core/designs/app_text_styles.dart';
import '../../../../core/designs/widgets/primary_button.dart';
import '../../../../core/designs/widgets/confirmation_dialog.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({super.key});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  bool _isPosting = false;

  @override
  Widget build(BuildContext context) {
    final draftState = ref.watch(taskCreationProvider);
    final attachmentsState = ref.watch(taskAttachmentUploadProvider);
    final attachments = attachmentsState.value ?? [];

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final cardColor = isDark ? AppColors.darkerBackground : AppColors.surface;

    final draft = draftState.value;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Review Task',
          style: AppTextStyles.heading3.copyWith(
            color: textColor,
            fontSize: 18,
          ),
        ),
        leading: CustomBackButton(),
        // actions: [CurrentLocation()],
      ),
      body: draft == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16.0,
                              right: 16.0,
                              top: 16.0,
                              bottom: 12.0,
                            ),
                            child: _TitleSection(draft: draft, isDark: isDark),
                          ),
                          if (attachments.isNotEmpty)
                            _AttachmentsSection(
                              attachments: attachments,
                              isDark: isDark,
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 12.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (draft.description != null &&
                                    draft.description!.isNotEmpty) ...[
                                  Text(
                                    draft.description!,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: textColor.withOpacity(0.85),
                                      height: 1.4,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                _InfoSection(
                                  draft: draft,
                                  textColor: textColor,
                                  cardColor: cardColor,
                                  isDark: isDark,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  PrimaryButton(
                    text: 'Post Task',
                    margin: EdgeInsets.symmetric(horizontal: 16.0.w),
                    isLoading: _isPosting,
                    onPressed: () async {
                      final confirm = await ConfirmationDialog.show(
                        context: context,
                        title: 'Post Task',
                        description:
                            'Are you sure you want to post this task? Please review the details carefully.',
                        confirmText: 'Post',
                        icon: Icons.check_circle_outline_rounded,
                      );
                      if (confirm) {
                        _handlePostTask(attachments);
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _handlePostTask(List<File> attachments) async {
    setState(() => _isPosting = true);
    context.showLoading();

    final completer = Completer<void>();

    try {
      await ref
          .read(taskCreationProvider.notifier)
          .submit(
            onSuccess: (taskId) async {
              if (attachments.isNotEmpty && taskId != null) {
                await ref
                    .read(taskAttachmentUploadProvider.notifier)
                    .upload(
                      taskId: taskId,
                      onSuccess: () {
                        completer.complete();
                        if (mounted) {
                          context.go('/task-creation/success');
                        }
                      },
                      onError: (err) {
                        completer.completeError(err);
                      },
                    );
              } else {
                completer.complete();
                if (mounted) {
                  context.go('/task-creation/success');
                }
              }
            },
            onError: (msg) {
              completer.completeError(msg);
            },
          );

      await completer.future;
    } catch (e) {
      if (mounted) {
        context.showMessage(e.toString(), type: MessageType.error);
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
      context.hideLoading();
    }
  }
}

class _AttachmentsSection extends StatefulWidget {
  final List<File> attachments;
  final bool isDark;

  const _AttachmentsSection({required this.attachments, required this.isDark});

  @override
  State<_AttachmentsSection> createState() => _AttachmentsSectionState();
}

class _AttachmentsSectionState extends State<_AttachmentsSection> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.attachments.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.width * 0.7,
          child: PageView.builder(
            itemCount: widget.attachments.length,
            onPageChanged: (index) {
              setState(() => _currentIndex = index);
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(
                    widget.attachments[index],
                    fit: BoxFit.cover,
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.attachments.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.attachments.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentIndex == index ? 16 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentIndex == index
                        ? AppColors.primary
                        : (widget.isDark ? Colors.white24 : Colors.black12),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TitleSection extends StatelessWidget {
  final CreateTaskRequest draft;
  final bool isDark;

  const _TitleSection({required this.draft, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          draft.title ?? 'Untitled Task',
          style: AppTextStyles.heading2.copyWith(
            color: isDark ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            height: 1.2,
            fontSize: 20,
          ),
        ),
        const SizedBox(height: 8),
        if (draft.categoryId != null)
          _CategoryBadge(categoryId: draft.categoryId!, isDark: isDark),
      ],
    );
  }
}

class _InfoSection extends StatelessWidget {
  final CreateTaskRequest draft;
  final Color textColor;
  final Color cardColor;
  final bool isDark;

  const _InfoSection({
    required this.draft,
    required this.textColor,
    required this.cardColor,
    required this.isDark,
  });

  String _formatBudget(double? min, double? max) {
    final format = NumberFormat.currency(symbol: '₦', decimalDigits: 0);
    if (min == null && max == null) return 'Not specified';
    if (min != null && max != null) {
      if (min == max) return format.format(min);
      return '${format.format(min)} - ${format.format(max)}';
    }
    return format.format(min ?? max);
  }

  String _formatLocation(CreateTaskRequest draft) {
    final locations = draft.locations;
    if (locations == null || locations.isEmpty) return 'Not specified';
    final loc = locations.first;
    if (loc.city != null && loc.state != null) {
      return '${loc.city}, ${loc.state}';
    } else if (loc.address != null) {
      return loc.address!;
    }
    return 'Location selected';
  }

  String _formatStartDate(DateTime? date) {
    if (date == null) return 'As soon as possible';

    final now = DateTime.now();
    final difference = date.difference(now);

    final DateFormat timeFormat = DateFormat('h:mm a');
    final DateFormat dateFormat = DateFormat('d MMM, yyyy');

    if (difference.inDays == 0 && date.day == now.day) {
      return '${timeFormat.format(date)}, Today';
    } else if (difference.inDays == 1 ||
        (difference.inDays == 0 &&
            date.day == now.add(const Duration(days: 1)).day)) {
      return '${timeFormat.format(date)}, Tomorrow';
    } else if (difference.inDays > 1 && difference.inDays < 7) {
      return '${timeFormat.format(date)}, ${difference.inDays} days from now';
    } else {
      return '${timeFormat.format(date)}, ${dateFormat.format(date)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        children: [
          _CompactInfoTile(
            icon: Icons.account_balance_wallet_rounded,
            title: 'Budget',
            value: _formatBudget(draft.budgetMin, draft.budgetMax),
            iconColor: AppColors.primary,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _CompactInfoTile(
            icon: Icons.location_on_rounded,
            title: 'Location',
            value: _formatLocation(draft),
            iconColor: AppColors.secondaryVariant,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _CompactInfoTile(
            icon: Icons.calendar_today_rounded,
            title: 'Start Date',
            value: _formatStartDate(draft.scheduledStartAt),
            iconColor: AppColors.accentOrange,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _CompactInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;
  final bool isDark;

  const _CompactInfoTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isDark ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryBadge extends ConsumerWidget {
  final String categoryId;
  final bool isDark;

  const _CategoryBadge({required this.categoryId, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryAsync = ref.watch(categoryByIdProvider(categoryId));
    return categoryAsync.when(
      data: (category) => _BadgeContainer(
        text: category.name ?? 'Category',
        color: AppColors.primary,
        icon: Icons.category_rounded,
      ),
      loading: () => _ShimmerBadge(isDark: isDark),
      error: (_, __) => const _BadgeContainer(
        text: 'Unknown',
        color: AppColors.primary,
        icon: Icons.error_outline,
      ),
    );
  }
}

class _ServiceBadge extends ConsumerWidget {
  final String serviceId;
  final bool isDark;

  const _ServiceBadge({required this.serviceId, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAsync = ref.watch(serviceByIdProvider(serviceId));
    return serviceAsync.when(
      data: (service) => _BadgeContainer(
        text: service.name ?? 'Service',
        color: AppColors.secondaryVariant,
        icon: Icons.design_services_rounded,
      ),
      loading: () => _ShimmerBadge(isDark: isDark),
      error: (_, __) => const _BadgeContainer(
        text: 'Unknown',
        color: AppColors.secondaryVariant,
        icon: Icons.error_outline,
      ),
    );
  }
}

class _BadgeContainer extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const _BadgeContainer({
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShimmerBadge extends StatelessWidget {
  final bool isDark;
  const _ShimmerBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: 100,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
