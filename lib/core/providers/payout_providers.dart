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


