import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/dio_provider.dart';

part 'support_client.g.dart';

final supportClientProvider = Provider<SupportClient>((ref) {
  final dio = ref.watch(dioProvider);
  return SupportClient(dio);
});

@RestApi(baseUrl: '/api/v1')
abstract class SupportClient {
  factory SupportClient(Dio dio, {String baseUrl}) = _SupportClient;

  @POST('/support/cases')
  Future<GenericResponse<SupportCase>> createCase(
    @Body() CreateSupportCaseRequest request,
  );

  @GET('/support/cases')
  Future<GenericResponse<PaginatedResponse<SupportCase>>> listUserCases({
    @Query('page') int? page = 1,
    @Query('per_page') int? perPage = 20,
    @Query('task_id') String? taskId,
  });

  @GET('/support/cases/{case_id}')
  Future<GenericResponse<SupportCase>> getUserCase(
    @Path('case_id') String caseId,
  );

  @GET('/support/cases/{case_id}/messages')
  Future<GenericResponse<PaginatedResponse<SupportCaseMessage>>> getCaseMessages(
    @Path('case_id') String caseId, {
    @Query('page') int? page = 1,
    @Query('per_page') int? perPage = 20,
  });

  @POST('/support/cases/{case_id}/messages')
  Future<GenericResponse<SupportCaseMessage>> sendUserMessage(
    @Path('case_id') String caseId,
    @Body() SendSupportMessageRequest request,
  );

  @GET('/support/cases/{case_id}/timeline')
  Future<GenericResponse<PaginatedResponse<SupportCaseTimelineItem>>> getCaseTimeline(
    @Path('case_id') String caseId, {
    @Query('page') int? page = 1,
    @Query('per_page') int? perPage = 20,
  });

  @POST('/support/cases/{case_id}/attachments')
  @MultiPart()
  Future<GenericResponse<SupportCaseAttachment>> uploadAttachment(
    @Path('case_id') String caseId,
    @Part(name: 'file') File file, {
    @Query('message_id') String? messageId,
  });

  @POST('/support/cases/{case_id}/close')
  Future<GenericResponse<SupportCase>> closeUserCase(
    @Path('case_id') String caseId,
  );

  @POST('/support/cases/{case_id}/reopen')
  Future<GenericResponse<SupportCase>> reopenUserCase(
    @Path('case_id') String caseId,
  );
}
