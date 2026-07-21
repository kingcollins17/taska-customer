import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/dio_provider.dart';

part 'services_client.g.dart';

final servicesClientProvider = Provider<ServicesClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ServicesClient(dio);
});

@RestApi(baseUrl: '/api/v1')
abstract class ServicesClient {
  factory ServicesClient(Dio dio, {String baseUrl}) = _ServicesClient;

  @GET('/services')
  Future<GenericResponse<PaginatedResponse<Service>>> getServices({
    @Query('page') int? page = 1,
    @Query('per_page') int? perPage = 20,
    @Query('search') String? search,
    @Query('category_id') String? categoryId,
    @Query('is_active') bool? isActive,
    @Query('sort_by') String? sortBy = 'created_at',
    @Query('sort_desc') bool? sortDesc = true,
  });

  @GET('/services/{service_id}')
  Future<GenericResponse<Service>> getService(@Path('service_id') String serviceId);

  @GET('/services/available/regions/{region_id}')
  Future<GenericResponse<PaginatedResponse<Service>>> getAvailableServicesInRegion(
    @Path('region_id') String regionId, {
    @Query('page') int? page = 1,
    @Query('per_page') int? perPage = 20,
  });

  @GET('/services/{service_id}/available/regions/{region_id}')
  Future<GenericResponse<ServiceAvailability>> checkServiceAvailabilityInRegion(
    @Path('service_id') String serviceId,
    @Path('region_id') String regionId,
  );

  @GET('/categories')
  Future<GenericResponse<PaginatedResponse<ServiceCategory>>> getCategories({
    @Query('page') int? page = 1,
    @Query('per_page') int? perPage = 20,
    @Query('search') String? search,
    @Query('is_active') bool? isActive,
    @Query('sort_by') String? sortBy = 'created_at',
    @Query('sort_desc') bool? sortDesc = true,
  });

  @GET('/categories/{category_id}')
  Future<GenericResponse<ServiceCategory>> getCategory(@Path('category_id') String categoryId);

  @GET('/services/top')
  Future<GenericResponse<List<Service>>> getTopServices({
    @Query('limit') int? limit = 10,
  });

  @GET('/services/categories/top')
  Future<GenericResponse<List<ServiceCategory>>> getTopCategories({
    @Query('limit') int? limit = 10,
  });
}
