import 'package:json_annotation/json_annotation.dart';
import 'package:seeker_app/core/models/tasks/assignment.dart';
import 'package:seeker_app/core/models/tasks/task.dart';

part 'pending_review_task.g.dart';

@JsonSerializable(explicitToJson: true)
class PendingReviewTask {
  final String? id;
  @JsonKey(name: 'customer_id')
  final String? customerId;
  final String? title;
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
  @JsonKey(name: 'scheduled_start_at')
  final DateTime? scheduledStartAt;
  @JsonKey(name: 'distance_km')
  final double? distanceKm;
  final TaskCustomer? customer;
  final TaskAssignmentProvider? provider;

  PendingReviewTask({
    this.id,
    this.customerId,
    this.title,
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
    this.scheduledStartAt,
    this.distanceKm,
    this.customer,
    this.provider,
  });

  factory PendingReviewTask.fromJson(Map<String, dynamic> json) =>
      _$PendingReviewTaskFromJson(json);

  Map<String, dynamic> toJson() => _$PendingReviewTaskToJson(this);
}
