import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/designs/widgets/custom_back_button.dart';
import 'package:seeker_app/core/designs/widgets/primary_button.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/support_providers.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import 'package:seeker_app/core/utils/flushbar_message.dart';
import 'package:seeker_app/core/utils/loading_overlay.dart';
import 'package:shimmer/shimmer.dart';

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
  Future<void> _refreshAll() async {
    ref.invalidate(caseDetailProvider(widget.caseId));
    await ref.read(caseTimelineProvider(widget.caseId).notifier).refresh();
    await ref.read(caseMessagesProvider(widget.caseId).notifier).refresh();
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

  void _navigateToChat() {
    context.pushNamed(
      RouteNames.supportChat.name,
      pathParameters: {'caseId': widget.caseId},
    );
  }

  Future<void> _toggleCaseStatus(bool isClosed) async {
    final actionName = isClosed ? 'reopen' : 'close';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${actionName.toUpperCase()} Ticket?'),
        content: Text(
          isClosed
              ? 'Are you sure you want to reopen this support ticket?'
              : 'Are you sure you want to mark this support ticket as closed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: isClosed ? AppColors.primary : AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(actionName.toUpperCase()),
          ),
        ],
      ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailAsync = ref.watch(caseDetailProvider(widget.caseId));
    final timelineAsync = ref.watch(caseTimelineProvider(widget.caseId));
    final messagesAsync = ref.watch(caseMessagesProvider(widget.caseId));

    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor = isDark ? const Color(0xFF16181C) : AppColors.surface;
    final borderColor = isDark ? const Color(0xFF2C2F36) : const Color(0xFFE5E7EB);
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: true,
        leading: const CustomBackButton(),
        title: Text(
          'Ticket Details',
          style: AppTextStyles.heading3.copyWith(
            color: textPrimary,
            fontSize: 16.sp,
          ),
        ),
        actions: [
          // Open Chat IconButton
          IconButton(
            onPressed: _navigateToChat,
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedBubbleChat,
              color: AppColors.primary,
              size: 20.sp,
            ),
            tooltip: 'Open Chat',
          ),
          IconButton(
            onPressed: _refreshAll,
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedRefresh,
              color: textPrimary,
              size: 20.sp,
            ),
            tooltip: 'Refresh',
          ),
          SizedBox(width: 4.w),
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

            final recentMessageCount = messagesAsync.value?.length ?? 0;

            return SingleChildScrollView(
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

                  SizedBox(height: 14.h),

                  // Open Support Chat Banner Card
                  _buildChatBannerCard(
                    messageCount: recentMessageCount,
                    isDark: isDark,
                    surfaceColor: surfaceColor,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ).animate().fade(duration: 220.ms).slideY(begin: 0.05, duration: 220.ms),

                  SizedBox(height: 16.h),

                  // Timeline Section Header
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedTime02,
                        size: 16.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        'Timeline & Event History',
                        style: AppTextStyles.heading3.copyWith(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),

                  // Timeline Stepper List
                  timelineAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.h),
                          child: Center(
                            child: Text(
                              'No timeline events available',
                              style: AppTextStyles.bodySmall.copyWith(color: textSecondary),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final isLast = index == items.length - 1;

                          return _TimelineItemTile(
                            item: item,
                            formattedDate: _formatDate(item.timestamp),
                            isLast: isLast,
                            isDark: isDark,
                            surfaceColor: surfaceColor,
                            borderColor: borderColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                          );
                        }).toList(),
                      );
                    },
                    loading: () => _buildShimmerTimeline(isDark, surfaceColor),
                    error: (err, _) => Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Text('Failed to load timeline: $err', style: TextStyle(color: AppColors.error)),
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
      padding: EdgeInsets.all(14.w),
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
          SizedBox(height: 8.h),

          Text(
            caseItem.subject ?? 'No Subject',
            style: AppTextStyles.heading3.copyWith(
              color: textPrimary,
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (caseItem.description != null && caseItem.description!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(
              caseItem.description!,
              style: AppTextStyles.bodySmall.copyWith(
                color: textSecondary,
                fontSize: 12.sp,
                height: 1.3,
              ),
            ),
          ],
          SizedBox(height: 10.h),

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

  Widget _buildChatBannerCard({
    required int messageCount,
    required bool isDark,
    required Color surfaceColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return InkWell(
      onTap: _navigateToChat,
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E242B) : const Color(0xFFF0FDF4),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.2.w,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedBubbleChat,
                size: 22.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Support Chat Channel',
                        style: AppTextStyles.label.copyWith(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      if (messageCount > 0) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            '$messageCount msgs',
                            style: AppTextStyles.label.copyWith(
                              fontSize: 9.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Chat directly with support representatives & send file attachments.',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 11.sp,
                      color: textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 6.w),
            HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              size: 16.sp,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip(String label, bool isDark, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF262930) : const Color(0xFFF1F5F9),
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
    final baseColor = isDark ? const Color(0xFF262930) : Colors.grey[300]!;
    final highlightColor = isDark ? const Color(0xFF383C45) : Colors.grey[100]!;

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
              height: 70.h,
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

  Widget _buildShimmerTimeline(bool isDark, Color surfaceColor) {
    final baseColor = isDark ? const Color(0xFF262930) : Colors.grey[300]!;
    final highlightColor = isDark ? const Color(0xFF383C45) : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            height: 60.h,
            margin: EdgeInsets.only(bottom: 10.h),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadius.circular(8.r),
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

class _TimelineItemTile extends StatelessWidget {
  final SupportCaseTimelineItem item;
  final String formattedDate;
  final bool isLast;
  final bool isDark;
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;

  const _TimelineItemTile({
    required this.item,
    required this.formattedDate,
    required this.isLast,
    required this.isDark,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  dynamic _getIconForType(String? type, String? actor) {
    final t = type?.toUpperCase() ?? '';
    if (t.contains('CREATE')) return HugeIcons.strokeRoundedTicket01;
    if (t.contains('CLOSE') || t.contains('RESOLV')) return HugeIcons.strokeRoundedCheckmarkCircle02;
    if (t.contains('REOPEN')) return HugeIcons.strokeRoundedRefresh;
    if (t.contains('MSG') || t.contains('MESSAGE')) return HugeIcons.strokeRoundedBubbleChat;
    if (actor?.toUpperCase() == 'AGENT') return HugeIcons.strokeRoundedCustomerSupport;
    return HugeIcons.strokeRoundedNotification01;
  }

  Color _getIconColor(String? type, String? actor) {
    final t = type?.toUpperCase() ?? '';
    if (t.contains('CREATE')) return AppColors.primary;
    if (t.contains('CLOSE') || t.contains('RESOLV')) return Colors.green;
    if (t.contains('REOPEN')) return Colors.orange;
    if (t.contains('MSG') || t.contains('MESSAGE')) return Colors.blue;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final iconData = _getIconForType(item.itemType, item.actorType);
    final iconColor = _getIconColor(item.itemType, item.actorType);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: iconColor.withValues(alpha: 0.4), width: 1.5.w),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: iconData,
                    size: 14.sp,
                    color: iconColor,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.w,
                    margin: EdgeInsets.symmetric(vertical: 4.h),
                    color: isDark ? const Color(0xFF2C2F36) : const Color(0xFFE2E8F0),
                  ),
                ),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.h),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: borderColor, width: 1.w),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title ?? 'Timeline Event',
                            style: AppTextStyles.label.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                        if (formattedDate.isNotEmpty)
                          Text(
                            formattedDate,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 9.sp,
                              color: textSecondary,
                            ),
                          ),
                      ],
                    ),
                    if (item.description != null && item.description!.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        item.description!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: textSecondary,
                          fontSize: 11.sp,
                          height: 1.3,
                        ),
                      ),
                    ],
                    if (item.actorType != null && item.actorType!.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'By: ${item.actorType!.toUpperCase()}',
                        style: AppTextStyles.label.copyWith(
                          fontSize: 9.sp,
                          color: iconColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
