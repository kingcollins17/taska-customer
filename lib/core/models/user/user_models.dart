import 'package:json_annotation/json_annotation.dart';

part 'user_models.g.dart';

@JsonSerializable(explicitToJson: true)
class User {
  final String? id;
  final String? email;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String? type;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'email_verified')
  final bool? emailVerified;
  @JsonKey(name: 'phone_verified')
  final bool? phoneVerified;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'region_id')
  final String? regionId;
  @JsonKey(name: 'meta_data')
  final dynamic metadata;
  final UserStats? stats;
  @JsonKey(name: 'customer_profile')
  final CustomerProfile? customerProfile;
  @JsonKey(name: 'provider_profile')
  final ProviderProfile? providerProfile;
  final List<dynamic>? devices;
  final UserLocation? location;
  @JsonKey(name: 'payment_account')
  final PaymentAccount? paymentAccount;

  User({
    this.id,
    this.email,
    this.phoneNumber,
    this.type,
    this.isActive,
    this.emailVerified,
    this.phoneVerified,
    this.createdAt,
    this.updatedAt,
    this.regionId,
    this.metadata,
    this.stats,
    this.customerProfile,
    this.providerProfile,
    this.devices,
    this.location,
    this.paymentAccount,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);

  double? get averageRatings => stats?.averageRatings;
  double? get credibility => stats?.credibilityScore;
}

@JsonSerializable()
class UserStats {
  final String? id;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'credibility_score')
  final double? credibilityScore;
  @JsonKey(name: 'average_ratings')
  final double? averageRatings;
  @JsonKey(name: 'total_ratings')
  final int? totalRatings;
  @JsonKey(name: 'acceptance_rate_30d')
  final double? acceptanceRate30d;
  @JsonKey(name: 'completion_rate_30d')
  final double? completionRate30d;
  @JsonKey(name: 'current_tier')
  final int? currentTier;
  @JsonKey(name: 'total_tasks_completed')
  final int? totalTasksCompleted;
  @JsonKey(name: 'total_tasks_posted')
  final int? totalTasksPosted;
  @JsonKey(name: 'consecutive_declines')
  final int? consecutiveDeclines;
  @JsonKey(name: 'cancellation_count')
  final int? cancellationCount;

  UserStats({
    this.id,
    this.userId,
    this.credibilityScore,
    this.averageRatings,
    this.totalRatings,
    this.acceptanceRate30d,
    this.completionRate30d,
    this.currentTier,
    this.totalTasksCompleted,
    this.totalTasksPosted,
    this.consecutiveDeclines,
    this.cancellationCount,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) =>
      _$UserStatsFromJson(json);

  Map<String, dynamic> toJson() => _$UserStatsToJson(this);
}

@JsonSerializable()
class CustomerProfile {
  final String? id;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'address_line')
  final String? addressLine;

  CustomerProfile({
    this.id,
    this.firstName,
    this.lastName,
    this.addressLine,
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> json) =>
      _$CustomerProfileFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerProfileToJson(this);

  String get fullname => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}

@JsonSerializable(explicitToJson: true)
class ProviderProfile {
  final String? id;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  @JsonKey(name: 'selfie_url')
  final String? selfieUrl;
  final String? gender;
  @JsonKey(name: 'kyc_status')
  final String? kycStatus;
  @JsonKey(name: 'provider_reference')
  final String? providerReference;
  @JsonKey(name: 'liveness_score')
  final double? livenessScore;
  @JsonKey(name: 'verified_at')
  final DateTime? verifiedAt;
  @JsonKey(name: 'address_line')
  final String? addressLine;
  @JsonKey(name: 'is_online')
  final bool? isOnline;
  @JsonKey(name: 'duty_status')
  final String? dutyStatus;
  @JsonKey(name: 'last_heartbeat_at')
  final DateTime? lastHeartbeatAt;
  final List<dynamic>? services;
  @JsonKey(name: 'kyc_documents')
  final List<dynamic>? kycDocuments;

  ProviderProfile({
    this.id,
    this.firstName,
    this.lastName,
    this.selfieUrl,
    this.gender,
    this.kycStatus,
    this.providerReference,
    this.livenessScore,
    this.verifiedAt,
    this.addressLine,
    this.isOnline,
    this.dutyStatus,
    this.lastHeartbeatAt,
    this.services,
    this.kycDocuments,
  });

  factory ProviderProfile.fromJson(Map<String, dynamic> json) =>
      _$ProviderProfileFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderProfileToJson(this);

  String get fullname => '${firstName ?? ''} ${lastName ?? ''}'.trim();
}

typedef ProviderProfileDetail = ProviderProfile;

@JsonSerializable()
class UserLocation {
  final String? id;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'region_id')
  final String? regionId;
  @JsonKey(name: 'address_line')
  final String? addressLine;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  UserLocation({
    this.id,
    this.userId,
    this.regionId,
    this.addressLine,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) =>
      _$UserLocationFromJson(json);

  Map<String, dynamic> toJson() => _$UserLocationToJson(this);
}

@JsonSerializable()
class PaymentAccount {
  final String? id;
  @JsonKey(name: 'user_id')
  final String? userId;
  final String? provider;
  @JsonKey(name: 'external_account_id')
  final String? externalAccountId;
  @JsonKey(name: 'account_name')
  final String? accountName;
  @JsonKey(name: 'account_metadata')
  final Map<String, dynamic>? accountMetadata;
  @JsonKey(name: 'is_active')
  final bool? isActive;

  PaymentAccount({
    this.id,
    this.userId,
    this.provider,
    this.externalAccountId,
    this.accountName,
    this.accountMetadata,
    this.isActive,
  });

  factory PaymentAccount.fromJson(Map<String, dynamic> json) =>
      _$PaymentAccountFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentAccountToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PublicProviderProfile {
  final String? id;
  final String? email;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  final String? type;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'email_verified')
  final bool? emailVerified;
  @JsonKey(name: 'phone_verified')
  final bool? phoneVerified;
  @JsonKey(name: 'credibility_score')
  final double? credibilityScore;
  @JsonKey(name: 'average_ratings')
  final double? averageRatings;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'region_id')
  final String? regionId;
  final UserLocation? location;
  final ProviderProfileDetail? profile;

  PublicProviderProfile({
    this.id,
    this.email,
    this.phoneNumber,
    this.type,
    this.isActive,
    this.emailVerified,
    this.phoneVerified,
    this.credibilityScore,
    this.averageRatings,
    this.createdAt,
    this.regionId,
    this.location,
    this.profile,
  });

  factory PublicProviderProfile.fromJson(Map<String, dynamic> json) =>
      _$PublicProviderProfileFromJson(json);

  Map<String, dynamic> toJson() => _$PublicProviderProfileToJson(this);

  String get fullname {
    if (profile != null && profile!.fullname.isNotEmpty) {
      return profile!.fullname;
    }
    return email ?? 'Tasker';
  }
}
