// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phone_number'] as String?,
  type: json['type'] as String?,
  isActive: json['is_active'] as bool?,
  emailVerified: json['email_verified'] as bool?,
  phoneVerified: json['phone_verified'] as bool?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  regionId: json['region_id'] as String?,
  customerProfile: json['customer_profile'] == null
      ? null
      : CustomerProfile.fromJson(
          json['customer_profile'] as Map<String, dynamic>,
        ),
  location: json['location'] == null
      ? null
      : UserLocation.fromJson(json['location'] as Map<String, dynamic>),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'phone_number': instance.phoneNumber,
  'type': instance.type,
  'is_active': instance.isActive,
  'email_verified': instance.emailVerified,
  'phone_verified': instance.phoneVerified,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
  'region_id': instance.regionId,
  'customer_profile': instance.customerProfile,
  'location': instance.location,
};

CustomerProfile _$CustomerProfileFromJson(Map<String, dynamic> json) =>
    CustomerProfile(
      id: json['id'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      addressLine: json['address_line'] as String?,
    );

Map<String, dynamic> _$CustomerProfileToJson(CustomerProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'address_line': instance.addressLine,
    };

UserLocation _$UserLocationFromJson(Map<String, dynamic> json) => UserLocation(
  id: json['id'] as String?,
  userId: json['user_id'] as String?,
  regionId: json['region_id'] as String?,
  addressLine: json['address_line'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserLocationToJson(UserLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'region_id': instance.regionId,
      'address_line': instance.addressLine,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
