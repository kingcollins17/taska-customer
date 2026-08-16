import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/designs/widgets/app_search_bar.dart';
import 'package:seeker_app/core/designs/widgets/current_location.dart';
import 'package:seeker_app/core/providers/task_providers.dart';
import 'package:seeker_app/features/task/presentation/widgets/task_card.dart';
import 'package:seeker_app/features/task/presentation/widgets/task_card_shimmer.dart';

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  final List<String> _statuses = [
    'All',
    'Draft',
    'Open',
    'Assigned',
    'In Progress',
    'Cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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

  void _onStatusChanged(String status) {
    if (status == 'All') {
      ref.read(taskStatusFilterProvider.notifier).state = [];
      return;
    }

    final key = status.toLowerCase().replaceAll(' ', '_');
    final current = List<String>.from(ref.read(taskStatusFilterProvider));

    if (current.contains(key)) {
      current.remove(key);
    } else {
      current.add(key);
    }

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
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const CurrentLocation(),
                ],
              ),
            ),
            // Search Bar
            AppSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              hintText: 'Search tasks...',
            ),

            SizedBox(height: 6.h),

            // Status Chips
            SizedBox(
              height: 32.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: _statuses.length,
                itemBuilder: (context, index) {
                  final status = _statuses[index];
                  final statusKey = status.toLowerCase().replaceAll(' ', '_');
                  final isSelected =
                      (status == 'All' && selectedStatuses.isEmpty) ||
                          selectedStatuses.contains(statusKey);

                  return Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: ChoiceChip(
                      label: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isSelected) ...[
                            HugeIcon(
                              icon: HugeIcons.strokeRoundedTick01,
                              color: Colors.white,
                              size: 13.sp,
                            ),
                            SizedBox(width: 4.w),
                          ],
                          Text(
                            status,
                            style: AppTextStyles.bodySmall.copyWith(
                              fontSize: 12.sp,
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
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      visualDensity: VisualDensity.compact,
                      showCheckmark: false,
                      selected: isSelected,
                      onSelected: (_) => _onStatusChanged(status),
                      selectedColor: AppColors.primary,
                      backgroundColor: isDark
                          ? AppColors.darkerBackground
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primary
                              : (isDark
                                  ? Colors.white24
                                  : Colors.grey.shade300),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),


            SizedBox(height: 6.h),

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
                          tasks.length +
                          1, // +1 for loading indicator at bottom
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
