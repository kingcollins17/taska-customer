import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/designs/widgets/current_location.dart';
import 'package:shimmer/shimmer.dart';

import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seeker_app/core/providers/task_creation_provider.dart';
import 'package:seeker_app/core/providers/services_provider.dart';

class CategorySelectionScreen extends ConsumerStatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  ConsumerState<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState
    extends ConsumerState<CategorySelectionScreen> {
  Timer? _debounceTimer;
  String? _searchQuery;

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1500), () {
      setState(() {
        _searchQuery = query.trim().isEmpty ? null : query.trim();
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final cardColor = isDark ? AppColors.darkerBackground : AppColors.surface;

    final categoriesAsync = ref.watch(categoriesProvider(_searchQuery));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: CustomBackButton(),
        actions: [CurrentLocation()],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text(
                'What do you need help with?',
                style: AppTextStyles.heading1.copyWith(
                  fontSize: 28.sp,
                  color: textColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: TextField(
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Search...',
                    hintStyle: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary.withOpacity(0.5),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: categoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) {
                      return Center(
                        child: Text(
                          'No categories found',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }
                    return GridView.builder(
                      padding: EdgeInsets.only(bottom: 24.h),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12.w,
                        mainAxisSpacing: 12.h,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        IconData icon = Icons.category;
                        
                        if (category.name?.toLowerCase().contains('plumb') == true) {
                          icon = Icons.plumbing;
                        } else if (category.name?.toLowerCase().contains('clean') == true) {
                          icon = Icons.cleaning_services;
                        } else if (category.name?.toLowerCase().contains('electric') == true) {
                          icon = Icons.electrical_services;
                        } else if (category.name?.toLowerCase().contains('mov') == true) {
                          icon = Icons.local_shipping;
                        } else if (category.name?.toLowerCase().contains('beaut') == true) {
                          icon = Icons.face_retouching_natural;
                        } else if (category.name?.toLowerCase().contains('deliver') == true) {
                          icon = Icons.delivery_dining;
                        }

                        return InkWell(
                          onTap: () {
                            if (category.id != null) {
                              ref
                                  .read(taskCreationProvider.notifier)
                                  .updateCategory(category.id!)
                                  .then((_) {
                                    if (!context.mounted) return;
                                    context.pushNamed(
                                      RouteNames.taskService.name,
                                      queryParameters: {
                                        'categoryId': category.id,
                                      },
                                    );
                                  });
                            }
                          },
                          borderRadius: BorderRadius.circular(16.r),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  icon,
                                  color: isDark ? Colors.white : AppColors.primary,
                                  size: 28.sp,
                                ),
                                SizedBox(height: 8.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                                  child: Text(
                                    category.name ?? 'Unknown Category',
                                    textAlign: TextAlign.center,
                                    style: AppTextStyles.heading3.copyWith(
                                      color: isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.textPrimary,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      return Shimmer.fromColors(
                        baseColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[300]!,
                        highlightColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[100]!,
                        child: Container(
                          decoration: BoxDecoration(
                            color: isDark ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                        ),
                      );
                    },
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading categories: $error',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
