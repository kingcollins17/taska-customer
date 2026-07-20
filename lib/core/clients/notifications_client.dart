import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/dio_provider.dart';

part 'notifications_client.g.dart';

final notificationsClientProvider = Provider<NotificationsClient>((ref) {
  final dio = ref.watch(dioProvider);
  return NotificationsClient(dio);
});

@RestApi(baseUrl: '/api/v1/notifications')
abstract class NotificationsClient {
  factory NotificationsClient(Dio dio, {String baseUrl}) = _NotificationsClient;

  @GET('/')
  Future<GenericResponse<PaginatedResponse<NotificationItem>>> getNotifications(
    @Query('page') int page,
    @Query('per_page') int perPage,
  );

  @POST('/mark-read')
  Future<GenericResponse<PaginatedResponse<NotificationItem>>> markRead(
    @Body() Map<String, dynamic> body,
  );

  @GET('/counts')
  Future<GenericResponse<NotificationCounts>> getNotificationCounts();
}
