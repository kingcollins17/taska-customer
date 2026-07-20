import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/designs/widgets/current_location.dart';
import 'package:seeker_app/core/models/service/service.dart' as md;
import 'package:shimmer/shimmer.dart';

import 'package:seeker_app/core/designs/app_colors.dart';
import 'package:seeker_app/core/designs/app_text_styles.dart';
import 'package:seeker_app/core/routes/route_names.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:seeker_app/core/providers/task_creation_provider.dart';
import 'package:seeker_app/core/providers/services_provider.dart';
import 'package:seeker_app/core/providers/location_provider.dart';
import 'package:seeker_app/core/designs/widgets/primary_button.dart';
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

  Future<void> _handleServiceTap(md.Service service) async {
    if (service.id == null) return;

    context.showLoading();
    try {
      final available = await ref.read(
        isServiceAvailableInCurrentRegionProvider(service.id!).future,
      );

      if (!available) {
        throw '${service.name ?? "Service"} is not available in your current location';
      }

      await ref.read(taskCreationProvider.notifier).updateService(service.id!);
    } catch (err) {
      if (mounted) {
        context.showMessage(
          (err as Object?).toFriendlyMessage(),
          type: MessageType.error,
        );
      }
    } finally {
      if (mounted) {
        context.hideLoading();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(taskCreationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final cardColor = isDark ? AppColors.darkerBackground : AppColors.surface;

    final categoryId = widget.categoryId ?? draft.value?.categoryId;

    if (categoryId == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Text(
            'No category selected',
            style: AppTextStyles.bodyLarge.copyWith(color: textColor),
          ),
        ),
      );
    }

    final servicesAsync = ref.watch(
      servicesProvider((search: _searchQuery, categoryId: categoryId)),
    );

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
                'What service do you need?',
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
                child: servicesAsync.when(
                  data: (services) {
                    if (services.isEmpty) {
                      return Center(
                        child: Text(
                          'No services found',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: services.length,
                      padding: EdgeInsets.only(bottom: 24.h),
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: _ServiceTile(
                            service: service,
                            isSelected: service.id == draft.value?.serviceId,
                            onTap: () => _handleServiceTap(service),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => ListView.builder(
                    itemCount: 8,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: const _ServiceTile(service: null),
                      );
                    },
                  ),
                  error: (error, stack) => Center(
                    child: Text(
                      'Error loading services: $error',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ),
              if (servicesAsync.hasValue && draft.value?.serviceId != null) ...[
                const SizedBox(height: 16),
                PrimaryButton(
                  text: 'Continue',
                  onPressed: () {
                    final selectedService = servicesAsync.value!.firstWhere((s) => s.id == draft.value!.serviceId);
                    context.pushNamed(
                      RouteNames.taskDescription.name,
                      queryParameters: {'service': selectedService.name ?? ''},
                    );
                  },
                ),
                SizedBox(height: 16.h),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTile extends ConsumerWidget {
  final md.Service? service;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ServiceTile({this.service, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    if (service == null) {
      return Shimmer.fromColors(
        baseColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[300]!,
        highlightColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[100]!,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: isDark ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 16.w),
              Container(
                height: 16.h,
                width: 150.w,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final availabilityAsync = ref.watch(
      isServiceAvailableInCurrentRegionProvider(service!.id!),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(16.r),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
            width: isSelected ? 2 : 1,
          ),
        ),
        padding: EdgeInsets.all(16.w),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.handyman_outlined,
                color: isSelected ? AppColors.primary : (isDark ? Colors.white : AppColors.textPrimary),
                size: 20.sp,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service!.name ?? 'Unknown Service',
                    style: AppTextStyles.heading3.copyWith(
                      fontSize: 15.sp,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  availabilityAsync.when(
                    data: (isAvailable) {
                      if (!isAvailable) {
                        return Text(
                          'Unavailable in your region',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.redAccent,
                            fontSize: 13.sp,
                          ),
                        );
                      }
                      return Text(
                        'Available',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.green,
                          fontSize: 13.sp,
                        ),
                      );
                    },
                    loading: () => Shimmer.fromColors(
                      baseColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[300]!,
                      highlightColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[100]!,
                      child: Container(
                        height: 12.h,
                        width: 80.w,
                        color: Colors.white,
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 24.sp)
            else
              Icon(Icons.chevron_right, color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.3), size: 20.sp),
          ],
        ),
      ),
    );
  }
}
