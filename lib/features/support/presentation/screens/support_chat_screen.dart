import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/designs/widgets/custom_back_button.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/support_providers.dart';
import 'package:seeker_app/core/utils/flushbar_message.dart';
import 'package:seeker_app/core/utils/loading_overlay.dart';
import 'package:shimmer/shimmer.dart';

class SupportChatScreen extends ConsumerStatefulWidget {
  final String caseId;

  const SupportChatScreen({
    super.key,
    required this.caseId,
  });

  @override
  ConsumerState<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends ConsumerState<SupportChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _messagesScrollController = ScrollController();

  File? _selectedAttachmentFile;
  String? _selectedAttachmentName;
  int? _selectedAttachmentSize;
  bool _isSending = false;
  bool _isUploadingFile = false;
  bool _isHeaderExpanded = false;

  @override
  void initState() {
    super.initState();
    _messagesScrollController.addListener(_onScroll);
    _messageController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _messagesScrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _onScroll() {
    if (_messagesScrollController.position.pixels >=
        _messagesScrollController.position.maxScrollExtent - 200) {
      ref.read(caseMessagesProvider(widget.caseId).notifier).loadMore();
    }
  }

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

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  void _showAttachmentOptions() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E2128) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                'Attach Media or Document',
                style: AppTextStyles.heading3.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: _buildAttachmentOptionTile(
                      icon: HugeIcons.strokeRoundedCamera01,
                      title: 'Camera',
                      color: Colors.blue,
                      onTap: () async {
                        Navigator.pop(ctx);
                        final picker = ImagePicker();
                        final photo = await picker.pickImage(source: ImageSource.camera);
                        if (photo != null) {
                          _setAttachmentFile(File(photo.path), photo.name);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildAttachmentOptionTile(
                      icon: HugeIcons.strokeRoundedImage01,
                      title: 'Gallery',
                      color: Colors.purple,
                      onTap: () async {
                        Navigator.pop(ctx);
                        final picker = ImagePicker();
                        final image = await picker.pickImage(source: ImageSource.gallery);
                        if (image != null) {
                          _setAttachmentFile(File(image.path), image.name);
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildAttachmentOptionTile(
                      icon: HugeIcons.strokeRoundedFile01,
                      title: 'Document',
                      color: AppColors.primary,
                      onTap: () async {
                        Navigator.pop(ctx);
                        final result = await FilePicker.pickFiles();
                        if (result != null && result.files.single.path != null) {
                          final f = File(result.files.single.path!);
                          _setAttachmentFile(f, result.files.single.name);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setAttachmentFile(File file, String name) {
    setState(() {
      _selectedAttachmentFile = file;
      _selectedAttachmentName = name;
      _selectedAttachmentSize = file.lengthSync();
    });
  }

  void _clearSelectedAttachment() {
    setState(() {
      _selectedAttachmentFile = null;
      _selectedAttachmentName = null;
      _selectedAttachmentSize = null;
    });
  }

  Future<void> _sendMessageAndAttachment() async {
    final text = _messageController.text.trim();
    if (text.isEmpty && _selectedAttachmentFile == null) return;
    if (_isSending || _isUploadingFile) return;

    setState(() {
      _isSending = true;
    });

    FocusScope.of(context).unfocus();
    context.showLoading();

    try {
      SupportCaseMessage? sentMessage;

      if (text.isNotEmpty) {
        await ref.read(supportActionsProvider.notifier).sendMessage(
              caseId: widget.caseId,
              request: SendSupportMessageRequest(body: text),
              onSuccess: (msg) {
                sentMessage = msg;
              },
              onError: (err) {
                throw Exception(err);
              },
            );
      }

      if (_selectedAttachmentFile != null) {
        setState(() {
          _isUploadingFile = true;
        });

        await ref.read(supportActionsProvider.notifier).uploadAttachment(
              caseId: widget.caseId,
              file: _selectedAttachmentFile!,
              messageId: sentMessage?.id,
              onSuccess: (_) {
                _clearSelectedAttachment();
              },
              onError: (err) {
                context.showMessage('File upload failed: $err', type: MessageType.error);
              },
            );
      }

      if (!mounted) return;
      context.hideLoading();
      setState(() {
        _isSending = false;
        _isUploadingFile = false;
        _messageController.clear();
      });
      context.showMessage('Message sent', type: MessageType.success);
      ref.read(caseMessagesProvider(widget.caseId).notifier).refresh();
      ref.read(caseTimelineProvider(widget.caseId).notifier).refresh();
    } catch (e) {
      if (!mounted) return;
      context.hideLoading();
      setState(() {
        _isSending = false;
        _isUploadingFile = false;
      });
      context.showMessage(e.toString().replaceAll('Exception: ', ''), type: MessageType.error);
    }
  }

  Future<void> _attachFileToSpecificMessage(String messageId) async {
    final result = await FilePicker.pickFiles();
    if (result == null || result.files.single.path == null || !mounted) return;

    final file = File(result.files.single.path!);
    context.showLoading();

    await ref.read(supportActionsProvider.notifier).uploadAttachment(
          caseId: widget.caseId,
          file: file,
          messageId: messageId,
          onSuccess: (_) {
            if (!mounted) return;
            context.hideLoading();
            context.showMessage('Attachment added to message', type: MessageType.success);
            ref.read(caseMessagesProvider(widget.caseId).notifier).refresh();
          },
          onError: (err) {
            if (!mounted) return;
            context.hideLoading();
            context.showMessage(err, type: MessageType.error);
          },
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

  void _showTimelineOverviewSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TimelineOverviewSheet(
        caseId: widget.caseId,
        formatDate: _formatDate,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailAsync = ref.watch(caseDetailProvider(widget.caseId));
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
        elevation: 0.5,
        leading: const CustomBackButton(),
        titleSpacing: 0,
        title: detailAsync.when(
          data: (caseItem) {
            final caseNum = caseItem.caseNumber != null && caseItem.caseNumber!.isNotEmpty
                ? '#${caseItem.caseNumber}'
                : '#${caseItem.id?.substring(0, 8).toUpperCase()}';
            return Row(
              children: [
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedCustomerSupport,
                      size: 16.sp,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              'Support Chat',
                              style: AppTextStyles.heading3.copyWith(
                                color: textPrimary,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Flexible(
                            fit: FlexFit.loose,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                caseNum,
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9.5.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        caseItem.subject ?? 'Help & Assistance',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: textSecondary,
                          fontSize: 10.5.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
          loading: () => Text('Support Chat', style: AppTextStyles.heading3.copyWith(fontSize: 14.sp)),
          error: (_, _) => Text('Support Ticket', style: AppTextStyles.heading3.copyWith(fontSize: 14.sp)),
        ),
        actions: [
          IconButton(
            onPressed: _showTimelineOverviewSheet,
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedTime02,
              color: AppColors.primary,
              size: 20.sp,
            ),
            tooltip: 'Timeline History',
          ),
          PopupMenuButton<String>(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedMoreVertical,
              color: textPrimary,
              size: 20.sp,
            ),
            color: surfaceColor,
            onSelected: (val) {
              if (val == 'refresh') _refreshAll();
              if (val == 'timeline') _showTimelineOverviewSheet();
              if (val == 'toggle_status') {
                final isClosed = detailAsync.value?.status?.toUpperCase() == 'CLOSED' ||
                    detailAsync.value?.status?.toUpperCase() == 'RESOLVED';
                _toggleCaseStatus(isClosed);
              }
            },
            itemBuilder: (ctx) => [
              PopupMenuItem(
                value: 'timeline',
                child: Row(
                  children: [
                    HugeIcon(icon: HugeIcons.strokeRoundedTime02, size: 16.sp, color: AppColors.primary),
                    SizedBox(width: 8.w),
                    const Text('View Timeline'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    HugeIcon(icon: HugeIcons.strokeRoundedRefresh, size: 16.sp, color: textPrimary),
                    SizedBox(width: 8.w),
                    const Text('Refresh Chat'),
                  ],
                ),
              ),
              if (detailAsync.value != null)
                PopupMenuItem(
                  value: 'toggle_status',
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedCheckmarkCircle02,
                        size: 16.sp,
                        color: (detailAsync.value?.status?.toUpperCase() == 'CLOSED' ||
                                detailAsync.value?.status?.toUpperCase() == 'RESOLVED')
                            ? AppColors.primary
                            : AppColors.error,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        (detailAsync.value?.status?.toUpperCase() == 'CLOSED' ||
                                detailAsync.value?.status?.toUpperCase() == 'RESOLVED')
                            ? 'Reopen Ticket'
                            : 'Close Ticket',
                      ),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(width: 4.w),
        ],
      ),
      body: detailAsync.when(
        data: (caseItem) {
          final isClosed = (caseItem.status?.toUpperCase() == 'CLOSED' ||
              caseItem.status?.toUpperCase() == 'RESOLVED' ||
              caseItem.status?.toUpperCase() == 'CANCELLED');
          final canSend = !isClosed &&
              !_isSending &&
              (_messageController.text.trim().isNotEmpty || _selectedAttachmentFile != null);

          return Column(
            children: [
              _buildCollapsibleTicketBanner(
                caseItem: caseItem,
                isDark: isDark,
                surfaceColor: surfaceColor,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refreshAll,
                  color: AppColors.primary,
                  child: messagesAsync.when(
                    data: (messages) {
                      if (messages.isEmpty) {
                        return _buildEmptyChatState(
                          isDark: isDark,
                          textPrimary: textPrimary,
                          textSecondary: textSecondary,
                        );
                      }

                      return ListView.separated(
                        controller: _messagesScrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        itemCount: messages.length,
                        separatorBuilder: (context, index) => SizedBox(height: 8.h),
                        itemBuilder: (context, index) {
                          final msg = messages[index];
                          final isCustomer = (msg.senderType?.toUpperCase() == 'CUSTOMER' ||
                              msg.senderType?.toUpperCase() == 'USER');

                          return _ChatMessageBubble(
                            message: msg,
                            isCustomer: isCustomer,
                            formattedDate: _formatDate(msg.createdAt),
                            isDark: isDark,
                            surfaceColor: surfaceColor,
                            borderColor: borderColor,
                            textPrimary: textPrimary,
                            textSecondary: textSecondary,
                            onAttachFile: () => _attachFileToSpecificMessage(msg.id!),
                          ).animate(key: ValueKey(msg.id ?? index.toString())).fade(duration: 180.ms).slideY(
                                begin: 0.05,
                                duration: 180.ms,
                                curve: Curves.easeOut,
                              );
                        },
                      );
                    },
                    loading: () => _buildShimmerChatFeed(isDark, surfaceColor),
                    error: (err, stack) => _buildErrorState(
                      err.toString(),
                      isDark,
                      textPrimary,
                      textSecondary,
                    ),
                  ),
                ),
              ),

              if (_selectedAttachmentFile != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  color: isDark ? const Color(0xFF22252D) : const Color(0xFFEFF6FF),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedFile01,
                          size: 15.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedAttachmentName ?? 'Attachment',
                              style: AppTextStyles.label.copyWith(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (_selectedAttachmentSize != null)
                              Text(
                                _formatFileSize(_selectedAttachmentSize!),
                                style: AppTextStyles.bodySmall.copyWith(
                                  fontSize: 9.5.sp,
                                  color: textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _clearSelectedAttachment,
                        icon: Icon(
                          Icons.cancel,
                          size: 18.sp,
                          color: AppColors.error,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ).animate().fade(duration: 150.ms).slideY(begin: 0.2, duration: 150.ms),

              Container(
                padding: EdgeInsets.only(left: 8.w, right: 8.w, top: 4.h, bottom: 4.h),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  border: Border(top: BorderSide(color: borderColor, width: 1.w)),
                ),
                child: SafeArea(
                  top: false,
                  bottom: false,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: isClosed ? null : _showAttachmentOptions,
                        icon: HugeIcon(
                          icon: HugeIcons.strokeRoundedAttachment01,
                          color: isClosed ? textSecondary : AppColors.primary,
                          size: 19.sp,
                        ),
                        tooltip: 'Attach File',
                        padding: EdgeInsets.all(4.w),
                        constraints: const BoxConstraints(),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          enabled: !isClosed && !_isSending,
                          maxLines: 4,
                          minLines: 1,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: textPrimary,
                            fontSize: 12.5.sp,
                          ),
                          decoration: InputDecoration(
                            hintText: isClosed
                                ? 'This ticket is closed'
                                : 'Type your message...',
                            hintStyle: AppTextStyles.bodySmall.copyWith(
                              color: textSecondary,
                              fontSize: 12.sp,
                            ),
                            fillColor: isDark ? const Color(0xFF242730) : const Color(0xFFF3F5F8),
                            filled: true,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 7.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.r),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: canSend
                              ? AppColors.primary
                              : Colors.grey.withValues(alpha: 0.25),
                          shape: BoxShape.circle,
                          boxShadow: canSend
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: canSend ? _sendMessageAndAttachment : null,
                            customBorder: const CircleBorder(),
                            child: Padding(
                              padding: EdgeInsets.all(8.w),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedSent,
                                color: canSend ? Colors.white : (isDark ? Colors.white38 : Colors.black26),
                                size: 16.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => _buildShimmerChatFeed(isDark, surfaceColor),
        error: (err, stack) => _buildErrorState(
          err.toString(),
          isDark,
          textPrimary,
          textSecondary,
        ),
      ),
    );
  }

  Widget _buildCollapsibleTicketBanner({
    required SupportCase caseItem,
    required bool isDark,
    required Color surfaceColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final statusStr = caseItem.status ?? 'OPEN';
    final typeStr = caseItem.type?.replaceAll('_', ' ').toUpperCase() ?? 'GENERAL';
    final priorityStr = caseItem.priority?.toUpperCase();

    final statusIsClosed = statusStr.toUpperCase() == 'CLOSED' || statusStr.toUpperCase() == 'RESOLVED';

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(bottom: BorderSide(color: borderColor, width: 1.w)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isHeaderExpanded = !_isHeaderExpanded;
              });
            },
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF262930) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              typeStr,
                              style: AppTextStyles.label.copyWith(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                              ),
                            ),
                          ),
                          if (priorityStr != null && priorityStr.isNotEmpty) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                              decoration: BoxDecoration(
                                color: priorityStr == 'URGENT' || priorityStr == 'HIGH'
                                    ? AppColors.error.withValues(alpha: 0.12)
                                    : (isDark ? const Color(0xFF262930) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'PRIORITY: $priorityStr',
                                style: AppTextStyles.label.copyWith(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.w600,
                                  color: priorityStr == 'URGENT' || priorityStr == 'HIGH'
                                      ? AppColors.error
                                      : textSecondary,
                                ),
                              ),
                            ),
                          ],
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.5.h),
                            decoration: BoxDecoration(
                              color: statusIsClosed
                                  ? (isDark ? Colors.white10 : const Color(0xFFF0F2F5))
                                  : Colors.blue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              statusStr.replaceAll('_', ' ').toUpperCase(),
                              style: AppTextStyles.label.copyWith(
                                color: statusIsClosed ? textSecondary : Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 9.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isHeaderExpanded ? 'Hide info' : 'Ticket info',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 10.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 2.w),
                      AnimatedRotation(
                        turns: _isHeaderExpanded ? 0.5 : 0.0,
                        duration: const Duration(milliseconds: 200),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedArrowDown01,
                          size: 14.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            child: _isHeaderExpanded
                ? Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(left: 14.w, right: 14.w, bottom: 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(color: borderColor, height: 1.h),
                        SizedBox(height: 8.h),
                        Text(
                          caseItem.subject ?? 'No Subject',
                          style: AppTextStyles.label.copyWith(
                            color: textPrimary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (caseItem.description != null && caseItem.description!.isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            caseItem.description!,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: textSecondary,
                              fontSize: 11.sp,
                              height: 1.35,
                            ),
                          ),
                        ],
                        SizedBox(height: 8.h),
                        InkWell(
                          onTap: _showTimelineOverviewSheet,
                          borderRadius: BorderRadius.circular(6.r),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedTime02,
                                  size: 13.sp,
                                  color: AppColors.primary,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'View Full Timeline & Activity History',
                                  style: AppTextStyles.label.copyWith(
                                    fontSize: 10.5.sp,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentOptionTile({
    required dynamic icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: icon,
              size: 20.sp,
              color: color,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            title,
            style: AppTextStyles.label.copyWith(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChatState({
    required bool isDark,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 40.h),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedBubbleChat,
              size: 38.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 14.h),
          Text(
            'Support Chat Initialized',
            style: AppTextStyles.heading3.copyWith(
              color: textPrimary,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Type a message or attach a document below. A customer support representative will review and respond shortly.',
            style: AppTextStyles.bodySmall.copyWith(
              color: textSecondary,
              fontSize: 12.sp,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerChatFeed(bool isDark, Color surfaceColor) {
    final baseColor = isDark ? const Color(0xFF262930) : Colors.grey[300]!;
    final highlightColor = isDark ? const Color(0xFF383C45) : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: 5,
        separatorBuilder: (context, index) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          final isRight = index % 2 == 0;
          return Align(
            alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 190.w,
              height: 46.h,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );
        },
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
              size: 38.sp,
              color: AppColors.error,
            ),
            SizedBox(height: 12.h),
            Text(
              'Failed to load messages',
              style: AppTextStyles.heading3.copyWith(
                color: textPrimary,
                fontSize: 14.5.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              error,
              style: AppTextStyles.bodySmall.copyWith(
                color: textSecondary,
                fontSize: 11.5.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: _refreshAll,
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedRefresh,
                size: 15.sp,
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

class _ChatMessageBubble extends StatelessWidget {
  final SupportCaseMessage message;
  final bool isCustomer;
  final String formattedDate;
  final bool isDark;
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onAttachFile;

  const _ChatMessageBubble({
    required this.message,
    required this.isCustomer,
    required this.formattedDate,
    required this.isDark,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onAttachFile,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleBg = isCustomer
        ? AppColors.primary
        : (isDark ? const Color(0xFF22252D) : const Color(0xFFF1F5F9));
    final textColor = isCustomer ? Colors.white : textPrimary;
    final subTextColor = isCustomer ? Colors.white70 : textSecondary;

    return Align(
      alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.78.sw),
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: bubbleBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14.r),
            topRight: Radius.circular(14.r),
            bottomLeft: Radius.circular(isCustomer ? 14.r : 3.r),
            bottomRight: Radius.circular(isCustomer ? 3.r : 14.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1.5),
            ),
          ],
          border: isCustomer ? null : Border.all(color: borderColor, width: 1.w),
        ),
        child: Column(
          crossAxisAlignment:
              isCustomer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCustomer) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: HugeIcon(
                      icon: HugeIcons.strokeRoundedCustomerSupport,
                      size: 10.sp,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    'Support Agent',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 9.5.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
            ],
            if (message.body != null && message.body!.isNotEmpty)
              Text(
                message.body!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: textColor,
                  fontSize: 12.5.sp,
                  height: 1.32,
                ),
              ),
            SizedBox(height: 4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedDate,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 8.5.sp,
                    color: subTextColor,
                  ),
                ),
                if (isCustomer) ...[
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.done_all,
                    size: 11.sp,
                    color: Colors.white70,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineOverviewSheet extends ConsumerWidget {
  final String caseId;
  final String Function(DateTime?) formatDate;

  const _TimelineOverviewSheet({
    required this.caseId,
    required this.formatDate,
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
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timelineAsync = ref.watch(caseTimelineProvider(caseId));

    final surfaceColor = isDark ? const Color(0xFF1A1D24) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2C2F36) : const Color(0xFFE5E7EB);
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(height: 12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    HugeIcon(
                      icon: HugeIcons.strokeRoundedTime02,
                      size: 18.sp,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Ticket Timeline History',
                      style: AppTextStyles.heading3.copyWith(
                        color: textPrimary,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, size: 20.sp, color: textSecondary),
                ),
              ],
            ),
          ),
          Divider(color: borderColor, height: 1),

          Expanded(
            child: timelineAsync.when(
              data: (items) {
                if (items.isEmpty) {
                  return Center(
                    child: Text(
                      'No timeline history available',
                      style: AppTextStyles.bodyMedium.copyWith(color: textSecondary),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isLast = index == items.length - 1;
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
                                  color: isDark ? const Color(0xFF22252C) : const Color(0xFFF8FAFC),
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
                                        Text(
                                          formatDate(item.timestamp),
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
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator.adaptive()),
              error: (err, stack) => Center(
                child: Text('Error: $err', style: TextStyle(color: AppColors.error)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
