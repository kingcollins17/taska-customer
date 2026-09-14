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
  metadata: json['meta_data'],
  stats: json['stats'] == null
      ? null
      : UserStats.fromJson(json['stats'] as Map<String, dynamic>),
  customerProfile: json['customer_profile'] == null
      ? null
      : CustomerProfile.fromJson(
          json['customer_profile'] as Map<String, dynamic>,
        ),
  providerProfile: json['provider_profile'] == null
      ? null
      : ProviderProfile.fromJson(
          json['provider_profile'] as Map<String, dynamic>,
        ),
  devices: json['devices'] as List<dynamic>?,
  location: json['location'] == null
      ? null
      : UserLocation.fromJson(json['location'] as Map<String, dynamic>),
  paymentAccount: json['payment_account'] == null
      ? null
      : PaymentAccount.fromJson(
          json['payment_account'] as Map<String, dynamic>,
        ),
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
  'meta_data': instance.metadata,
  'stats': instance.stats?.toJson(),
  'customer_profile': instance.customerProfile?.toJson(),
  'provider_profile': instance.providerProfile?.toJson(),
  'devices': instance.devices,
  'location': instance.location?.toJson(),
  'payment_account': instance.paymentAccount?.toJson(),
};

UserStats _$UserStatsFromJson(Map<String, dynamic> json) => UserStats(
  id: json['id'] as String?,
  userId: json['user_id'] as String?,
  credibilityScore: (json['credibility_score'] as num?)?.toDouble(),
  averageRatings: (json['average_ratings'] as num?)?.toDouble(),
  totalRatings: (json['total_ratings'] as num?)?.toInt(),
  acceptanceRate30d: (json['acceptance_rate_30d'] as num?)?.toDouble(),
  completionRate30d: (json['completion_rate_30d'] as num?)?.toDouble(),
  currentTier: (json['current_tier'] as num?)?.toInt(),
  totalTasksCompleted: (json['total_tasks_completed'] as num?)?.toInt(),
  totalTasksPosted: (json['total_tasks_posted'] as num?)?.toInt(),
  consecutiveDeclines: (json['consecutive_declines'] as num?)?.toInt(),
  cancellationCount: (json['cancellation_count'] as num?)?.toInt(),
);

Map<String, dynamic> _$UserStatsToJson(UserStats instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'credibility_score': instance.credibilityScore,
  'average_ratings': instance.averageRatings,
  'total_ratings': instance.totalRatings,
  'acceptance_rate_30d': instance.acceptanceRate30d,
  'completion_rate_30d': instance.completionRate30d,
  'current_tier': instance.currentTier,
  'total_tasks_completed': instance.totalTasksCompleted,
  'total_tasks_posted': instance.totalTasksPosted,
  'consecutive_declines': instance.consecutiveDeclines,
  'cancellation_count': instance.cancellationCount,
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

ProviderProfile _$ProviderProfileFromJson(Map<String, dynamic> json) =>
    ProviderProfile(
      id: json['id'] as String?,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      selfieUrl: json['selfie_url'] as String?,
      gender: json['gender'] as String?,
      kycStatus: json['kyc_status'] as String?,
      providerReference: json['provider_reference'] as String?,
      livenessScore: (json['liveness_score'] as num?)?.toDouble(),
      verifiedAt: json['verified_at'] == null
          ? null
          : DateTime.parse(json['verified_at'] as String),
      addressLine: json['address_line'] as String?,
      isOnline: json['is_online'] as bool?,
      dutyStatus: json['duty_status'] as String?,
      lastHeartbeatAt: json['last_heartbeat_at'] == null
          ? null
          : DateTime.parse(json['last_heartbeat_at'] as String),
      services: json['services'] as List<dynamic>?,
      kycDocuments: json['kyc_documents'] as List<dynamic>?,
    );

Map<String, dynamic> _$ProviderProfileToJson(ProviderProfile instance) =>
    <String, dynamic>{
      'id': instance.id,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'selfie_url': instance.selfieUrl,
      'gender': instance.gender,
      'kyc_status': instance.kycStatus,
      'provider_reference': instance.providerReference,
      'liveness_score': instance.livenessScore,
      'verified_at': instance.verifiedAt?.toIso8601String(),
      'address_line': instance.addressLine,
      'is_online': instance.isOnline,
      'duty_status': instance.dutyStatus,
      'last_heartbeat_at': instance.lastHeartbeatAt?.toIso8601String(),
      'services': instance.services,
      'kyc_documents': instance.kycDocuments,
    };

UserLocation _$UserLocationFromJson(Map<String, dynamic> json) => UserLocation(
  id: json['id'] as String?,
  userId: json['user_id'] as String?,
  regionId: json['region_id'] as String?,
  addressLine: json['address_line'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
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
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };

PaymentAccount _$PaymentAccountFromJson(Map<String, dynamic> json) =>
    PaymentAccount(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      provider: json['provider'] as String?,
      externalAccountId: json['external_account_id'] as String?,
      accountName: json['account_name'] as String?,
      accountMetadata: json['account_metadata'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool?,
    );

Map<String, dynamic> _$PaymentAccountToJson(PaymentAccount instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'provider': instance.provider,
      'external_account_id': instance.externalAccountId,
      'account_name': instance.accountName,
      'account_metadata': instance.accountMetadata,
      'is_active': instance.isActive,
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
      : ProviderProfile.fromJson(json['profile'] as Map<String, dynamic>),
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
