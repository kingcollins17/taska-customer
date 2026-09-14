import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/designs/widgets/custom_back_button.dart';
import 'package:seeker_app/core/designs/widgets/primary_button.dart';
import 'package:seeker_app/core/models/payout/payout_models.dart';
import 'package:seeker_app/core/providers/payout_providers.dart';
import 'package:seeker_app/core/utils/num_extension.dart';
import 'package:shimmer/shimmer.dart';

const Map<String, String> _payoutStatusDisplayNames = {
  'PENDING': 'Pending',
  'CUSTOMER_PAID': 'Customer Paid',
  'TRANSFER_INITIATED': 'Transfer Initiated',
  'COMPLETED': 'Completed',
  'CANCELLED': 'Cancelled',
  'FAILED': 'Failed',
};

class PayoutsListScreen extends ConsumerStatefulWidget {
  const PayoutsListScreen({super.key});

  @override
  ConsumerState<PayoutsListScreen> createState() => _PayoutsListScreenState();
}

class _PayoutsListScreenState extends ConsumerState<PayoutsListScreen> {
  final ScrollController _scrollController = ScrollController();
  final Set<String> _selectedStatuses = {};

  List<String>? get _apiStatusParam {
    if (_selectedStatuses.isEmpty) return null;
    return _selectedStatuses.toList();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(customerPayoutsProvider(_apiStatusParam).notifier)
          .loadMore();
    }
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PayoutStatusFilterSheet(
        initialSelected: _selectedStatuses,
        onApply: (selected) {
          setState(() {
            _selectedStatuses.clear();
            _selectedStatuses.addAll(selected);
          });
        },
      ),
    );
  }

  void _removeStatusFilter(String statusKey) {
    setState(() {
      _selectedStatuses.remove(statusKey);
    });
  }

  String _formatDate(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return '';
    try {
      final dateTime = DateTime.parse(rawDate).toLocal();
      final now = DateTime.now();
      final timeStr = DateFormat('HH:mm').format(dateTime);

      if (dateTime.year == now.year &&
          dateTime.month == now.month &&
          dateTime.day == now.day) {
        return 'Today · $timeStr';
      }

      final yesterday = now.subtract(const Duration(days: 1));
      if (dateTime.year == yesterday.year &&
          dateTime.month == yesterday.month &&
          dateTime.day == yesterday.day) {
        return 'Yesterday · $timeStr';
      }

      final dateStr = DateFormat('dd.MM').format(dateTime);
      return '$dateStr · $timeStr';
    } catch (_) {
      return rawDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final payoutsAsync = ref.watch(customerPayoutsProvider(_apiStatusParam));

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const CustomBackButton(),
        title: Text(
          'Transactions',
          style: GoogleFonts.inter(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _showFilterBottomSheet(context),
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedFilter,
                  color: _selectedStatuses.isNotEmpty
                      ? AppColors.primary
                      : (isDark ? Colors.white70 : AppColors.textPrimary),
                  size: 20.sp,
                ),
                if (_selectedStatuses.isNotEmpty)
                  Positioned(
                    top: -4.h,
                    right: -4.w,
                    child: Container(
                      padding: EdgeInsets.all(3.r),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 14.w,
                        minHeight: 14.w,
                      ),
                      child: Center(
                        child: Text(
                          '${_selectedStatuses.length}',
                          style: GoogleFonts.inter(
                            color: Colors.white,
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
          SizedBox(width: 8.w),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Filter Badges Bar
            if (_selectedStatuses.isNotEmpty) ...[
              SizedBox(height: 8.h),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: [
                    ..._selectedStatuses.map((statusKey) {
                      final displayName =
                          _payoutStatusDisplayNames[statusKey] ?? statusKey;
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
                      onTap: () {
                        setState(() {
                          _selectedStatuses.clear();
                        });
                      },
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

            // Payout List
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  await ref
                      .read(customerPayoutsProvider(_apiStatusParam).notifier)
                      .refresh();
                },
                child: payoutsAsync.when(
                  data: (payouts) {
                    if (payouts.isEmpty) {
                      return ListView(
                        children: [
                          SizedBox(height: 100.h),
                          Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                HugeIcon(
                                  icon: HugeIcons.strokeRoundedCreditCard,
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.grey.shade300,
                                  size: 64.sp,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'No transactions found',
                                  style: AppTextStyles.heading3.copyWith(
                                    fontSize: 16.sp,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  'Your payout transactions will appear here.',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontSize: 13.sp,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }

                    final notifier = ref.read(
                      customerPayoutsProvider(_apiStatusParam).notifier,
                    );

                    return ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.h,
                      ),
                      itemCount: payouts.length + 1,
                      itemBuilder: (context, index) {
                        if (index == payouts.length) {
                          if (notifier.hasMore) {
                            return const _PayoutTileShimmer();
                          }
                          return const SizedBox.shrink();
                        }

                        final payout = payouts[index];
                        return _PayoutItemTile(
                          payout: payout,
                          formattedDate: _formatDate(
                            payout.createdAt ?? payout.urlGeneratedAt,
                          ),
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
                    itemBuilder: (context, index) => const _PayoutTileShimmer(),
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
                            'Failed to load transactions',
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
                              ref
                                  .read(
                                    customerPayoutsProvider(_apiStatusParam)
                                        .notifier,
                                  )
                                  .refresh();
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

class _PayoutStatusFilterSheet extends StatefulWidget {
  final Set<String> initialSelected;
  final ValueChanged<Set<String>> onApply;

  const _PayoutStatusFilterSheet({
    required this.initialSelected,
    required this.onApply,
  });

  @override
  State<_PayoutStatusFilterSheet> createState() =>
      __PayoutStatusFilterSheetState();
}

class __PayoutStatusFilterSheetState extends State<_PayoutStatusFilterSheet> {
  late Set<String> _tempSelected;

  @override
  void initState() {
    super.initState();
    _tempSelected = Set<String>.from(widget.initialSelected);
  }

  void _toggleKey(String key) {
    setState(() {
      if (_tempSelected.contains(key)) {
        _tempSelected.remove(key);
      } else {
        _tempSelected.add(key);
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
                'Filter Payouts',
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              if (_tempSelected.isNotEmpty)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tempSelected.clear();
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
            'Payout Status',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 12.h),

          // Multi-Select Choice Chips
          Wrap(
            spacing: 8.w,
            runSpacing: 10.h,
            children: _payoutStatusDisplayNames.entries.map((entry) {
              final key = entry.key;
              final displayName = entry.value;
              final isSelected = _tempSelected.contains(key);

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
            text: _tempSelected.isEmpty
                ? 'Show All Transactions'
                : 'Apply Filters (${_tempSelected.length})',
            onPressed: () {
              widget.onApply(_tempSelected);
              Navigator.pop(context);
            },
          ),
          SizedBox(height: 12.h),
        ],
      ),
    );
  }
}

class _PayoutItemTile extends StatelessWidget {
  final Payout payout;
  final String formattedDate;

  const _PayoutItemTile({
    required this.payout,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    final title = payout.task?.title?.isNotEmpty == true
        ? payout.task!.title!
        : (payout.description?.isNotEmpty == true
            ? payout.description!
            : 'Task Payout');

    final subtitle = payout.reference != null && payout.reference!.isNotEmpty
        ? 'Ref: ${payout.reference}'
        : (payout.task?.status ?? payout.status ?? '');

    final num amountNum = payout.customerPaymentAmount ??
        payout.payoutAmount ??
        payout.task?.customerTotalPrice ??
        0;

    final String amountStr = amountNum.toNaira(2);
    final String statusStr = (payout.status ?? '').toUpperCase();

    Color statusColor;
    IconData iconData;
    String prefix;

    switch (statusStr) {
      case 'SUCCESS':
      case 'COMPLETED':
      case 'CUSTOMER_PAID':
        statusColor = const Color(0xFF22C55E);
        iconData = Icons.south_west;
        prefix = '+ ';
        break;
      case 'PENDING':
      case 'TRANSFER_INITIATED':
        statusColor = Colors.amber.shade700;
        iconData = Icons.access_time_rounded;
        prefix = '';
        break;
      case 'FAILED':
      case 'CANCELLED':
        statusColor = AppColors.error;
        iconData = Icons.north_east;
        prefix = '- ';
        break;
      default:
        statusColor = isDark ? Colors.white70 : AppColors.textPrimary;
        iconData = Icons.receipt_long_outlined;
        prefix = '';
    }

    final cardBg = isDark
        ? AppColors.darkerBackground
        : AppColors.surface;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        children: [
          // Left Circular Icon Avatar
          Container(
            width: 44.w,
            height: 44.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: statusColor.withValues(alpha: isDark ? 0.18 : 0.1),
            ),
            child: Icon(
              iconData,
              color: statusColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),

          // Middle Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 3.h),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),

          // Right Amount & Date/Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$prefix$amountStr',
                style: GoogleFonts.inter(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
              if (formattedDate.isNotEmpty) ...[
                SizedBox(height: 3.h),
                Text(
                  formattedDate,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _PayoutTileShimmer extends StatelessWidget {
  const _PayoutTileShimmer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;
    final cardBg = isDark ? AppColors.darkerBackground : AppColors.surface;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120.w,
                    height: 14.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Container(
                    width: 80.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 70.w,
                  height: 14.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  width: 50.w,
                  height: 10.h,
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
}
