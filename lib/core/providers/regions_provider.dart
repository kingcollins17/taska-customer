import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker_app/core/clients/clients.dart';
import 'package:seeker_app/core/models/models.dart';
import 'location_provider.dart';

final regionsProvider = FutureProvider<List<Region>>((ref) async {
  final client = ref.read(regionsClientProvider);
  final response = await client.getRegions();
  return response.data ?? [];
});

final currentRegionProvider = FutureProvider.autoDispose<Region?>((ref) async {
  final address = await ref.watch(locationProvider.future);
  if (address == null || address.state == null) {
    return null;
  }

  final regions = await ref.watch(regionsProvider.future);

  try {
    return regions.firstWhere(
      (region) => region.state?.toLowerCase() == address.state?.toLowerCase(),
    );
  } catch (e) {
    return null;
  }
});
