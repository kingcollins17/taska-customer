import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/dio_provider.dart';

part 'regions_client.g.dart';

final regionsClientProvider = Provider<RegionsClient>((ref) {
  final dio = ref.watch(dioProvider);
  return RegionsClient(dio);
});

@RestApi(baseUrl: '/api/v1/regions')
abstract class RegionsClient {
  factory RegionsClient(Dio dio, {String baseUrl}) = _RegionsClient;

  @GET('/')
  Future<GenericResponse<List<Region>>> getRegions();
}
