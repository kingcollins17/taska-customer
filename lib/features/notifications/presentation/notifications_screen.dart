import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:seeker_app/core/core.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animations/animations.dart';
import 'package:seeker_app/core/designs/widgets/custom_back_button.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/notification_providers.dart';

import 'widgets/notifications_filter_row.dart';
import 'widgets/notification_group_header.dart';
import 'widgets/notification_list_item.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  bool _showUnreadOnly = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(notificationsProvider.notifier).loadMore();
    }
  }

  void _markAllRead(List<NotificationItem> items) {
    final unreadIds = items
        .where((i) => i.readAt == null && i.notificationId != null)
        .map((i) => i.notificationId!)
        .toList();
    if (unreadIds.isNotEmpty) {
      context.showLoading();
      ref
          .read(notificationsProvider.notifier)
          .markAsRead(
            unreadIds,
            onSuccess: () {
              context.hideLoading();
            },
            onError: (err) {
              context.hideLoading();
            },
          );
    }
  }

  void _markRead(String id) {
    ref.read(notificationsProvider.notifier).markAsRead([id]);
  }

  String _getGroupTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final itemDate = DateTime(date.year, date.month, date.day);

    if (itemDate == today) {
      return 'Today';
    } else if (itemDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat.yMMMd().format(date);
    }
  }

  List<Widget> _buildGroupedList(List<NotificationItem> items) {
    if (items.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: 60.h),
            child: Text(
              'No notifications found',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ];
    }

    final filteredItems = _showUnreadOnly
        ? items.where((i) => i.readAt == null).toList()
        : items;

    if (filteredItems.isEmpty) {
      return [
        Center(
          child: Padding(
            padding: EdgeInsets.only(top: 60.h),
            child: Text(
              'No unread notifications',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ),
      ];
    }

    final Map<String, List<NotificationItem>> grouped = {};
    for (var item in filteredItems) {
      final title = _getGroupTitle(item.createdAt ?? DateTime.now());
      if (!grouped.containsKey(title)) {
        grouped[title] = [];
      }
      grouped[title]!.add(item);
    }

    final List<Widget> widgets = [];
    for (var entry in grouped.entries) {
      widgets.add(NotificationGroupHeader(title: entry.key));
      widgets.add(SizedBox(height: 12.h));
      widgets.addAll(
        entry.value.map((item) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: NotificationListItem(
              notification: item,
              onTap: () {
                if (item.readAt == null && item.notificationId != null) {
                  _markRead(item.notificationId!);
                }
              },
            ),
          );
        }),
      );
    }

    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: const Text('Notifications'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
        child: ListView(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          children: [
            state.when(
              data: (items) => NotificationsFilterRow(
                showUnreadOnly: _showUnreadOnly,
                onFilterChanged: (val) {
                  setState(() {
                    _showUnreadOnly = val;
                  });
                },
                onMarkAllRead: () => _markAllRead(items),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            SizedBox(height: 8.h),
            state.when(
              data: (items) => PageTransitionSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation, secondaryAnimation) {
                  return SharedAxisTransition(
                    animation: animation,
                    secondaryAnimation: secondaryAnimation,
                    transitionType: SharedAxisTransitionType.horizontal,
                    child: child,
                  );
                },
                child: Column(
                  key: ValueKey<bool>(_showUnreadOnly),
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildGroupedList(items),
                ),
              ),
              loading: () => Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: 12.h,
                          top: index == 0 ? 12.h : 0,
                        ),
                        child: Shimmer.fromColors(
                          baseColor: Colors.white.withValues(alpha: 0.05),
                          highlightColor: Colors.white.withValues(alpha: 0.1),
                          child: Container(
                            height: 80.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 60.h),
                  child: Text(
                    'Error: $err',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            ),
            if (state.isLoading && state.hasValue)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Shimmer.fromColors(
                  baseColor: Colors.white.withValues(alpha: 0.05),
                  highlightColor: Colors.white.withValues(alpha: 0.1),
                  child: Container(
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
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
