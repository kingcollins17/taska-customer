import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:seeker_app/core/clients/payments_client.dart';
import 'package:seeker_app/core/constants.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/models/payout/payout_models.dart';

final pendingPayoutProvider = FutureProvider.family.autoDispose<Payout?, String?>((ref, taskId) async {
  try {
    final client = ref.watch(paymentsClientProvider);
    final response = await client.getPendingPayout(taskId: taskId);
    if (response.success && response.data != null) {
      return response.data..debugLog();
    }
  } catch (e) {
    e.debugLog(type: LogType.error);
    rethrow;
  }
  return null;
});


final pendingPayoutListenerProvider = FutureProvider.autoDispose<void>((ref) async{
  void showModal(Payout payout) {
  
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appQueue.add(() async {
          await PaymentPage.show(
            amount: payout.customerPaymentAmount?.toDouble() ??
                payout.payoutAmount?.toDouble() ??
                payout.task?.customerTotalPrice?.toDouble(),
            userId: payout.customerId,
            taskId: payout.taskId,
          );
          
        });
      });
    }
  

  final payout = await ref.watch(pendingPayoutProvider(null).future);
  if (payout != null) {
    showModal(payout);
  }
});

class CustomerPayoutsNotifier
    extends AsyncNotifier<List<Payout>> {
  int _page = 1;
  final int _perPage = 20;
  bool _hasMore = true;

  bool get hasMore => _hasMore;

  final List<String>? statuses;

  CustomerPayoutsNotifier([this.statuses]);

  @override
  FutureOr<List<Payout>> build() async {
    _page = 1;
    _hasMore = true;
    return _fetchPayouts();
  }

  Future<List<Payout>> _fetchPayouts() async {
    final client = ref.read(paymentsClientProvider);
    final statusList = (statuses != null && statuses!.isNotEmpty)
        ? statuses!.map((i) => i.toUpperCase().replaceAll(' ', '_')).toList()
        : null;

    final response = await client.getCustomerPayouts(
      page: _page,
      perPage: _perPage,
      status: statusList,
    );

    if (response.success && response.data != null) {
      final items = response.data!.items ?? [];
      if (items.length < _perPage) {
        _hasMore = false;
      }
      return items;
    } else {
      throw Exception(response.detail ?? 'Failed to load customer payouts');
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || state.isLoading || state.isRefreshing) return;

    final currentData = state.value ?? [];
    _page++;

    try {
      final newItems = await _fetchPayouts();
      state = AsyncData([...currentData, ...newItems]);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> refresh() async {
    _page = 1;
    _hasMore = true;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPayouts());
  }
}

final customerPayoutsProvider = AsyncNotifierProvider.family<
    CustomerPayoutsNotifier, List<Payout>, List<String>?>((param) =>
  CustomerPayoutsNotifier(param),
);


