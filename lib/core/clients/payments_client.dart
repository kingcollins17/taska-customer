import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/dio_provider.dart';

part 'payments_client.g.dart';

final paymentsClientProvider = Provider<PaymentsClient>((ref) {
  final dio = ref.watch(dioProvider);
  return PaymentsClient(dio);
});

@RestApi(baseUrl: '/api/v1')
abstract class PaymentsClient {
  factory PaymentsClient(Dio dio, {String baseUrl}) = _PaymentsClient;

  @POST('/payments/webhooks')
  Future<GenericResponse<dynamic>> processPaymentWebhook(
    @Body() WebhookPayload payload,
  );

  @GET('/payments/customer/payouts/pending-payment')
  Future<GenericResponse<Payout>> getPendingPayout();
}

