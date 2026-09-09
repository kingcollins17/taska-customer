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
  @JsonKey(name: 'customer_profile')
  final CustomerProfile? customerProfile;
  final UserLocation? location;
  @JsonKey(name: 'average_ratings')
  final double? averageRatings;
  @JsonKey(name: 'credibility')
  final double? credibility;

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
    this.customerProfile,
    this.location,
    this.averageRatings,
    this.credibility,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
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

  CustomerProfile({this.id, this.firstName, this.lastName, this.addressLine});

  factory CustomerProfile.fromJson(Map<String, dynamic> json) =>
      _$CustomerProfileFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerProfileToJson(this);
}

@JsonSerializable()
class UserLocation {
  final String? id;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'region_id')
  final String? regionId;
  @JsonKey(name: 'address_line')
  final String? addressLine;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  UserLocation({
    this.id,
    this.userId,
    this.regionId,
    this.addressLine,
    this.createdAt,
    this.updatedAt,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) =>
      _$UserLocationFromJson(json);

  Map<String, dynamic> toJson() => _$UserLocationToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ProviderProfileDetail {
  final String? id;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final String? gender;
  @JsonKey(name: 'selfie_url')
  final String? selfieUrl;
  @JsonKey(name: 'is_online')
  final bool? isOnline;
  @JsonKey(name: 'duty_status')
  final String? dutyStatus;
  @JsonKey(name: 'last_heartbeat_at')
  final DateTime? lastHeartbeatAt;
  @JsonKey(name: 'total_tasks_completed')
  final int? totalTasksCompleted;

  ProviderProfileDetail({
    this.id,
    this.userId,
    this.firstName,
    this.lastName,
    this.gender,
    this.selfieUrl,
    this.isOnline,
    this.dutyStatus,
    this.lastHeartbeatAt,
    this.totalTasksCompleted,
  });

  factory ProviderProfileDetail.fromJson(Map<String, dynamic> json) =>
      _$ProviderProfileDetailFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderProfileDetailToJson(this);

  String get fullname => '${firstName ?? ''} ${lastName ?? ''}'.trim();
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
