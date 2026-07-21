import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker_app/core/clients/clients.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/regions_provider.dart';

class ServicesNotifier extends AsyncNotifier<List<Service>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  final String? search, categoryId;

  ServicesNotifier({this.search, this.categoryId});
  @override
  FutureOr<List<Service>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchServices(page: _page);
  }

  Future<List<Service>> _fetchServices({required int page}) async {
    final client = ref.read(servicesClientProvider);
    final response = await client.getServices(
      page: page,
      perPage: _perPage,
      search: search,
      categoryId: categoryId,
    );
    final items = response.data?.items ?? [];
    if (items.length < _perPage) {
      _hasMore = false;
    }
    return items;
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchServices(page: _page));
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.hasError || !_hasMore) return;

    final currentItems = state.value ?? [];

    try {
      final nextItems = await _fetchServices(page: _page + 1);
      _page++;
      state = AsyncData([...currentItems, ...nextItems]);
    } catch (e, st) {
      // TODO: Implement error handling
    }
  }
}

typedef ServiceQuery = ({String? search, String? categoryId});
final servicesProvider =
    AsyncNotifierProvider.family<ServicesNotifier, List<Service>, ServiceQuery>(
      (param) {
        return ServicesNotifier(
          search: param.search,
          categoryId: param.categoryId,
        );
      },
    );

class CategoriesNotifier extends AsyncNotifier<List<ServiceCategory>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  final String? search;

  CategoriesNotifier({this.search});
  @override
  FutureOr<List<ServiceCategory>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchCategories(page: _page);
  }

  Future<List<ServiceCategory>> _fetchCategories({required int page}) async {
    final client = ref.read(servicesClientProvider);
    final response = await client.getCategories(
      page: page,
      perPage: _perPage,
      search: search,
    );
    final items = response.data?.items ?? [];
    if (items.length < _perPage) {
      _hasMore = false;
    }
    return items;
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchCategories(page: _page));
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.hasError || !_hasMore) return;

    final currentItems = state.value ?? [];

    try {
      final nextItems = await _fetchCategories(page: _page + 1);
      _page++;
      state = AsyncData([...currentItems, ...nextItems]);
    } catch (e, st) {
      // TODO: Implement error handling
    }
  }
}

final categoriesProvider =
    AsyncNotifierProvider.family<
      CategoriesNotifier,
      List<ServiceCategory>,
      String?
    >((search) {
      return CategoriesNotifier(search: search);
    });

final serviceByIdProvider = FutureProvider.family<Service, String>((
  ref,
  id,
) async {
  final client = ref.read(servicesClientProvider);
  final response = await client.getService(id);
  if (response.data == null) {
    throw Exception(response.detail ?? 'Service not found');
  }
  return response.data!;
});

final categoryByIdProvider = FutureProvider.family<ServiceCategory, String>((
  ref,
  id,
) async {
  final client = ref.read(servicesClientProvider);
  final response = await client.getCategory(id);
  if (response.data == null) {
    throw Exception(response.detail ?? 'Category not found');
  }
  return response.data!;
});

final isServiceAvailableInRegionProvider =
    FutureProvider.family<bool, ({String serviceId, String regionId})>((
      ref,
      param,
    ) async {
      final response = await ref
          .read(servicesClientProvider)
          .checkServiceAvailabilityInRegion(param.serviceId, param.regionId);

      return response.data?.isAvailable ?? false;
    });

final isServiceAvailableInCurrentRegionProvider =
    FutureProvider.family<bool, String>((ref, serviceId) async {
      final currentRegion = await ref.watch(currentRegionProvider.future);

      if (currentRegion?.id == null) throw 'Current Region not available';
      final isAvailable = await ref.watch(
        isServiceAvailableInRegionProvider((
          regionId: currentRegion!.id!,
          serviceId: serviceId,
        )).future,
      );

      return isAvailable;
    });

final topServicesProvider = FutureProvider<List<Service>>((ref) async {
  final client = ref.read(servicesClientProvider);
  final response = await client.getTopServices(limit: 10);
  if (response.data == null) {
    throw Exception(response.detail ?? 'Failed to load top services');
  }
  return response.data!;
});

final topCategoriesProvider = FutureProvider<List<ServiceCategory>>((ref) async {
  final client = ref.read(servicesClientProvider);
  final response = await client.getTopCategories(limit: 10);
  if (response.data == null) {
    throw Exception(response.detail ?? 'Failed to load top categories');
  }
  return response.data!;
});
