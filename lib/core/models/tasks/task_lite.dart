import 'package:json_annotation/json_annotation.dart';
import 'package:seeker_app/core/models/service/service.dart';
import 'package:seeker_app/core/models/tasks/task.dart';

part 'task_lite.g.dart';

@JsonSerializable(explicitToJson: true)
class TaskLite {
  final String? id;
  @JsonKey(name: 'customer_id')
  final String? customerId;
  final String? title;
  @JsonKey(name: 'category_id')
  final String? categoryId;
  @JsonKey(name: 'service_id')
  final String? serviceId;
  final String? status;
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
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'scheduled_start_at')
  final DateTime? scheduledStartAt;
  @JsonKey(name: 'distance_km')
  final double? distanceKm;
  final ServiceCategory? category;
  final Assignment? assignment;

  TaskLite({
    this.id,
    this.customerId,
    this.title,
    this.categoryId,
    this.serviceId,
    this.status,
    this.basePrice,
    this.distanceFee,
    this.timeFee,
    this.urgencyFee,
    this.complexityFee,
    this.surgeMultiplier,
    this.customerTotalPrice,
    this.platformFee,
    this.providerPayout,
    this.createdAt,
    this.scheduledStartAt,
    this.distanceKm,
    this.category,
    this.assignment,
  });

  factory TaskLite.fromJson(Map<String, dynamic> json) =>
      _$TaskLiteFromJson(json);

  Map<String, dynamic> toJson() => _$TaskLiteToJson(this);
}
