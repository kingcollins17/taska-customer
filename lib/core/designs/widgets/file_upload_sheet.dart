import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/providers/file_upload_provider.dart';

/// Bottom sheet widget for testing file uploads and deletions via [FileUploadNotifier].
class FileUploadSheet extends ConsumerStatefulWidget {
  const FileUploadSheet({super.key});

  /// Static helper method to display the file upload bottom sheet.
  static Future<void> upload(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FileUploadSheet(),
    );
  }

  @override
  ConsumerState<FileUploadSheet> createState() => _FileUploadSheetState();
}

class _FileUploadSheetState extends ConsumerState<FileUploadSheet> {
  String? _errorMessage;

  Future<void> _pickAndUploadImages() async {
    setState(() => _errorMessage = null);
    final picker = ImagePicker();
    final images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      final files = images.map((xFile) => File(xFile.path)).toList();
      await ref.read(fileUploadProvider.notifier).uploadMultiple(
        files,
        onError: (err) {
          if (mounted) {
            setState(() => _errorMessage = err);
          }
        },
      );
    }
  }

  Future<void> _pickAndUploadFiles() async {
    setState(() => _errorMessage = null);
    final result = await FilePicker.pickFiles(allowMultiple: true);
    if (result != null && result.files.isNotEmpty) {
      final files =
          result.files
              .map((file) => file.path)
              .whereType<String>()
              .map((path) => File(path))
              .toList();
      await ref.read(fileUploadProvider.notifier).uploadMultiple(
        files,
        onError: (err) {
          if (mounted) {
            setState(() => _errorMessage = err);
          }
        },
      );
    }
  }

  Future<void> _deleteSingleFile(String url) async {
    setState(() => _errorMessage = null);
    await ref.read(fileUploadProvider.notifier).deleteSingleFile(
      url,
      onError: (err) {
        if (mounted) {
          setState(() => _errorMessage = err);
        }
      },
    );
  }

  Future<void> _deleteAllFiles(List<String> urls) async {
    if (urls.isEmpty) return;
    setState(() => _errorMessage = null);
    await ref.read(fileUploadProvider.notifier).deleteFiles(
      urls,
      onError: (err) {
        if (mounted) {
          setState(() => _errorMessage = err);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final uploadState = ref.watch(fileUploadProvider);
    final uploadedUrlsAsync = ref.watch(uploadedFileUrlsProvider);
    final uploadedUrls = (uploadedUrlsAsync.value ?? <String>{}).toList();
    final isLoading = uploadState.isLoading;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Header Title & Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'File Upload Tester',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedCancel01,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Upload single or multiple files to test the Utils API.',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
          ),
          SizedBox(height: 16.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _pickAndUploadImages,
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedImage01,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text('Pick Images'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : _pickAndUploadFiles,
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedFolderAttachment,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  label: const Text('Pick Files'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Loading Indicator
          if (isLoading) ...[
            LinearProgressIndicator(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              color: AppColors.primary,
            ),
            SizedBox(height: 8.h),
            Center(
              child: Text(
                'Processing file request...',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
              ),
            ),
            SizedBox(height: 12.h),
          ],

          // Error Banner
          if (_errorMessage != null) ...[
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  const HugeIcon(
                    icon: HugeIcons.strokeRoundedAlertCircle,
                    color: Colors.red,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.bodySmall.copyWith(color: Colors.red.shade800),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
          ],

          // Uploaded Files Header & Delete All Action
          if (uploadedUrls.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Uploaded Files (${uploadedUrls.length})',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: isLoading ? null : () => _deleteAllFiles(uploadedUrls),
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedDelete02,
                    color: Colors.red,
                    size: 16,
                  ),
                  label: Text('Delete All', style: AppTextStyles.bodySmall.copyWith(color: Colors.red)),
                ),
              ],
            ),
            SizedBox(height: 8.h),
          ],

          // Files List
          Flexible(
            child: uploadedUrls.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Center(
                      child: Text(
                        'No files uploaded yet.',
                        style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: uploadedUrls.length,
                    separatorBuilder: (context, index) => SizedBox(height: 8.h),
                    itemBuilder: (context, index) {
                      final url = uploadedUrls[index];
                      final filename = url.split('/').last;

                      return Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const HugeIcon(
                                icon: HugeIcons.strokeRoundedFile01,
                                color: AppColors.primary,
                                size: 20,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    filename.isEmpty ? 'File #${index + 1}' : filename,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    url,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: Colors.blue,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: isLoading
                                  ? null
                                  : () => _deleteSingleFile(url),
                              icon: const HugeIcon(
                                icon: HugeIcons.strokeRoundedDelete02,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
