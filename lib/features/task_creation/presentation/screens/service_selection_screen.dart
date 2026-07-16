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

      if (mounted) {
        context.pushNamed(
          RouteNames.taskDescription.name,
          queryParameters: {'service': service.name ?? ''},
        );
      }
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
                    return ListView.separated(
                      itemCount: services.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, color: Colors.transparent),
                      itemBuilder: (context, index) {
                        final service = services[index];
                        return _ServiceTile(
                          service: service,
                          onTap: () => _handleServiceTap(service),
                        );
                      },
                    );
                  },
                  loading: () => ListView.separated(
                    itemCount: 8,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: Colors.transparent),
                    itemBuilder: (context, index) {
                      return const _ServiceTile(service: null);
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
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceTile extends ConsumerWidget {
  final md.Service? service;
  final VoidCallback? onTap;

  const _ServiceTile({this.service, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    if (service == null) {
      return Shimmer.fromColors(
        baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
        highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                height: 20,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
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
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.textSecondary.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                service!.name ?? 'Unknown Service',
                style: AppTextStyles.heading3.copyWith(
                  fontSize: 18.sp,
                  color: textColor,
                ),
              ),
            ),
            availabilityAsync.when(
              data: (isAvailable) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isAvailable
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isAvailable ? 'Available' : 'Unavailable',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isAvailable ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox(),
            ),
          ],
        ),
      ),
    );
  }
}
