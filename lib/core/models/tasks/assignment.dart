import 'package:json_annotation/json_annotation.dart';

part 'assignment.g.dart';

@JsonSerializable(explicitToJson: true)
class TaskAssignment {
  final String? id;
  @JsonKey(name: 'task_id')
  final String? taskId;
  @JsonKey(name: 'provider_id')
  final String? providerId;
  @JsonKey(name: 'accepted_dispatch_attempt_id')
  final String? acceptedDispatchAttemptId;
  @JsonKey(name: 'accepted_price')
  final double? acceptedPrice;
  @JsonKey(name: 'assigned_at')
  final DateTime? assignedAt;
  @JsonKey(name: 'started_at')
  final DateTime? startedAt;
  @JsonKey(name: 'completed_at')
  final DateTime? completedAt;
  final String? status;
  final TaskAssignmentTask? task;
  final TaskAssignmentProvider? provider;

  TaskAssignment({
    this.id,
    this.taskId,
    this.providerId,
    this.acceptedDispatchAttemptId,
    this.acceptedPrice,
    this.assignedAt,
    this.startedAt,
    this.completedAt,
    this.status,
    this.task,
    this.provider,
  });

  factory TaskAssignment.fromJson(Map<String, dynamic> json) =>
      _$TaskAssignmentFromJson(json);

  Map<String, dynamic> toJson() => _$TaskAssignmentToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TaskAssignmentTask {
  final String? id;
  final String? title;
  final String? description;
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @JsonKey(name: 'service_id')
  final String? serviceId;
  final String? status;
  @JsonKey(name: 'scheduled_start_at')
  final DateTime? scheduledStartAt;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'provider_payout')
  final double? providerPayout;
  @JsonKey(name: 'customer_total_price')
  final double? customerTotalPrice;

  TaskAssignmentTask({
    this.id,
    this.title,
    this.description,
    this.categoryId,
    this.serviceId,
    this.status,
    this.scheduledStartAt,
    this.createdAt,
    this.providerPayout,
    this.customerTotalPrice,
  });

  factory TaskAssignmentTask.fromJson(Map<String, dynamic> json) =>
      _$TaskAssignmentTaskFromJson(json);

  Map<String, dynamic> toJson() => _$TaskAssignmentTaskToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TaskAssignmentProvider {
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
  @JsonKey(name: 'profile_picture_url')
  final String? profilePictureUrl;
  @JsonKey(name: 'selfie_url')
  final String? selfieUrl;
  @JsonKey(name: 'total_tasks_completed')
  final int? totalTasksCompleted;
  final ProviderLocation? location;

  TaskAssignmentProvider({
    this.id,
    this.fullname,
    this.email,
    this.phoneNumber,
    this.averageRatings,
    this.credibilityScore,
    this.gender,
    this.profilePictureUrl,
    this.selfieUrl,
    this.totalTasksCompleted,
    this.location,
  });

  factory TaskAssignmentProvider.fromJson(Map<String, dynamic> json) =>
      _$TaskAssignmentProviderFromJson(json);

  Map<String, dynamic> toJson() => _$TaskAssignmentProviderToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ProviderLocation {
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

  ProviderLocation({
    this.id,
    this.userId,
    this.regionId,
    this.addressLine,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  factory ProviderLocation.fromJson(Map<String, dynamic> json) =>
      _$ProviderLocationFromJson(json);

  Map<String, dynamic> toJson() => _$ProviderLocationToJson(this);
}
