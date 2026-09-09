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
  averageRatings: (json['average_ratings'] as num?)?.toDouble(),
  credibility: (json['credibility'] as num?)?.toDouble(),
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
  'customer_profile': instance.customerProfile?.toJson(),
  'location': instance.location?.toJson(),
  'average_ratings': instance.averageRatings,
  'credibility': instance.credibility,
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

ProviderProfileDetail _$ProviderProfileDetailFromJson(
  Map<String, dynamic> json,
) => ProviderProfileDetail(
  id: json['id'] as String?,
  userId: json['user_id'] as String?,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  gender: json['gender'] as String?,
  selfieUrl: json['selfie_url'] as String?,
  isOnline: json['is_online'] as bool?,
  dutyStatus: json['duty_status'] as String?,
  lastHeartbeatAt: json['last_heartbeat_at'] == null
      ? null
      : DateTime.parse(json['last_heartbeat_at'] as String),
  totalTasksCompleted: (json['total_tasks_completed'] as num?)?.toInt(),
);

Map<String, dynamic> _$ProviderProfileDetailToJson(
  ProviderProfileDetail instance,
) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'first_name': instance.firstName,
  'last_name': instance.lastName,
  'gender': instance.gender,
  'selfie_url': instance.selfieUrl,
  'is_online': instance.isOnline,
  'duty_status': instance.dutyStatus,
  'last_heartbeat_at': instance.lastHeartbeatAt?.toIso8601String(),
  'total_tasks_completed': instance.totalTasksCompleted,
};

PublicProviderProfile _$PublicProviderProfileFromJson(
  Map<String, dynamic> json,
) => PublicProviderProfile(
  id: json['id'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phone_number'] as String?,
  type: json['type'] as String?,
  isActive: json['is_active'] as bool?,
  emailVerified: json['email_verified'] as bool?,
  phoneVerified: json['phone_verified'] as bool?,
  credibilityScore: (json['credibility_score'] as num?)?.toDouble(),
  averageRatings: (json['average_ratings'] as num?)?.toDouble(),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  regionId: json['region_id'] as String?,
  location: json['location'] == null
      ? null
      : UserLocation.fromJson(json['location'] as Map<String, dynamic>),
  profile: json['profile'] == null
      ? null
      : ProviderProfileDetail.fromJson(json['profile'] as Map<String, dynamic>),
);

Map<String, dynamic> _$PublicProviderProfileToJson(
  PublicProviderProfile instance,
) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'phone_number': instance.phoneNumber,
  'type': instance.type,
  'is_active': instance.isActive,
  'email_verified': instance.emailVerified,
  'phone_verified': instance.phoneVerified,
  'credibility_score': instance.credibilityScore,
  'average_ratings': instance.averageRatings,
  'created_at': instance.createdAt?.toIso8601String(),
  'region_id': instance.regionId,
  'location': instance.location?.toJson(),
  'profile': instance.profile?.toJson(),
};
