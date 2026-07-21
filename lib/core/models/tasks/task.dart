import 'package:freezed_annotation/freezed_annotation.dart';

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
class Bid {
  final String? id;
  @JsonKey(name: 'task_id')
  final String? taskId;
  @JsonKey(name: 'provider_id')
  final String? providerId;
  final double? price;
  final String? message;
  @JsonKey(name: 'estimated_duration')
  final String? estimatedDuration;
  final String? status;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'updated_at')
  final DateTime? updatedAt;

  Bid({
    this.id,
    this.taskId,
    this.providerId,
    this.price,
    this.message,
    this.estimatedDuration,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Bid.fromJson(Map<String, dynamic> json) => _$BidFromJson(json);

  Map<String, dynamic> toJson() => _$BidToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Assignment {
  final String? id;
  @JsonKey(name: 'task_id')
  final String? taskId;
  @JsonKey(name: 'provider_id')
  final String? providerId;
  @JsonKey(name: 'accepted_bid_id')
  final String? acceptedBidId;
  @JsonKey(name: 'accepted_price')
  final double? acceptedPrice;
  @JsonKey(name: 'assigned_at')
  final DateTime? assignedAt;
  @JsonKey(name: 'started_at')
  final DateTime? startedAt;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  final String? status;

  Assignment({
    this.id,
    this.taskId,
    this.providerId,
    this.acceptedBidId,
    this.acceptedPrice,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.status,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) =>
      _$AssignmentFromJson(json);

  Map<String, dynamic> toJson() => _$AssignmentToJson(this);
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
  @JsonKey(name: 'budget_min')
  final double? budgetMin;
  @JsonKey(name: 'budget_max')
  final double? budgetMax;
  @JsonKey(name: 'pricing_model')
  final String? pricingModel;
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
  final Assignment? assignment;
  final List<TaskAttachment>? attachments;

  Task({
    this.id,
    this.customerId,
    this.regionId,
    this.title,
    this.description,
    this.categoryId,
    this.serviceId,
    this.budgetMin,
    this.budgetMax,
    this.pricingModel,
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
  });

  factory Task.fromJson(Map<String, dynamic> json) => _$TaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskToJson(this);
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
    @JsonKey(name: 'budget_min') double? budgetMin,
    @JsonKey(name: 'budget_max') double? budgetMax,
    @JsonKey(name: 'pricing_model') String? pricingModel,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'scheduled_start_at') DateTime? scheduledStartAt,
    List<CreateTaskLocationRequest>? locations,
  }) = _CreateTaskRequest;

  factory CreateTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateTaskRequestFromJson(json);
}
