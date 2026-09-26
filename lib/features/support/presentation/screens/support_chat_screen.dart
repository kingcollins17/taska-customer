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
import 'package:seeker_app/core/designs/widgets/confirmation_dialog.dart';
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
    final surfaceColor = isDark ? AppColors.darkBackground : AppColors.surface;
    final tileBgColor = isDark ? Colors.white.withValues(alpha: 0.04) : AppColors.surface;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E7EB);
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;

    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Attach File or Photo',
                style: AppTextStyles.heading3.copyWith(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              SizedBox(height: 14.h),
              _buildSimpleAttachmentTile(
                icon: HugeIcons.strokeRoundedCamera01,
                title: 'Take Photo',
                subtitle: 'Use camera to capture image',
                surfaceColor: tileBgColor,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final photo = await picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    _setAttachmentFile(File(photo.path), photo.name);
                  }
                },
              ),
              SizedBox(height: 10.h),
              _buildSimpleAttachmentTile(
                icon: HugeIcons.strokeRoundedImage01,
                title: 'Choose from Gallery',
                subtitle: 'Select photos or media files',
                surfaceColor: tileBgColor,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () async {
                  Navigator.pop(ctx);
                  final picker = ImagePicker();
                  final image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    _setAttachmentFile(File(image.path), image.name);
                  }
                },
              ),
              SizedBox(height: 10.h),
              _buildSimpleAttachmentTile(
                icon: HugeIcons.strokeRoundedFile01,
                title: 'Upload Document',
                subtitle: 'Select PDF, DOC, or file attachment',
                surfaceColor: tileBgColor,
                borderColor: borderColor,
                textPrimary: textPrimary,
                textSecondary: textSecondary,
                onTap: () async {
                  Navigator.pop(ctx);
                  final result = await FilePicker.pickFiles();
                  if (result != null && result.files.single.path != null) {
                    final f = File(result.files.single.path!);
                    _setAttachmentFile(f, result.files.single.name);
                  }
                },
              ),
              SizedBox(height: 12.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleAttachmentTile({
    required dynamic icon,
    required String title,
    required String subtitle,
    required Color surfaceColor,
    required Color borderColor,
    required Color textPrimary,
    required Color textSecondary,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: borderColor, width: 1.w),
          ),
          child: Row(
            children: [
              Container(
                width: 38.w,
                height: 38.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: HugeIcon(
                    icon: icon,
                    size: 20.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.label.copyWith(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.sp,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                size: 16.sp,
                color: textSecondary,
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
      _messageController.clear();
      setState(() {
        _isSending = false;
        _isUploadingFile = false;
      });
      ref.read(caseMessagesProvider(widget.caseId).notifier).refresh();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
        _isUploadingFile = false;
      });
      context.showMessage(e.toString().replaceAll('Exception: ', ''), type: MessageType.error);
    }
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final detailAsync = ref.watch(caseDetailProvider(widget.caseId));
    final messagesAsync = ref.watch(caseMessagesProvider(widget.caseId));

    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor = isDark ? AppColors.darkBackground : AppColors.surface;
    final borderColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06);
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: const CustomBackButton(),
        titleSpacing: 0,
        title: detailAsync.when(
          data: (caseItem) {
            final caseNum = caseItem.caseNumber != null && caseItem.caseNumber!.isNotEmpty
                ? '#${caseItem.caseNumber}'
                : '#${caseItem.id?.substring(0, 8).toUpperCase()}';
            final typeStr = caseItem.type?.replaceAll('_', ' ').toUpperCase() ?? 'GENERAL';
            final priorityStr = caseItem.priority?.toUpperCase();

            return Column(
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
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
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
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        caseItem.subject ?? 'Help & Assistance',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: textSecondary,
                          fontSize: 11.sp,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        typeStr,
                        style: AppTextStyles.label.copyWith(
                          fontSize: 8.5.sp,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                        ),
                      ),
                    ),
                    if (priorityStr != null && priorityStr.isNotEmpty) ...[
                      SizedBox(width: 4.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                        decoration: BoxDecoration(
                          color: priorityStr == 'URGENT' || priorityStr == 'HIGH'
                              ? AppColors.error.withValues(alpha: 0.12)
                              : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFF1F5F9)),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          priorityStr,
                          style: AppTextStyles.label.copyWith(
                            fontSize: 8.5.sp,
                            fontWeight: FontWeight.w600,
                            color: priorityStr == 'URGENT' || priorityStr == 'HIGH'
                                ? AppColors.error
                                : textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            );
          },
          loading: () => Text('Support Chat', style: AppTextStyles.heading3.copyWith(fontSize: 15.sp, color: textPrimary)),
          error: (_, _) => Text('Support Ticket', style: AppTextStyles.heading3.copyWith(fontSize: 15.sp, color: textPrimary)),
        ),
        actions: [
          if (detailAsync.value != null)
            PopupMenuButton<String>(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedMoreVertical,
                color: textPrimary,
                size: 20.sp,
              ),
              color: isDark ? AppColors.darkBackground : AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(color: borderColor, width: 1.w),
              ),
              onSelected: (val) {
                if (val == 'toggle_status') {
                  final isClosed = detailAsync.value?.status?.toUpperCase() == 'CLOSED' ||
                      detailAsync.value?.status?.toUpperCase() == 'RESOLVED';
                  _toggleCaseStatus(isClosed);
                }
              },
              itemBuilder: (ctx) => [
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
                        style: AppTextStyles.label.copyWith(
                          fontSize: 12.sp,
                          color: textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          SizedBox(width: 6.w),
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
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        itemCount: messages.length,
                        separatorBuilder: (context, index) => SizedBox(height: 12.h),
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
                          ).animate(key: ValueKey(msg.id ?? index.toString())).fade(duration: 180.ms).slideY(
                                begin: 0.04,
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
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white.withValues(alpha: 0.04) : const Color(0xFFEFF6FF),
                    border: Border(top: BorderSide(color: borderColor, width: 1.w)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: HugeIcon(
                          icon: HugeIcons.strokeRoundedFile01,
                          size: 16.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _selectedAttachmentName ?? 'Attachment',
                              style: AppTextStyles.label.copyWith(
                                fontSize: 12.sp,
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
                                  fontSize: 10.sp,
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
                          size: 20.sp,
                          color: AppColors.error,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ).animate().fade(duration: 150.ms).slideY(begin: 0.2, duration: 150.ms),

              // Enhanced Spacious Input Area
              Container(
                padding: EdgeInsets.only(
                  left: 12.w,
                  right: 12.w,
                  top: 10.h,
                  bottom: 12.h,
                ),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  border: Border(top: BorderSide(color: borderColor, width: 1.w)),
                ),
                child: SafeArea(
                  top: false,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: (isClosed || _isSending) ? null : _showAttachmentOptions,
                            borderRadius: BorderRadius.circular(20.r),
                            child: Padding(
                              padding: EdgeInsets.all(8.w),
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedAttachment01,
                                color: (isClosed || _isSending) ? textSecondary : AppColors.primary,
                                size: 22.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          enabled: !isClosed && !_isSending,
                          maxLines: 5,
                          minLines: 1,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: textPrimary,
                            fontSize: 13.5.sp,
                            height: 1.35,
                          ),
                          decoration: InputDecoration(
                            hintText: isClosed
                                ? 'This ticket is closed'
                                : (_isSending ? 'Sending message...' : 'Type your message...'),
                            hintStyle: AppTextStyles.bodySmall.copyWith(
                              color: textSecondary,
                              fontSize: 13.sp,
                            ),
                            fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF3F5F8),
                            filled: true,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24.r),
                              borderSide: BorderSide(
                                color: borderColor,
                                width: 1.w,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24.r),
                              borderSide: BorderSide(
                                color: borderColor,
                                width: 1.w,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24.r),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 1.5.w,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          curve: Curves.easeInOut,
                          decoration: BoxDecoration(
                            color: (canSend || _isSending)
                                ? AppColors.primary
                                : (isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE5E7EB)),
                            shape: BoxShape.circle,
                            boxShadow: canSend
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: (canSend && !_isSending) ? _sendMessageAndAttachment : null,
                              customBorder: const CircleBorder(),
                              child: Padding(
                                padding: EdgeInsets.all(10.w),
                                child: _isSending
                                    ? SizedBox(
                                        width: 18.w,
                                        height: 18.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : HugeIcon(
                                        icon: HugeIcons.strokeRoundedSent,
                                        color: canSend
                                            ? Colors.white
                                            : (isDark ? Colors.white38 : Colors.black26),
                                        size: 18.sp,
                                      ),
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
    final baseColor = isDark ? Colors.white.withValues(alpha: 0.04) : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        padding: EdgeInsets.all(16.w),
        itemCount: 5,
        separatorBuilder: (context, index) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final isRight = index % 2 == 0;
          return Align(
            alignment: isRight ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 210.w,
              height: 52.h,
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(14.r),
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

  const _ChatMessageBubble({
    required this.message,
    required this.isCustomer,
    required this.formattedDate,
    required this.isDark,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final bubbleBg = isCustomer
        ? AppColors.primary
        : (isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF3F4F6));
    final textColor = isCustomer ? Colors.white : textPrimary;
    final subTextColor = isCustomer ? Colors.white70 : textSecondary;

    return Align(
      alignment: isCustomer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: 0.78.sw),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: bubbleBg,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isCustomer ? 16.r : 4.r),
            bottomRight: Radius.circular(isCustomer ? 4.r : 16.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: isCustomer
              ? null
              : Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : const Color(0xFFE2E8F0),
                  width: 1.w,
                ),
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
                      size: 11.sp,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    'Support Team',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5.h),
            ],
            if (message.body != null && message.body!.isNotEmpty)
              Text(
                message.body!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: textColor,
                  fontSize: 13.sp,
                  height: 1.38,
                ),
              ),
            SizedBox(height: 4.h),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedDate,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 9.sp,
                    color: subTextColor,
                  ),
                ),
                if (isCustomer) ...[
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.done_all,
                    size: 12.sp,
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
