import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/dio_provider.dart';

part 'tasks_client.g.dart';

final tasksClientProvider = Provider<TasksClient>((ref) {
  final dio = ref.watch(dioProvider);
  return TasksClient(dio);
});

@RestApi(baseUrl: '/api/v1')
abstract class TasksClient {
  factory TasksClient(Dio dio, {String baseUrl}) = _TasksClient;

  @POST('/tasks')
  Future<GenericResponse> createTask(@Body() CreateTaskRequest request);

  @GET('/tasks/{task_id}')
  Future<GenericResponse<Task>> getTask(@Path('task_id') String taskId);

  @POST('/tasks/{task_id}/attachments')
  @MultiPart()
  Future<GenericResponse<TaskAttachment>> uploadAttachment(
    @Path('task_id') String taskId,
    @Part(name: 'file') File file,
  );
}
