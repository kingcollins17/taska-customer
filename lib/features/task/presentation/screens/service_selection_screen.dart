import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/models/service/service.dart' as md;
import 'package:shimmer/shimmer.dart';

import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:seeker_app/core/providers/task_creation_provider.dart';
import 'package:seeker_app/core/providers/services_provider.dart';
import 'package:seeker_app/core/utils/service_icon_helper.dart';

class ServiceSelectionScreen extends ConsumerStatefulWidget {
  final String? categoryId;
  const ServiceSelectionScreen({super.key, this.categoryId});

  @override
  ConsumerState<ServiceSelectionScreen> createState() =>
      _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState
    extends ConsumerState<ServiceSelectionScreen> {
  Timer? _debounceTimer;
  String? _searchQuery;
  String? _selectedCategoryId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(availableServicesProvider(_selectedCategoryId).notifier)
          .loadMore();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _searchQuery = query.trim().isEmpty ? null : query.trim();
      });
    });
  }

  void _onCategorySelected(String? categoryId) {
    if (_selectedCategoryId == categoryId) return;
    setState(() {
      _selectedCategoryId = categoryId;
    });
    if (categoryId != null) {
      ref.read(taskCreationProvider.notifier).updateCategory(categoryId);
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleServiceTap(md.Service service) async {
    if (service.id == null) return;

    try {
      if (service.categoryId != null) {
        await ref
            .read(taskCreationProvider.notifier)
            .updateCategory(service.categoryId!);
      }
      await ref.read(taskCreationProvider.notifier).updateService(service.id!);
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
    final draft = ref.watch(taskCreationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final cardColor = isDark ? const Color(0xFF1A1A1E) : Colors.white;

    final categoriesAsync = ref.watch(categoriesProvider(null));
    final servicesAsync =
        ref.watch(availableServicesProvider(_selectedCategoryId));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: CustomBackButton(),
        actions: [CurrentLocation()],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  Text(
                    'What do you need\nhelp with?',
                    style: AppTextStyles.heading1.copyWith(
                      fontSize: 22.sp,
                      color: textColor,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Search Bar
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
                        hintText: 'Search services...',
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
                  SizedBox(height: 12.h),

                  // Category Horizontal Chips
                  SizedBox(
                    height: 34.h,
                    child: categoriesAsync.when(
                      data: (categories) {
                        return ListView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          children: [
                            _CategoryChip(
                              label: 'All',
                              isSelected: _selectedCategoryId == null,
                              onTap: () => _onCategorySelected(null),
                            ),
                            ...categories.map(
                              (cat) => Padding(
                                padding: EdgeInsets.only(left: 6.w),
                                child: _CategoryChip(
                                  label: cat.name ?? 'Unknown',
                                  isSelected:
                                      _selectedCategoryId == cat.id,
                                  onTap: () =>
                                      _onCategorySelected(cat.id),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                      loading: () => ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: 5,
                        separatorBuilder: (_, _) => SizedBox(width: 6.w),
                        itemBuilder: (context, index) {
                          return Shimmer.fromColors(
                            baseColor: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.grey[300]!,
                            highlightColor: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : Colors.grey[100]!,
                            child: Container(
                              width: 72.w,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                          );
                        },
                      ),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Service Grid (2 Columns, inspired by design ref)
                  Expanded(
                    child: servicesAsync.when(
                      data: (services) {
                        final filtered = _searchQuery != null
                            ? services
                                .where((s) =>
                                    s.name?.toLowerCase().contains(
                                          _searchQuery!.toLowerCase(),
                                        ) ??
                                    false)
                                .toList()
                            : services;

                        if (filtered.isEmpty) {
                          return AppEmptyStateWidget(
                            compact: true,
                            icon: _searchQuery != null
                                ? Icons.search_off_rounded
                                : Icons.explore_off_rounded,
                            title: _searchQuery != null
                                ? 'No matches found'
                                : 'No services nearby',
                            subtitle: _searchQuery != null
                                ? 'Try a different search term or browse all services'
                                : 'There are no services available in your area right now',
                            actionLabel:
                                _searchQuery != null ? 'Clear Search' : null,
                            onAction: _searchQuery != null
                                ? () => setState(() => _searchQuery = null)
                                : null,
                          );
                        }
                        return GridView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10.w,
                            mainAxisSpacing: 10.h,
                            childAspectRatio: 1.12,
                          ),
                          itemCount: filtered.length,
                          padding: EdgeInsets.only(
                            bottom: (draft.value?.serviceId != null)
                                ? 90.h
                                : 20.h,
                          ),
                          itemBuilder: (context, index) {
                            final service = filtered[index];
                            return _ServiceCard(
                              service: service,
                              index: index,
                              isSelected:
                                  service.id == draft.value?.serviceId,
                              onTap: () => _handleServiceTap(service),
                            );
                          },
                        );
                      },
                      loading: () => GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10.w,
                          mainAxisSpacing: 10.h,
                          childAspectRatio: 1.12,
                        ),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return const _ServiceCard(
                            service: null,
                            index: 0,
                          );
                        },
                      ),
                      error: (error, _) => AppErrorWidget(
                        compact: true,
                        error: error,
                        title: 'Failed to load services',
                        onRetry: () => ref
                            .read(availableServicesProvider(
                                    _selectedCategoryId)
                                .notifier)
                            .refresh(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Continue Button
            if (servicesAsync.hasValue && draft.value?.serviceId != null)
              Positioned(
                bottom: 16.h,
                left: 20.w,
                right: 20.w,
                child: PrimaryButton(
                  text: 'Continue',
                  onPressed: () {
                    final selectedService =
                        servicesAsync.value!.firstWhere(
                      (s) => s.id == draft.value!.serviceId,
                    );
                    context.pushNamed(
                      RouteNames.taskDescription.name,
                      queryParameters: {
                        'service': selectedService.name ?? '',
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Category Chip ──────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.black.withValues(alpha: 0.06)),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontSize: 12.sp,
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? Colors.white.withValues(alpha: 0.8)
                      : AppColors.textSecondary),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Vibrant Card Accent Palette ─────────────────────────────────────────────

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

// ── Compact Grid Service Card ───────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  final md.Service? service;
  final int index;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ServiceCard({
    required this.service,
    required this.index,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final cardBg = isDark ? const Color(0xFF1A1A1E) : Colors.white;

    if (service == null) {
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

    final isAvailable = service!.isAvailable ?? true;
    final providerCount = service!.providerCount ?? 0;
    final icon = getServiceIcon(service?.name);
    final accentColor = _accentColors[index % _accentColors.length];

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: !isAvailable ? 0.45 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18.r),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: isDark ? 0.20 : 0.08)
                  : cardBg,
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? Colors.white.withValues(alpha: 0.07)
                        : Colors.black.withValues(alpha: 0.05)),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: [
                if (!isDark)
                  BoxShadow(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: isSelected ? 12 : 6,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Row: Vibrant Icon Container + Selection Check / Status Dot
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
                    if (isSelected)
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 12.sp,
                        ),
                      )
                    else
                      Container(
                        width: 7.w,
                        height: 7.w,
                        margin: EdgeInsets.only(top: 4.h, right: 2.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isAvailable ? Colors.green : Colors.redAccent,
                          boxShadow: [
                            BoxShadow(
                              color: (isAvailable
                                      ? Colors.green
                                      : Colors.redAccent)
                                  .withValues(alpha: 0.35),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                // Bottom Column: Title & Provider Count/Status Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      service!.name ?? 'Unknown Service',
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
                      providerCount > 0
                          ? '$providerCount pro${providerCount == 1 ? '' : 's'} nearby'
                          : (isAvailable ? 'Available' : 'Unavailable'),
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
      ),
    );
  }
}
