import 'package:json_annotation/json_annotation.dart';

part 'user_requests.g.dart';

@JsonSerializable()
class RequestEmailOtpRequest {
  final String email;

  RequestEmailOtpRequest({required this.email});

  factory RequestEmailOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$RequestEmailOtpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RequestEmailOtpRequestToJson(this);
}

@JsonSerializable()
class VerifyEmailRequest {
  final String email;
  final String code;

  VerifyEmailRequest({required this.email, required this.code});

  factory VerifyEmailRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyEmailRequestToJson(this);
}

@JsonSerializable()
class RequestPhoneOtpRequest {
  @JsonKey(name: 'phone_number')
  final String phoneNumber;

  RequestPhoneOtpRequest({required this.phoneNumber});

  factory RequestPhoneOtpRequest.fromJson(Map<String, dynamic> json) =>
      _$RequestPhoneOtpRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RequestPhoneOtpRequestToJson(this);
}

@JsonSerializable()
class VerifyPhoneRequest {
  @JsonKey(name: 'phone_number')
  final String phoneNumber;
  final String code;

  VerifyPhoneRequest({required this.phoneNumber, required this.code});

  factory VerifyPhoneRequest.fromJson(Map<String, dynamic> json) =>
      _$VerifyPhoneRequestFromJson(json);

  Map<String, dynamic> toJson() => _$VerifyPhoneRequestToJson(this);
}
