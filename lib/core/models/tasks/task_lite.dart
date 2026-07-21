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
  @JsonKey(name: 'budget_min')
  final double? budgetMin;
  @JsonKey(name: 'budget_max')
  final double? budgetMax;
  @JsonKey(name: 'pricing_model')
  final String? pricingModel;
  final String? status;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;
  @JsonKey(name: 'scheduled_start_at')
  final DateTime? scheduledStartAt;
  @JsonKey(name: 'distance_km')
  final double? distanceKm;
  final ServiceCategory? category;
  @JsonKey(name: 'bids_count')
  final int? bidsCount;
  final Assignment? assignment;

  TaskLite({
    this.id,
    this.customerId,
    this.title,
    this.categoryId,
    this.serviceId,
    this.budgetMin,
    this.budgetMax,
    this.pricingModel,
    this.status,
    this.createdAt,
    this.scheduledStartAt,
    this.distanceKm,
    this.category,
    this.bidsCount,
    this.assignment,
  });

  factory TaskLite.fromJson(Map<String, dynamic> json) =>
      _$TaskLiteFromJson(json);

  Map<String, dynamic> toJson() => _$TaskLiteToJson(this);
}
