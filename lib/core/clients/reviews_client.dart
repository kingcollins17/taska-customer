import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/dio_provider.dart';

part 'reviews_client.g.dart';

final reviewsClientProvider = Provider<ReviewsClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ReviewsClient(dio);
});

@RestApi(baseUrl: '/api/v1')
abstract class ReviewsClient {
  factory ReviewsClient(Dio dio, {String baseUrl}) = _ReviewsClient;

  @POST('/reviews')
  Future<GenericResponse<dynamic>> submitReview(
    @Body() SubmitReviewRequest request,
  );

  @GET('/reviews/pending/customer')
  Future<GenericResponse<PaginatedResponse<PendingReviewTask>>> getPendingCustomerReviews({
    @Query('page') int? page = 1,
    @Query('per_page') int? perPage = 20,
  });
}
