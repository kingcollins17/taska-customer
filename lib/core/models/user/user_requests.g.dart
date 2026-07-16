// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_requests.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestEmailOtpRequest _$RequestEmailOtpRequestFromJson(
  Map<String, dynamic> json,
) => RequestEmailOtpRequest(email: json['email'] as String);

Map<String, dynamic> _$RequestEmailOtpRequestToJson(
  RequestEmailOtpRequest instance,
) => <String, dynamic>{'email': instance.email};

VerifyEmailRequest _$VerifyEmailRequestFromJson(Map<String, dynamic> json) =>
    VerifyEmailRequest(
      email: json['email'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$VerifyEmailRequestToJson(VerifyEmailRequest instance) =>
    <String, dynamic>{'email': instance.email, 'code': instance.code};

RequestPhoneOtpRequest _$RequestPhoneOtpRequestFromJson(
  Map<String, dynamic> json,
) => RequestPhoneOtpRequest(phoneNumber: json['phone_number'] as String);

Map<String, dynamic> _$RequestPhoneOtpRequestToJson(
  RequestPhoneOtpRequest instance,
) => <String, dynamic>{'phone_number': instance.phoneNumber};

VerifyPhoneRequest _$VerifyPhoneRequestFromJson(Map<String, dynamic> json) =>
    VerifyPhoneRequest(
      phoneNumber: json['phone_number'] as String,
      code: json['code'] as String,
    );

Map<String, dynamic> _$VerifyPhoneRequestToJson(VerifyPhoneRequest instance) =>
    <String, dynamic>{
      'phone_number': instance.phoneNumber,
      'code': instance.code,
    };

UpdateProfileRequest _$UpdateProfileRequestFromJson(
  Map<String, dynamic> json,
) => UpdateProfileRequest(
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  gender: json['gender'] as String?,
  phoneNumber: json['phone_number'] as String?,
);

Map<String, dynamic> _$UpdateProfileRequestToJson(
  UpdateProfileRequest instance,
) => <String, dynamic>{
  'first_name': ?instance.firstName,
  'last_name': ?instance.lastName,
  'gender': ?instance.gender,
  'phone_number': ?instance.phoneNumber,
};
