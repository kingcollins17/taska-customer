import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:seeker_app/core/clients/payments_client.dart';
import 'package:seeker_app/core/core.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/models/payout/payout_models.dart';




final pendingPayoutProvider = FutureProvider.autoDispose<Payout?>((ref) async {
  try {
    final client = ref.watch(paymentsClientProvider);
    final response = await client.getPendingPayout();
    if (response.success && response.data != null) {
      return response.data;
    }
  } catch (e) {
    e.debugLog(type: LogType.error);
    rethrow;
  }
  return null;
});

final hasShownPendingPayoutModalProvider = StateProvider<bool>((ref) => false);

final pendingPayoutListenerProvider = Provider.autoDispose<void>((ref) {
  void showModal(Payout payout) {
    final currentlyShown = ref.read(hasShownPendingPayoutModalProvider);
    if (!currentlyShown) {
      final modalNotifier = ref.read(hasShownPendingPayoutModalProvider.notifier);
      modalNotifier.state = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await PaymentPage.show(
          amount: payout.customerPaymentAmount?.toDouble() ??
              payout.payoutAmount?.toDouble() ??
              payout.task?.customerTotalPrice?.toDouble(),
          userId: payout.customerId,
          taskId: payout.taskId,
        );
        if (ref.mounted) {
          modalNotifier.state = false;
        }
      });
    }
  }

  ref.listen<AsyncValue<Payout?>>(pendingPayoutProvider, (previous, next) {
    final payout = next.value;
    if (payout != null) {
      showModal(payout);
    }
  });

  final asyncPayout = ref.watch(pendingPayoutProvider);
  if (asyncPayout.hasValue && asyncPayout.value != null) {
    showModal(asyncPayout.value!);
  }
});


