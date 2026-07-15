import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/designs/app_colors.dart';
import '../../../../core/designs/widgets/primary_button.dart';

class SuccessAttachmentsScreen extends StatefulWidget {
  const SuccessAttachmentsScreen({super.key});

  @override
  State<SuccessAttachmentsScreen> createState() => _SuccessAttachmentsScreenState();
}

class _SuccessAttachmentsScreenState extends State<SuccessAttachmentsScreen> {
  final List<String> _uploads = []; // Mock list of uploads

  void _addUpload(String name) {
    setState(() {
      _uploads.add(name);
    });
    // Simulate upload delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          // You'd typically update status here
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final cardColor = isDark ? AppColors.darkerBackground : AppColors.surface;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '🎉 Your task is live!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Would you like to add photos or documents?',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),
                    
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _addUpload('photo_${DateTime.now().millisecondsSinceEpoch}.jpg'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.add_a_photo, color: AppColors.primary, size: 32),
                                  const SizedBox(height: 8),
                                  Text('Add Photos', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () => _addUpload('document_${DateTime.now().millisecondsSinceEpoch}.pdf'),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.attach_file, color: AppColors.secondary, size: 32),
                                  const SizedBox(height: 8),
                                  Text('Add Files', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Upload List
                    if (_uploads.isNotEmpty) ...[
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Uploading...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._uploads.map((file) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Icon(Icons.insert_drive_file, color: AppColors.textSecondary),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    file,
                                    style: TextStyle(color: textColor, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: null, // Indeterminate to simulate upload
                                    backgroundColor: AppColors.textSecondary.withOpacity(0.2),
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ],
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  PrimaryButton(
                    text: 'View Task Details',
                    onPressed: () {
                      // Navigate to task details or just pop back to home
                      context.go('/');
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      context.go('/');
                    },
                    child: Text(
                      'Skip for now',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
