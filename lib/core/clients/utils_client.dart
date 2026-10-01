import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/dio_provider.dart';

part 'utils_client.g.dart';

/// Provider for [UtilsClient].
final utilsClientProvider = Provider<UtilsClient>((ref) {
  final dio = ref.watch(dioProvider);
  return UtilsClient(dio);
});

/// Retrofit REST client for Utils endpoints.
@RestApi(baseUrl: '/api/v1/utils')
abstract class UtilsClient {
  factory UtilsClient(Dio dio, {String baseUrl}) = _UtilsClient;

  /// Upload a single file.
  ///
  /// Accessible by authenticated users and admins.
  @POST('/upload-file')
  @MultiPart()
  Future<GenericResponse<FileUploadData>> uploadSingleFile(
    @Part(name: 'file') File file,
  );

  /// Upload multiple files in parallel.
  ///
  /// Accessible by authenticated users and admins.
  @POST('/upload-files')
  @MultiPart()
  Future<GenericResponse<MultipleFilesUploadData>> uploadMultipleFiles(
    @Part(name: 'files') List<File> files,
  );

  /// Delete multiple files in parallel via DELETE method.
  ///
  /// Accessible by authenticated users and admins.
  @DELETE('/delete-files')
  Future<GenericResponse<DeleteFilesData>> deleteMultipleFiles(
    @Body() DeleteFilesRequest request,
  );
}
