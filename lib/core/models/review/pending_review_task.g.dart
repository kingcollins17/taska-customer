// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_review_task.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PendingReviewTask _$PendingReviewTaskFromJson(Map<String, dynamic> json) =>
    PendingReviewTask(
      id: json['id'] as String?,
      customerId: json['customer_id'] as String?,
      title: json['title'] as String?,
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
      scheduledStartAt: json['scheduled_start_at'] == null
          ? null
          : DateTime.parse(json['scheduled_start_at'] as String),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      customer: json['customer'] == null
          ? null
          : TaskCustomer.fromJson(json['customer'] as Map<String, dynamic>),
      provider: json['provider'] == null
          ? null
          : TaskAssignmentProvider.fromJson(
              json['provider'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$PendingReviewTaskToJson(PendingReviewTask instance) =>
    <String, dynamic>{
      'id': instance.id,
      'customer_id': instance.customerId,
      'title': instance.title,
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
      'scheduled_start_at': instance.scheduledStartAt?.toIso8601String(),
      'distance_km': instance.distanceKm,
      'customer': instance.customer?.toJson(),
      'provider': instance.provider?.toJson(),
    };
