import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/designs/widgets/app_search_bar.dart';
import 'package:seeker_app/core/designs/widgets/current_location.dart';
import 'package:seeker_app/core/designs/widgets/primary_button.dart';
import 'package:seeker_app/core/providers/task_providers.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import 'package:seeker_app/features/task/presentation/widgets/task_card.dart';
import 'package:seeker_app/features/task/presentation/widgets/task_card_shimmer.dart';

const Map<String, String> _statusDisplayNames = {
  'DRAFT': 'Draft',
  'UNDER_REVIEW': 'Under Review',
  'OPEN': 'Open',
  'SEARCHING': 'Searching',
  'ASSIGNED': 'Assigned',
  'IN_PROGRESS': 'In Progress',
  'COMPLETED': 'Completed',
  'CANCELLED': 'Cancelled',
  'NO_MATCH': 'No Match',
};

class TasksScreen extends ConsumerStatefulWidget {
  final List<String>? initialStatuses;

  const TasksScreen({super.key, this.initialStatuses});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    if (widget.initialStatuses != null && widget.initialStatuses!.isNotEmpty) {
      final formattedStatuses = widget.initialStatuses!
          .map((s) => s.toUpperCase().replaceAll(' ', '_'))
          .toList();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(taskStatusFilterProvider.notifier).state = formattedStatuses;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(tasksProvider.notifier).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref
          .read(tasksProvider.notifier)
          .setFilters(search: query.isNotEmpty ? query : null);
    });
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _TaskStatusFilterSheet(),
    );
  }

  void _removeStatusFilter(String statusKey) {
    final current = List<String>.from(ref.read(taskStatusFilterProvider));
    current.remove(statusKey);
    ref.read(taskStatusFilterProvider.notifier).state = current;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final tasksAsync = ref.watch(tasksProvider);
    final selectedStatuses = ref.watch(taskStatusFilterProvider);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'My Tasks',
                    style: AppTextStyles.heading2.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const CurrentLocation(),
                ],
              ),
            ),

            // Search Bar & Filter Button Row
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: Row(
                children: [
                  Expanded(
                    child: AppSearchBar(
                      controller: _searchController,
                      onChanged: _onSearchChanged,
                      hintText: 'Search tasks...',
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  _FilterButton(
                    activeCount: selectedStatuses.length,
                    onTap: () => _showFilterBottomSheet(context),
                  ),
                ],
              ),
            ),

            // Active Filter Badges Bar
            if (selectedStatuses.isNotEmpty) ...[
              SizedBox(height: 8.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    ...selectedStatuses.map((statusKey) {
                      final displayName = _statusDisplayNames[statusKey] ??
                          statusKey
                              .replaceAll('_', ' ')
                              .toLowerCase()
                              .split(' ')
                              .map((w) => w.isNotEmpty
                                  ? '${w[0].toUpperCase()}${w.substring(1)}'
                                  : '')
                              .join(' ');
                      return Padding(
                        padding: EdgeInsets.only(right: 6.w),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary
                                .withValues(alpha: isDark ? 0.2 : 0.1),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: AppColors.primary
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                displayName,
                                style: GoogleFonts.inter(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              GestureDetector(
                                onTap: () => _removeStatusFilter(statusKey),
                                child: Icon(
                                  Icons.close,
                                  size: 14.sp,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    GestureDetector(
                      onTap: () =>
                          ref.read(taskStatusFilterProvider.notifier).state = [],
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        child: Text(
                          'Reset',
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? Colors.white54
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 8.h),

            // Task List
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  await ref.read(tasksProvider.notifier).refresh();
                },
                child: tasksAsync.when(
                  data: (tasks) {
                    if (tasks.isEmpty) {
                      return ListView(
                        children: [
                          SizedBox(height: 80.h),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedTask01,
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.grey.shade300,
                                  size: 64.sp,
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  'No tasks found',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: isDark
                                        ? Colors.white54
                                        : AppColors.textSecondary,
                                    fontSize: 15.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.h,
                      ),
                      itemCount:
                          tasks.length + 1, // +1 for loading indicator at bottom
                      itemBuilder: (context, index) {
                        if (index == tasks.length) {
                          if (ref.read(tasksProvider.notifier).hasMore) {
                            return const TaskCardShimmer();
                          }
                          return const SizedBox.shrink();
                        }

                        final task = tasks[index];
                        return TaskCard(
                          task: task,
                          onTap: () {
                            if (task.id != null) {
                              context.pushNamed(
                                RouteNames.taskDetail.name,
                                pathParameters: {'taskId': task.id!},
                              );
                            }
                          },
                        );
                      },
                    );
                  },
                  loading: () => ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 4.h,
                    ),
                    itemCount: 8,
                    itemBuilder: (context, index) => const TaskCardShimmer(),
                  ),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HugeIcon(
                            icon: HugeIcons.strokeRoundedAlert01,
                            color: AppColors.error,
                            size: 40.sp,
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'Oops, something went wrong',
                            style: AppTextStyles.heading3.copyWith(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            error.toString(),
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: isDark
                                  ? Colors.white54
                                  : AppColors.textSecondary,
                              fontSize: 13.sp,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          ElevatedButton(
                            onPressed: () {
                              ref.read(tasksProvider.notifier).refresh();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: 20.w,
                                vertical: 10.h,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final int activeCount;
  final VoidCallback onTap;

  const _FilterButton({
    required this.activeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isActive = activeCount > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: 48.h,
        height: 48.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary
              : (isDark ? AppColors.darkerBackground : Colors.white),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isActive
                ? AppColors.primary
                : (isDark ? Colors.white12 : Colors.grey.shade200),
            width: 1,
          ),
          boxShadow: isDark || isActive
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedFilter,
              color: isActive
                  ? Colors.white
                  : (isDark ? Colors.white70 : AppColors.textPrimary),
              size: 20.sp,
            ),
            if (isActive)
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.all(3.r),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  constraints: BoxConstraints(
                    minWidth: 14.w,
                    minHeight: 14.w,
                  ),
                  child: Center(
                    child: Text(
                      '$activeCount',
                      style: GoogleFonts.inter(
                        color: AppColors.primary,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TaskStatusFilterSheet extends ConsumerStatefulWidget {
  const _TaskStatusFilterSheet();

  @override
  ConsumerState<_TaskStatusFilterSheet> createState() =>
      __TaskStatusFilterSheetState();
}

class __TaskStatusFilterSheetState
    extends ConsumerState<_TaskStatusFilterSheet> {
  late Set<String> _selectedKeys;

  @override
  void initState() {
    super.initState();
    _selectedKeys = Set<String>.from(ref.read(taskStatusFilterProvider));
  }

  void _toggleKey(String key) {
    setState(() {
      if (_selectedKeys.contains(key)) {
        _selectedKeys.remove(key);
      } else {
        _selectedKeys.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final sheetBg = isDark ? AppColors.darkerBackground : AppColors.surface;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Title & Reset Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Tasks',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              if (_selectedKeys.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _selectedKeys.clear();
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Reset',
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),

          Text(
            'Status',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 12.h),

          // Wrap Filter Chips
          Wrap(
            spacing: 8.w,
            runSpacing: 10.h,
            children: _statusDisplayNames.entries.map((entry) {
              final key = entry.key;
              final displayName = entry.value;
              final isSelected = _selectedKeys.contains(key);

              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedTick01,
                        color: Colors.white,
                        size: 14.sp,
                      ),
                      SizedBox(width: 6.w),
                    ],
                    Text(
                      displayName,
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: isSelected
                            ? Colors.white
                            : (isDark
                                ? Colors.white70
                                : AppColors.textPrimary),
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                selected: isSelected,
                onSelected: (_) => _toggleKey(key),
                selectedColor: AppColors.primary,
                backgroundColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.shade100,
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
                visualDensity: VisualDensity.compact,
                showCheckmark: false,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primary
                        : (isDark
                            ? Colors.white12
                            : Colors.grey.shade300),
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 32.h),

          // Apply Button
          PrimaryButton(
            text: _selectedKeys.isEmpty
                ? 'Show All Tasks'
                : 'Apply Filters (${_selectedKeys.length})',
            onPressed: () {
              ref.read(taskStatusFilterProvider.notifier).state =
                  _selectedKeys.toList();
              Navigator.pop(context);
            },
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}
