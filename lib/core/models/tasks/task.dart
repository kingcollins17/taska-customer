import 'package:freezed_annotation/freezed_annotation.dart';

import 'assignment.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@JsonSerializable(explicitToJson: true)
class TaskLocation {
  final String? id;
  @JsonKey(name: 'task_id')
  final String? taskId;
  @JsonKey(name: 'location_type')
  final String? locationType;
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  @JsonKey(name: 'distance_km')
  final double? distanceKm;

  TaskLocation({
    this.id,
    this.taskId,
    this.locationType,
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
    this.createdAt,
    this.updatedAt,
    this.distanceKm,
  });

  factory TaskLocation.fromJson(Map<String, dynamic> json) =>
      _$TaskLocationFromJson(json);

  Map<String, dynamic> toJson() => _$TaskLocationToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TaskAttachment {
  final String? id;
  @JsonKey(name: 'task_id')
  final String? taskId;
  @JsonKey(name: 'storage_key')
  final String? storageKey;
  @JsonKey(name: 'file_name')
  final String? fileName;
  @JsonKey(name: 'file_size')
  final int? fileSize;
  @JsonKey(name: 'mime_type')
  final String? mimeType;
  final String? url;
  final String? type;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  TaskAttachment({
    this.id,
    this.taskId,
    this.storageKey,
    this.fileName,
    this.fileSize,
    this.mimeType,
    this.url,
    this.type,
    this.createdAt,
  });

  factory TaskAttachment.fromJson(Map<String, dynamic> json) =>
      _$TaskAttachmentFromJson(json);

  Map<String, dynamic> toJson() => _$TaskAttachmentToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TaskCustomer {
  final String? id;
  final String? fullname;
  final String? email;
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;
  @JsonKey(name: 'average_ratings')
  final double? averageRatings;
  @JsonKey(name: 'credibility_score')
  final double? credibilityScore;
  final String? gender;

  TaskCustomer({
    this.id,
    this.fullname,
    this.email,
    this.phoneNumber,
    this.averageRatings,
    this.credibilityScore,
    this.gender,
  });

  factory TaskCustomer.fromJson(Map<String, dynamic> json) =>
      _$TaskCustomerFromJson(json);

  Map<String, dynamic> toJson() => _$TaskCustomerToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Task {
  final String? id;
  @JsonKey(name: 'customer_id')
  final String? customerId;
  @JsonKey(name: 'region_id')
  final String? regionId;
  final String? title;
  final String? description;
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @JsonKey(name: 'service_id')
  final String? serviceId;
  @JsonKey(name: 'base_price')
  final double? basePrice;
  @JsonKey(name: 'distance_fee')
  final double? distanceFee;
  @JsonKey(name: 'time_fee')
  final double? timeFee;
  @JsonKey(name: 'urgency_fee')
  final double? urgencyFee;
  @JsonKey(name: 'complexity_fee')
  final double? complexityFee;
  @JsonKey(name: 'surge_multiplier')
  final double? surgeMultiplier;
  @JsonKey(name: 'customer_total_price')
  final double? customerTotalPrice;
  @JsonKey(name: 'platform_fee')
  final double? platformFee;
  @JsonKey(name: 'provider_payout')
  final double? providerPayout;
  final String? status;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @JsonKey(name: 'scheduled_start_at')
  final DateTime? scheduledStartAt;
  @JsonKey(name: 'start_pin')
  final String? startPin;
  @JsonKey(name: 'completion_pin')
  final String? completionPin;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;
  final List<TaskLocation>? locations;
  final TaskAssignment? assignment;
  final List<TaskAttachment>? attachments;
  final TaskCustomer? customer;

  Task({
    this.id,
    this.customerId,
    this.regionId,
    this.title,
    this.description,
    this.categoryId,
    this.serviceId,
    this.basePrice,
    this.distanceFee,
    this.timeFee,
    this.urgencyFee,
    this.complexityFee,
    this.surgeMultiplier,
    this.customerTotalPrice,
    this.platformFee,
    this.providerPayout,
    this.status,
    this.createdAt,
    this.expiresAt,
    this.scheduledStartAt,
    this.startPin,
    this.completionPin,
    this.updatedAt,
    this.locations,
    this.assignment,
    this.attachments,
    this.customer,
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DispatchAttempt {
  final String? id;
  @JsonKey(name: 'task_id')
  final String? taskId;
  @JsonKey(name: 'provider_id')
  final String? providerId;
  @JsonKey(name: 'sequence_order')
  final int? sequenceOrder;
  @JsonKey(name: 'match_score')
  final double? matchScore;
  @JsonKey(name: 'offered_payout')
  final double? offeredPayout;
  @JsonKey(name: 'pinged_at')
  final DateTime? pingedAt;
  @JsonKey(name: 'expires_at')
  final DateTime? expiresAt;
  @JsonKey(name: 'responded_at')
  final DateTime? respondedAt;
  final String? status;

  DispatchAttempt({
    this.id,
    this.taskId,
    this.providerId,
    this.sequenceOrder,
    this.matchScore,
    this.offeredPayout,
    this.pingedAt,
    this.expiresAt,
    this.respondedAt,
    this.status,
  });

  factory DispatchAttempt.fromJson(Map<String, dynamic> json) =>
      _$DispatchAttemptFromJson(json);

  Map<String, dynamic> toJson() => _$DispatchAttemptToJson(this);
}

@freezed
abstract class CreateTaskLocationRequest with _$CreateTaskLocationRequest {
  @JsonSerializable(explicitToJson: true)
  const factory CreateTaskLocationRequest({
    @JsonKey(name: 'location_type') @Default('service') String? locationType,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? state,
    String? country,
  }) = _CreateTaskLocationRequest;

  factory CreateTaskLocationRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskLocationRequestFromJson(json);
}

@freezed
abstract class CreateTaskRequest with _$CreateTaskRequest {
  @JsonSerializable(explicitToJson: true)
  const factory CreateTaskRequest({
    String? title,
    String? description,
    @JsonKey(name: 'category_id') String? categoryId,
    @JsonKey(name: 'service_id') String? serviceId,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'scheduled_start_at') DateTime? scheduledStartAt,
    List<CreateTaskLocationRequest>? locations,
  }) = _CreateTaskRequest;

  factory CreateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskRequestFromJson(json);
}
