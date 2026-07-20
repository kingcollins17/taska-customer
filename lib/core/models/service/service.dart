import 'package:freezed_annotation/freezed_annotation.dart';

part 'service.g.dart';

@JsonSerializable(explicitToJson: true)
class ServiceCategory {
  final String? id;
  final String? name;
  final String? description;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  ServiceCategory({
    this.id,
    this.name,
    this.description,
    this.imageUrl,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) =>
      _$ServiceCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceCategoryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Service {
  final String? id;
  final String? name;
  final String? description;
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @JsonKey(name: 'take_rate')
  final double? takeRate;
  @JsonKey(name: 'is_active')
  final bool? isActive;
  @JsonKey(name: 'category_id')
  final String? categoryId;
  final ServiceCategory? category;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Service({
    this.id,
    this.name,
    this.description,
    this.imageUrl,
    this.takeRate,
    this.isActive,
    this.categoryId,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) =>
      _$ServiceFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ServiceAvailability {
  @JsonKey(name: 'is_available')
  final bool? isAvailable;

  ServiceAvailability({this.isAvailable});

  factory ServiceAvailability.fromJson(Map<String, dynamic> json) =>
      _$ServiceAvailabilityFromJson(json);

  Map<String, dynamic> toJson() => _$ServiceAvailabilityToJson(this);
}
