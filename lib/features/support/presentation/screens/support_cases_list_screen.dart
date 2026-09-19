import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/designs/widgets/custom_back_button.dart';
import 'package:seeker_app/core/designs/widgets/primary_button.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/support_providers.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import 'package:shimmer/shimmer.dart';

enum TicketFilter { all, open, closed }

class SupportCasesListScreen extends ConsumerStatefulWidget {
  const SupportCasesListScreen({super.key});

  @override
  ConsumerState<SupportCasesListScreen> createState() =>
      _SupportCasesListScreenState();
}

class _SupportCasesListScreenState extends ConsumerState<SupportCasesListScreen> {
  final ScrollController _scrollController = ScrollController();
  TicketFilter _selectedFilter = TicketFilter.all;

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
      ref.read(userCasesProvider(null).notifier).loadMore();
    }
  }

  Future<void> _openCreateTicket() async {
    await context.pushNamed(RouteNames.createSupportCase.name);
    if (!mounted) return;
    ref.read(userCasesProvider(null).notifier).refresh();
  }

  List<SupportCase> _filterCases(List<SupportCase> cases) {
    switch (_selectedFilter) {
      case TicketFilter.open:
        return cases.where((c) {
          final s = c.status?.toUpperCase() ?? '';
          return s == 'OPEN' || s == 'IN_PROGRESS' || s == 'PENDING' || s == 'WAITING_FOR_CUSTOMER';
        }).toList();
      case TicketFilter.closed:
        return cases.where((c) {
          final s = c.status?.toUpperCase() ?? '';
          return s == 'CLOSED' || s == 'RESOLVED' || s == 'CANCELLED';
        }).toList();
      case TicketFilter.all:
        return cases;
    }
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final casesAsync = ref.watch(userCasesProvider(null));

    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.background;
    final surfaceColor = isDark ? const Color(0xFF16181C) : AppColors.surface;
    final borderColor = isDark ? const Color(0xFF2C2F36) : const Color(0xFFE5E7EB);
    final textPrimary = isDark ? Colors.white : AppColors.textPrimary;
    final textSecondary = isDark ? const Color(0xFF9CA3AF) : AppColors.textSecondary;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        centerTitle: true,
        leading: const CustomBackButton(),
        title: Text(
          'Support Tickets',
          style: AppTextStyles.heading3.copyWith(
            color: textPrimary,
            fontSize: 16.sp,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openCreateTicket,
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedAdd01,
              color: AppColors.primary,
              size: 22.sp,
            ),
            tooltip: 'New Ticket',
          ),
          SizedBox(width: 8.w),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateTicket,
        backgroundColor: AppColors.primary,
        icon: HugeIcon(
          icon: HugeIcons.strokeRoundedCustomerSupport,
          color: Colors.white,
          size: 18.sp,
        ),
        label: Text(
          'New Ticket',
          style: AppTextStyles.label.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(userCasesProvider(null).notifier).refresh();
        },
        color: AppColors.primary,
        child: Column(
          children: [
            SizedBox(height: 12.h),
            // Filter Tabs Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildFilterTabs(isDark, textPrimary, textSecondary, surfaceColor, borderColor),
            ),
            SizedBox(height: 12.h),

            // Content Area
            Expanded(
              child: casesAsync.when(
                data: (allCases) {
                  final filtered = _filterCases(allCases);

                  if (filtered.isEmpty) {
                    return _buildEmptyState(isDark, textPrimary, textSecondary);
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      top: 4.h,
                      bottom: 80.h,
                    ),
                    itemCount: filtered.length +
                        (ref.read(userCasesProvider(null).notifier).hasMore ? 1 : 0),
                    separatorBuilder: (_, index) => SizedBox(height: 10.h),
                    itemBuilder: (context, index) {
                      if (index == filtered.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          child: const Center(
                            child: CircularProgressIndicator.adaptive(),
                          ),
                        );
                      }

                      final caseItem = filtered[index];
                      return _TicketCard(
                        caseItem: caseItem,
                        formattedDate: _formatDate(caseItem.createdAt),
                        isDark: isDark,
                        surfaceColor: surfaceColor,
                        borderColor: borderColor,
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                        onTap: () {
                          if (caseItem.id != null) {
                            context.pushNamed(
                              RouteNames.supportCaseDetail.name,
                              pathParameters: {'caseId': caseItem.id!},
                            );
                          }
                        },
                      ).animate().fade(duration: 250.ms).slideY(
                            begin: 0.05,
                            duration: 250.ms,
                            curve: Curves.easeOut,
                          );
                    },
                  );
                },
                loading: () => _buildShimmerList(isDark, surfaceColor, borderColor),
                error: (err, stack) => _buildErrorState(
                  err.toString(),
                  isDark,
                  textPrimary,
                  textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTabs(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
    Color surfaceColor,
    Color borderColor,
  ) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor, width: 1.w),
      ),
      child: Row(
        children: TicketFilter.values.map((filter) {
          final isSelected = _selectedFilter == filter;
          String label;
          switch (filter) {
            case TicketFilter.all:
              label = 'All Tickets';
              break;
            case TicketFilter.open:
              label = 'Open';
              break;
            case TicketFilter.closed:
              label = 'Closed';
              break;
          }

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              child: AnimatedContainer(
                duration: 200.ms,
                padding: EdgeInsets.symmetric(vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? const Color(0xFF2C2F36) : AppColors.primary.withValues(alpha: 0.1))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: AppTextStyles.label.copyWith(
                      fontSize: 12.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState(
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedCustomerSupport,
              size: 48.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            _selectedFilter == TicketFilter.all
                ? 'No Support Tickets Yet'
                : 'No ${_selectedFilter.name.toUpperCase()} Tickets Found',
            style: AppTextStyles.heading3.copyWith(
              color: textPrimary,
              fontSize: 16.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Need help with a task, payment, or general question? Create a ticket and our team will assist you.',
            style: AppTextStyles.bodySmall.copyWith(
              color: textSecondary,
              fontSize: 12.sp,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: 200.w,
            child: PrimaryButton(
              text: 'Create Ticket',
              height: 40.h,
              onPressed: _openCreateTicket,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    String error,
    bool isDark,
    Color textPrimary,
    Color textSecondary,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(
            icon: HugeIcons.strokeRoundedAlertCircle,
            size: 40.sp,
            color: AppColors.error,
          ),
          SizedBox(height: 12.h),
          Text(
            'Failed to load support tickets',
            style: AppTextStyles.heading3.copyWith(
              color: textPrimary,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            error,
            style: AppTextStyles.bodySmall.copyWith(
              color: textSecondary,
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(userCasesProvider(null).notifier).refresh();
            },
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedRefresh,
              size: 16.sp,
              color: Colors.white,
            ),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList(bool isDark, Color surfaceColor, Color borderColor) {
    final baseColor = isDark ? const Color(0xFF1F222A) : const Color(0xFFE5E7EB);
    final highlightColor = isDark ? const Color(0xFF2C303B) : const Color(0xFFF3F4F6);
    final placeholderColor = isDark ? const Color(0xFF282B34) : const Color(0xFFD1D5DB);

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: 3,
      separatorBuilder: (context, index) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: borderColor, width: 1.w),
          ),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlightColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 14.w,
                          height: 14.w,
                          decoration: BoxDecoration(
                            color: placeholderColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          width: 70.w,
                          height: 11.h,
                          decoration: BoxDecoration(
                            color: placeholderColor,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 60.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: placeholderColor,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Container(
                  width: 180.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  width: double.infinity,
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: placeholderColor,
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Container(
                      width: 50.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: placeholderColor,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      width: 40.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: placeholderColor,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 70.w,
                      height: 10.h,
                      decoration: BoxDecoration(
                        color: placeholderColor,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TicketCard extends StatelessWidget {
  final SupportCase caseItem;
  final String formattedDate;
  final bool isDark;
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final VoidCallback onTap;

  const _TicketCard({
    required this.caseItem,
    required this.formattedDate,
    required this.isDark,
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.onTap,
  });

  Color _getStatusBgColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
      case 'PENDING':
        return Colors.blue.withValues(alpha: 0.12);
      case 'IN_PROGRESS':
        return Colors.amber.withValues(alpha: 0.14);
      case 'RESOLVED':
      case 'CLOSED':
        return isDark ? Colors.white10 : const Color(0xFFF0F2F5);
      case 'CANCELLED':
        return AppColors.error.withValues(alpha: 0.1);
      default:
        return AppColors.primary.withValues(alpha: 0.1);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toUpperCase()) {
      case 'OPEN':
      case 'PENDING':
        return Colors.blue.shade700;
      case 'IN_PROGRESS':
        return Colors.amber.shade800;
      case 'RESOLVED':
      case 'CLOSED':
        return textSecondary;
      case 'CANCELLED':
        return AppColors.error;
      default:
        return AppColors.primary;
    }
  }

  String _formatStatus(String? status) {
    if (status == null || status.isEmpty) return 'OPEN';
    return status.replaceAll('_', ' ').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final statusStr = caseItem.status ?? 'OPEN';
    final caseNum = caseItem.caseNumber != null && caseItem.caseNumber!.isNotEmpty
        ? '#${caseItem.caseNumber}'
        : (caseItem.id != null ? '#${caseItem.id!.substring(0, 8).toUpperCase()}' : '#TICKET');

    final typeStr = caseItem.type?.replaceAll('_', ' ').toUpperCase() ?? 'GENERAL';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: borderColor, width: 1.w),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Case Number & Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedTicket01,
                        size: 14.sp,
                        color: AppColors.primary,
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        caseNum,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: _getStatusBgColor(statusStr),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      _formatStatus(statusStr),
                      style: AppTextStyles.label.copyWith(
                        color: _getStatusTextColor(statusStr),
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),

              // Subject
              Text(
                caseItem.subject ?? 'No Subject',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (caseItem.description != null && caseItem.description!.isNotEmpty) ...[
                SizedBox(height: 3.h),
                Text(
                  caseItem.description!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: textSecondary,
                    fontSize: 11.sp,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 8.h),

              // Footer: Category chip, Priority, Date
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF262930) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      typeStr,
                      style: AppTextStyles.label.copyWith(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: textSecondary,
                      ),
                    ),
                  ),
                  if (caseItem.priority != null && caseItem.priority!.isNotEmpty) ...[
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: caseItem.priority!.toUpperCase() == 'URGENT' ||
                                caseItem.priority!.toUpperCase() == 'HIGH'
                            ? AppColors.error.withValues(alpha: 0.1)
                            : (isDark ? const Color(0xFF262930) : const Color(0xFFF1F5F9)),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        caseItem.priority!.toUpperCase(),
                        style: AppTextStyles.label.copyWith(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w600,
                          color: caseItem.priority!.toUpperCase() == 'URGENT' ||
                                  caseItem.priority!.toUpperCase() == 'HIGH'
                              ? AppColors.error
                              : textSecondary,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  Text(
                    formattedDate,
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 10.sp,
                      color: textSecondary,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    size: 13.sp,
                    color: textSecondary,
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
