// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskLocation _$TaskLocationFromJson(Map<String, dynamic> json) => TaskLocation(
  id: json['id'] as String?,
  taskId: json['task_id'] as String?,
  locationType: json['location_type'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  address: json['address'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  country: json['country'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  distanceKm: (json['distance_km'] as num?)?.toDouble(),
);

Map<String, dynamic> _$TaskLocationToJson(TaskLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'location_type': instance.locationType,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'address': instance.address,
      'city': instance.city,
      'state': instance.state,
      'country': instance.country,
      'created_at': instance.createdAt?.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
      'distance_km': instance.distanceKm,
    };

TaskAttachment _$TaskAttachmentFromJson(Map<String, dynamic> json) =>
    TaskAttachment(
      id: json['id'] as String?,
      taskId: json['task_id'] as String?,
      storageKey: json['storage_key'] as String?,
      fileName: json['file_name'] as String?,
      fileSize: (json['file_size'] as num?)?.toInt(),
      mimeType: json['mime_type'] as String?,
      url: json['url'] as String?,
      type: json['type'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TaskAttachmentToJson(TaskAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'storage_key': instance.storageKey,
      'file_name': instance.fileName,
      'file_size': instance.fileSize,
      'mime_type': instance.mimeType,
      'url': instance.url,
      'type': instance.type,
      'created_at': instance.createdAt?.toIso8601String(),
    };

TaskCustomer _$TaskCustomerFromJson(Map<String, dynamic> json) => TaskCustomer(
  id: json['id'] as String?,
  fullname: json['fullname'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phone_number'] as String?,
  averageRatings: (json['average_ratings'] as num?)?.toDouble(),
  credibilityScore: (json['credibility_score'] as num?)?.toDouble(),
  gender: json['gender'] as String?,
);

Map<String, dynamic> _$TaskCustomerToJson(TaskCustomer instance) =>
    <String, dynamic>{
      'id': instance.id,
      'fullname': instance.fullname,
      'email': instance.email,
      'phone_number': instance.phoneNumber,
      'average_ratings': instance.averageRatings,
      'credibility_score': instance.credibilityScore,
      'gender': instance.gender,
    };

Task _$TaskFromJson(Map<String, dynamic> json) => Task(
  id: json['id'] as String?,
  customerId: json['customer_id'] as String?,
  regionId: json['region_id'] as String?,
  title: json['title'] as String?,
  description: json['description'] as String?,
  categoryId: json['category_id'] as String?,
  serviceId: json['service_id'] as String?,
  basePrice: (json['base_price'] as num?)?.toDouble(),
  distanceFee: (json['distance_fee'] as num?)?.toDouble(),
  timeFee: (json['time_fee'] as num?)?.toDouble(),
  urgencyFee: (json['urgency_fee'] as num?)?.toDouble(),
  complexityFee: (json['complexity_fee'] as num?)?.toDouble(),
  surgeMultiplier: (json['surge_multiplier'] as num?)?.toDouble(),
  customerTotalPrice: (json['customer_total_price'] as num?)?.toDouble(),
  platformFee: (json['platform_fee'] as num?)?.toDouble(),
  providerPayout: (json['provider_payout'] as num?)?.toDouble(),
  status: json['status'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  expiresAt: json['expires_at'] == null
      ? null
      : DateTime.parse(json['expires_at'] as String),
  scheduledStartAt: json['scheduled_start_at'] == null
      ? null
      : DateTime.parse(json['scheduled_start_at'] as String),
  startPin: json['start_pin'] as String?,
  completionPin: json['completion_pin'] as String?,
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  cancellationReason: json['cancellation_reason'] as String?,
  locations: (json['locations'] as List<dynamic>?)
      ?.map((e) => TaskLocation.fromJson(e as Map<String, dynamic>))
      .toList(),
  assignment: json['assignment'] == null
      ? null
      : TaskAssignment.fromJson(json['assignment'] as Map<String, dynamic>),
  attachments: (json['attachments'] as List<dynamic>?)
      ?.map((e) => TaskAttachment.fromJson(e as Map<String, dynamic>))
      .toList(),
  customer: json['customer'] == null
      ? null
      : TaskCustomer.fromJson(json['customer'] as Map<String, dynamic>),
  assignedProviderId: json['assigned_provider_id'] as String?,
  paymentStatus: json['payment_status'] as String?,
  payout: json['payout'] == null
      ? null
      : Payout.fromJson(json['payout'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TaskToJson(Task instance) => <String, dynamic>{
  'id': instance.id,
  'customer_id': instance.customerId,
  'region_id': instance.regionId,
  'title': instance.title,
  'description': instance.description,
  'category_id': instance.categoryId,
  'service_id': instance.serviceId,
  'base_price': instance.basePrice,
  'distance_fee': instance.distanceFee,
  'time_fee': instance.timeFee,
  'urgency_fee': instance.urgencyFee,
  'complexity_fee': instance.complexityFee,
  'surge_multiplier': instance.surgeMultiplier,
  'customer_total_price': instance.customerTotalPrice,
  'platform_fee': instance.platformFee,
  'provider_payout': instance.providerPayout,
  'status': instance.status,
  'created_at': instance.createdAt?.toIso8601String(),
  'expires_at': instance.expiresAt?.toIso8601String(),
  'scheduled_start_at': instance.scheduledStartAt?.toIso8601String(),
  'start_pin': instance.startPin,
  'completion_pin': instance.completionPin,
  'updated_at': instance.updatedAt?.toIso8601String(),
  'cancellation_reason': instance.cancellationReason,
  'locations': instance.locations?.map((e) => e.toJson()).toList(),
  'assignment': instance.assignment?.toJson(),
  'attachments': instance.attachments?.map((e) => e.toJson()).toList(),
  'customer': instance.customer?.toJson(),
  'assigned_provider_id': instance.assignedProviderId,
  'payment_status': instance.paymentStatus,
  'payout': instance.payout?.toJson(),
};

DispatchAttempt _$DispatchAttemptFromJson(Map<String, dynamic> json) =>
    DispatchAttempt(
      id: json['id'] as String?,
      taskId: json['task_id'] as String?,
      providerId: json['provider_id'] as String?,
      sequenceOrder: (json['sequence_order'] as num?)?.toInt(),
      matchScore: (json['match_score'] as num?)?.toDouble(),
      offeredPayout: (json['offered_payout'] as num?)?.toDouble(),
      pingedAt: json['pinged_at'] == null
          ? null
          : DateTime.parse(json['pinged_at'] as String),
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      respondedAt: json['responded_at'] == null
          ? null
          : DateTime.parse(json['responded_at'] as String),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$DispatchAttemptToJson(DispatchAttempt instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'provider_id': instance.providerId,
      'sequence_order': instance.sequenceOrder,
      'match_score': instance.matchScore,
      'offered_payout': instance.offeredPayout,
      'pinged_at': instance.pingedAt?.toIso8601String(),
      'expires_at': instance.expiresAt?.toIso8601String(),
      'responded_at': instance.respondedAt?.toIso8601String(),
      'status': instance.status,
    };

_CreateTaskLocationRequest _$CreateTaskLocationRequestFromJson(
  Map<String, dynamic> json,
) => _CreateTaskLocationRequest(
  locationType: json['location_type'] as String? ?? 'service',
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  address: json['address'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  country: json['country'] as String?,
);

Map<String, dynamic> _$CreateTaskLocationRequestToJson(
  _CreateTaskLocationRequest instance,
) => <String, dynamic>{
  'location_type': instance.locationType,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'address': instance.address,
  'city': instance.city,
  'state': instance.state,
  'country': instance.country,
};

_CreateTaskRequest _$CreateTaskRequestFromJson(Map<String, dynamic> json) =>
    _CreateTaskRequest(
      title: json['title'] as String?,
      description: json['description'] as String?,
      categoryId: json['category_id'] as String?,
      serviceId: json['service_id'] as String?,
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      scheduledStartAt: json['scheduled_start_at'] == null
          ? null
          : DateTime.parse(json['scheduled_start_at'] as String),
      locations: (json['locations'] as List<dynamic>?)
          ?.map(
            (e) =>
                CreateTaskLocationRequest.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$CreateTaskRequestToJson(_CreateTaskRequest instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'category_id': instance.categoryId,
      'service_id': instance.serviceId,
      'expires_at': instance.expiresAt?.toIso8601String(),
      'scheduled_start_at': instance.scheduledStartAt?.toIso8601String(),
      'locations': instance.locations,
    };
