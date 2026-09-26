import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/designs/widgets/confirmation_dialog.dart';
import 'package:seeker_app/core/designs/widgets/custom_back_button.dart';
import 'package:seeker_app/core/designs/widgets/primary_button.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/support_providers.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import 'package:seeker_app/core/utils/flushbar_message.dart';
import 'package:seeker_app/core/utils/loading_overlay.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportCaseDetailScreen extends ConsumerStatefulWidget {
  final String caseId;

  const SupportCaseDetailScreen({
    super.key,
    required this.caseId,
  });

  @override
  ConsumerState<SupportCaseDetailScreen> createState() =>
      _SupportCaseDetailScreenState();
}

class _SupportCaseDetailScreenState extends ConsumerState<SupportCaseDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(caseAttachmentsProvider(widget.caseId).notifier).loadMore();
    }
  }

  Future<void> _refreshAll() async {
    ref.invalidate(caseDetailProvider(widget.caseId));
    await ref.read(caseAttachmentsProvider(widget.caseId).notifier).refresh();
  }

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) return '';
    final local = dateTime.toLocal();
    final now = DateTime.now();
    final timeStr = DateFormat('HH:mm').format(local);

    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return 'Today · $timeStr';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (local.year == yesterday.year &&
        local.month == yesterday.month &&
        local.day == yesterday.day) {
      return 'Yesterday · $timeStr';
    }

    return DateFormat('MMM d, yyyy · HH:mm').format(local);
  }

  String _formatFileSize(int? bytes) {
    if (bytes == null || bytes <= 0) return '0 B';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _navigateToChat() {
    context.pushNamed(
      RouteNames.supportChat.name,
      pathParameters: {'caseId': widget.caseId},
    );
  }

  Future<void> _toggleCaseStatus(bool isClosed) async {
    final confirm = await ConfirmationDialog.show(
      context: context,
      title: isClosed ? 'Reopen Ticket?' : 'Close Ticket?',
      description: isClosed
          ? 'Are you sure you want to reopen this support ticket?'
          : 'Are you sure you want to mark this support ticket as closed?',
      confirmText: isClosed ? 'Reopen Ticket' : 'Close Ticket',
      cancelText: 'Cancel',
      isDestructive: !isClosed,
      customColor: isClosed ? AppColors.primary : AppColors.error,
    );

    if (confirm != true || !mounted) return;

    context.showLoading();

    if (isClosed) {
      await ref.read(supportActionsProvider.notifier).reopenCase(
            caseId: widget.caseId,
            onSuccess: (_) {
              if (!mounted) return;
              context.hideLoading();
              context.showMessage('Ticket reopened', type: MessageType.success);
              _refreshAll();
            },
            onError: (err) {
              if (!mounted) return;
              context.hideLoading();
              context.showMessage(err, type: MessageType.error);
            },
          );
    } else {
      await ref.read(supportActionsProvider.notifier).closeCase(
            caseId: widget.caseId,
            onSuccess: (_) {
              if (!mounted) return;
              context.hideLoading();
              context.showMessage('Ticket closed', type: MessageType.success);
              _refreshAll();
            },
            onError: (err) {
              if (!mounted) return;
              context.hideLoading();
              context.showMessage(err, type: MessageType.error);
            },
          );
    }
  }

  Future<void> _openAttachmentUrl(String? url) async {
    if (url == null || url.isEmpty) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      context.showMessage('Could not open file URL', type: MessageType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailAsync = ref.watch(caseDetailProvider(widget.caseId));
    final attachmentsAsync = ref.watch(caseAttachmentsProvider(widget.caseId));

    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor = isDark ? Colors.white.withValues(alpha: 0.04) : AppColors.surface;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06);
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: CustomBackButton(),
        title: Text(
          'Ticket Details',
          style: AppTextStyles.heading3.copyWith(
            color: textPrimary,
            fontSize: 16.sp,
          ),
        ),
        actions: [

        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: PrimaryButton(
            text: 'Open Support Chat',
            height: 44.h,
            onPressed: _navigateToChat,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshAll,
        color: AppColors.primary,
        child: detailAsync.when(
          data: (caseItem) {
            final isClosed = (caseItem.status?.toUpperCase() == 'CLOSED' ||
                caseItem.status?.toUpperCase() == 'RESOLVED' ||
                caseItem.status?.toUpperCase() == 'CANCELLED');

            final attachmentCount = attachmentsAsync.value?.length ?? 0;

            return SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Case Header Card
                  _buildHeaderCard(
                    caseItem: caseItem,
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    isClosed: isClosed,
                  ).animate().fade(duration: 200.ms),

                  SizedBox(height: 20.h),

                  // Attachments Section Header
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedAttachment01,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Attachments',
                        style: AppTextStyles.heading3.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      if (attachmentCount > 0) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '$attachmentCount',
                            style: AppTextStyles.label.copyWith(
                              fontSize: 10.sp,
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // Attachments List
                  attachmentsAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return _buildEmptyAttachmentsState(isDark, surfaceColor, borderColor, textSecondary);
                      }

                      final hasMore = ref.read(caseAttachmentsProvider(widget.caseId).notifier).hasMore;

                      return Column(
                        children: [
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: items.length + (hasMore ? 1 : 0),
                            separatorBuilder: (context, index) => SizedBox(height: 8.h),
                            itemBuilder: (context, index) {
                              if (index == items.length) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  child: const Center(
                                    child: CircularProgressIndicator.adaptive(),
                                  ),
                                );
                              }

                              final item = items[index];
                              return _AttachmentTile(
                                item: item,
                                formattedDate: _formatDate(item.createdAt),
                                formattedSize: _formatFileSize(item.fileSize),
                                isDark: isDark,
                                surfaceColor: surfaceColor,
                                borderColor: borderColor,
                                textPrimary: textPrimary,
                                textSecondary: textSecondary,
                                onTap: () => _openAttachmentUrl(item.fileUrl),
                              );
                            },
                          ),
                        ],
                      );
                    },
                    loading: () => _buildShimmerAttachments(isDark, surfaceColor, borderColor),
                    error: (err, _) => Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Text('Failed to load attachments: $err', style: TextStyle(color: AppColors.error)),
                    ),
                  ),

                  SizedBox(height: 24.h),
                ],
              ),
            );
          },
          loading: () => _buildShimmerDetail(isDark, surfaceColor, borderColor),
          error: (err, stack) => _buildErrorState(
            err.toString(),
            isDark,
            textPrimary,
            textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard({
    required SupportCase caseItem,
    required bool isDark,
    required Color surfaceColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required bool isClosed,
  }) {
    final statusStr = caseItem.status ?? 'OPEN';
    final caseNum = caseItem.caseNumber != null && caseItem.caseNumber!.isNotEmpty
        ? '#${caseItem.caseNumber}'
        : (caseItem.id != null ? '#${caseItem.id!.substring(0, 8).toUpperCase()}' : '#TICKET');

    final typeStr = caseItem.type?.replaceAll('_', ' ').toUpperCase() ?? 'GENERAL';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: borderColor, width: 1.w),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedTicket01,
                    size: 16.sp,
                    color: AppColors.primary,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    caseNum,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: isClosed
                          ? (isDark ? Colors.white10 : const Color(0xFFF0F2F5))
                          : Colors.blue.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      statusStr.replaceAll('_', ' ').toUpperCase(),
                      style: AppTextStyles.label.copyWith(
                        color: isClosed ? textSecondary : Colors.blue.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => _toggleCaseStatus(isClosed),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: isClosed
                            ? AppColors.primary.withValues(alpha: 0.12)
                            : AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color: isClosed
                              ? AppColors.primary.withValues(alpha: 0.3)
                              : AppColors.error.withValues(alpha: 0.3),
                          width: 1.w,
                        ),
                      ),
                      child: Text(
                        isClosed ? 'Reopen' : 'Close Ticket',
                        style: AppTextStyles.label.copyWith(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: isClosed ? AppColors.primary : AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10.h),

          Text(
            caseItem.subject ?? 'No Subject',
            style: AppTextStyles.heading3.copyWith(
              color: textPrimary,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (caseItem.description != null && caseItem.description!.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              caseItem.description!,
              style: AppTextStyles.bodySmall.copyWith(
                color: textSecondary,
                fontSize: 12.sp,
                height: 1.4,
              ),
            ),
          ],
          SizedBox(height: 12.h),

          Wrap(
            spacing: 6.w,
            runSpacing: 6.h,
            children: [
              _buildMetaChip(typeStr, isDark, textSecondary),
              if (caseItem.priority != null && caseItem.priority!.isNotEmpty)
                _buildMetaChip('Priority: ${caseItem.priority!.toUpperCase()}', isDark, textSecondary),
              if (caseItem.taskId != null && caseItem.taskId!.isNotEmpty)
                _buildMetaChip('Task ID: #${caseItem.taskId!.substring(0, 8)}', isDark, AppColors.primary),
              if (caseItem.assignmentId != null && caseItem.assignmentId!.isNotEmpty)
                _buildMetaChip('Assign ID: #${caseItem.assignmentId!.substring(0, 8)}', isDark, textSecondary),
              if (caseItem.createdAt != null)
                _buildMetaChip(_formatDate(caseItem.createdAt), isDark, textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAttachmentsState(
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textSecondary,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor, width: 1.w),
      ),
      child: Column(
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedAttachment01,
            size: 32.sp,
            color: textSecondary.withValues(alpha: 0.5),
          ),
          SizedBox(height: 8.h),
          Text(
            'No Attachments Uploaded Yet',
            style: AppTextStyles.bodySmall.copyWith(
              color: textSecondary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetaChip(String label, bool isDark, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildShimmerDetail(bool isDark, Color surfaceColor, Color borderColor) {
    final baseColor = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Container(
              height: 140.h,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              height: 100.h,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerAttachments(bool isDark, Color surfaceColor, Color borderColor) {
    final baseColor = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: List.generate(
          2,
          (index) => Container(
            height: 56.h,
            margin: EdgeInsets.only(bottom: 8.h),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    String error,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedAlertCircle,
              size: 40.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 12.h),
            Text(
              'Failed to load ticket details',
              style: AppTextStyles.heading3.copyWith(
                color: textPrimary,
                fontSize: 15.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              error,
              style: AppTextStyles.bodySmall.copyWith(
                color: textSecondary,
                fontSize: 12.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton.icon(
              onPressed: _refreshAll,
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedRefresh,
                size: 16.sp,
                color: Colors.white,
              ),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttachmentTile extends StatelessWidget {
  final SupportCaseAttachment item;
  final String formattedDate;
  final String formattedSize;
  final bool isDark;
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  const _AttachmentTile({
    required this.item,
    required this.formattedDate,
    required this.formattedSize,
    required this.isDark,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  dynamic _getIconForFile(String? contentType, String? fileName) {
    final type = contentType?.toLowerCase() ?? '';
    final ext = fileName?.toLowerCase().split('.').last ?? '';

    if (type.contains('image') || ['png', 'jpg', 'jpeg', 'gif', 'webp'].contains(ext)) {
      return HugeIcons.strokeRoundedImage01;
    }
    if (type.contains('pdf') || ext == 'pdf') {
      return HugeIcons.strokeRoundedFile02;
    }
    if (type.contains('video') || ['mp4', 'mov', 'avi'].contains(ext)) {
      return HugeIcons.strokeRoundedVideo01;
    }
    return HugeIcons.strokeRoundedAttachment01;
  }

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconForFile(item.contentType, item.fileName);
    final name = item.fileName ?? 'Attachment';
    final hasUrl = item.fileUrl != null && item.fileUrl!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: borderColor, width: 1.w),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        leading: Container(
          width: 36.w,
          height: 36.w,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: HugeIcon(
              icon: iconData,
              size: 18.sp,
              color: AppColors.primary,
            ),
          ),
        ),
        title: Text(
          name,
          style: AppTextStyles.label.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Text(
              formattedSize,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 10.sp,
                color: textSecondary,
              ),
            ),
            if (formattedDate.isNotEmpty) ...[
              Text(
                ' · ',
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10.sp,
                  color: textSecondary,
                ),
              ),
              Text(
                formattedDate,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10.sp,
                  color: textSecondary,
                ),
              ),
            ],
          ],
        ),
        trailing: hasUrl
            ? IconButton(
                onPressed: onTap,
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedDownload01,
                  size: 16.sp,
                  color: AppColors.primary,
                ),
                tooltip: 'View / Download',
              )
            : null,
      ),
    );
  }
}
