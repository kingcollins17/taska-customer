import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shimmer/shimmer.dart';

import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/services_provider.dart';
import 'package:seeker_app/core/providers/task_creation_provider.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import 'package:seeker_app/core/utils/category_icon_helper.dart';

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
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
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

  Future<void> _handleCategoryTap(ServiceCategory category) async {
    if (category.id == null) return;

    try {
      await ref
          .read(taskCreationProvider.notifier)
          .updateCategory(category.id!);
      if (mounted) {
        context.pushNamed(
          RouteNames.taskService.name,
          queryParameters: {'categoryId': category.id!},
        );
      }
    } catch (err) {
      if (mounted) {
        context.showMessage(
          (err as Object?).toFriendlyMessage(),
          type: MessageType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final cardColor = isDark ? const Color(0xFF1A1A1E) : Colors.white;

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
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              Text(
                'Browse Categories',
                style: AppTextStyles.heading1.copyWith(
                  fontSize: 22.sp,
                  color: textColor,
                  fontWeight: FontWeight.w700,
                  height: 1.25,
                ),
              ),
              SizedBox(height: 14.h),

              // Search Bar matching ServiceSelectionScreen style
              Container(
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.06),
                  ),
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                  ],
                ),
                child: TextField(
                  onChanged: _onSearchChanged,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: textColor,
                    fontSize: 13.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search categories...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.4)
                          : AppColors.textSecondary.withValues(alpha: 0.6),
                      fontSize: 13.sp,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.5)
                          : AppColors.textSecondary,
                      size: 18.sp,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              SizedBox(height: 14.h),

              // Compact Category Grid (2 columns)
              Expanded(
                child: categoriesAsync.when(
                  data: (categories) {
                    if (categories.isEmpty) {
                      return AppEmptyStateWidget(
                        compact: true,
                        icon: _searchQuery != null
                            ? Icons.search_off_rounded
                            : Icons.grid_view_rounded,
                        title: _searchQuery != null
                            ? 'No categories match your search'
                            : 'No categories available',
                        subtitle: _searchQuery != null
                            ? 'Try a different search term'
                            : 'Check back later for new categories',
                        actionLabel: _searchQuery != null
                            ? 'Clear Search'
                            : null,
                        onAction: _searchQuery != null
                            ? () => setState(() => _searchQuery = null)
                            : null,
                      );
                    }

                    return GridView.builder(
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.w,
                        mainAxisSpacing: 10.h,
                        childAspectRatio: 1.12,
                      ),
                      itemCount: categories.length,
                      padding: EdgeInsets.only(bottom: 20.h),
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        return _CategoryCard(
                          category: category,
                          index: index,
                          onTap: () => _handleCategoryTap(category),
                        );
                      },
                    );
                  },
                  loading: () => GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.w,
                      mainAxisSpacing: 10.h,
                      childAspectRatio: 1.12,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return const _CategoryCard(category: null, index: 0);
                    },
                  ),
                  error: (error, _) => AppErrorWidget(
                    compact: true,
                    error: error,
                    title: 'Failed to load categories',
                    onRetry: () =>
                        ref.read(categoriesProvider(_searchQuery).notifier),
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

// ── Vibrant Card Accent Colors ──────────────────────────────────────────────

const List<Color> _accentColors = [
  Color(0xFFA855F7), // Purple
  Color(0xFFF97316), // Orange
  Color(0xFF10B981), // Emerald
  Color(0xFF3B82F6), // Blue
  Color(0xFFEC4899), // Pink
  Color(0xFF06B6D4), // Cyan
  Color(0xFFF59E0B), // Amber
  Color(0xFF6366F1), // Indigo
];

// ── Compact Grid Category Card ──────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  final ServiceCategory? category;
  final int index;
  final VoidCallback? onTap;

  const _CategoryCard({
    required this.category,
    required this.index,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final cardBg = isDark ? const Color(0xFF1A1A1E) : Colors.white;

    if (category == null) {
      return Shimmer.fromColors(
        baseColor: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.grey[300]!,
        highlightColor: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.grey[100]!,
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12.h,
                    width: 90.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    height: 9.h,
                    width: 60.w,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final icon = getCategoryIcon(category?.name);
    final accentColor = _accentColors[index % _accentColors.length];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18.r),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Vibrant Icon Container + Chevron
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: HugeIcon(
                      icon: icon,
                      color: accentColor,
                      size: 18.sp,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12.sp,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.2),
                  ),
                ],
              ),

              // Bottom Column: Category Name & Subtitle
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category!.name ?? 'Unknown Category',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.heading3.copyWith(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'Explore services',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 10.5.sp,
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.45)
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
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
}
