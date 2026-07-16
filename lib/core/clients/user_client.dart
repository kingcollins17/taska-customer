import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:retrofit/retrofit.dart';
import 'package:seeker_app/core/models/models.dart';
import 'package:seeker_app/core/providers/dio_provider.dart';

part 'user_client.g.dart';

final userClientProvider = Provider<UserClient>((ref) {
  final dio = ref.watch(dioProvider);
  return UserClient(dio);
});

@RestApi(baseUrl: '/api/v1')
abstract class UserClient {
  factory UserClient(Dio dio, {String baseUrl}) = _UserClient;

  @POST('/users/register')
  Future<GenericResponse<dynamic>> registerUser(
    @Body() RegisterRequest request,
  );

  @POST('/users/login')
  @FormUrlEncoded()
  Future<LoginResponse> login(
    @Field('username') String username,
    @Field('password') String password, {
    @Field('grant_type') String? grantType,
    @Field('scope') String? scope,
    @Field('client_id') String? clientId,
    @Field('client_secret') String? clientSecret,
  });

  @POST('/users/request-email-otp')
  Future<GenericResponse<dynamic>> requestEmailOtp(
    @Body() RequestEmailOtpRequest request,
  );

  @POST('/users/verify-email')
  Future<GenericResponse<dynamic>> verifyEmail(
    @Body() VerifyEmailRequest request,
  );

  @POST('/users/request-phone-otp')
  Future<GenericResponse<dynamic>> requestPhoneOtp(
    @Body() RequestPhoneOtpRequest request,
  );

  @POST('/users/verify-phone')
  Future<GenericResponse<dynamic>> verifyPhone(
    @Body() VerifyPhoneRequest request,
  );

  @GET('/users/me')
  Future<GenericResponse<User>> getMe();

  @PUT('/users/update-seeker-profile')
  Future<GenericResponse<dynamic>> updateSeekerProfile(
    @Body() UpdateProfileRequest request,
  );
}
