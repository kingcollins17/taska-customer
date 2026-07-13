import 'package:json_annotation/json_annotation.dart';

part 'user_models.g.dart';

@JsonSerializable()
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

  CustomerProfile({
    this.id,
    this.firstName,
    this.lastName,
    this.addressLine,
  });

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
