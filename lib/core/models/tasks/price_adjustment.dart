import 'package:json_annotation/json_annotation.dart';

part 'price_adjustment.g.dart';

@JsonSerializable(explicitToJson: true)
class PriceAdjustment {
  final String? id;
  @JsonKey(name: 'task_id')
  final String? taskId;
  final String? description;
  final double? amount;
  @JsonKey(name: 'requested_by')
  final String? requestedBy;
  final String? status;
  @JsonKey(name: 'created_at')
  final DateTime? createdAt;

  PriceAdjustment({
    this.id,
    this.taskId,
    this.description,
    this.amount,
    this.requestedBy,
    this.status,
    this.createdAt,
  });

  factory PriceAdjustment.fromJson(Map<String, dynamic> json) =>
      _$PriceAdjustmentFromJson(json);

  Map<String, dynamic> toJson() => _$PriceAdjustmentToJson(this);
}

@JsonSerializable()
class RespondPriceAdjustmentRequest {
  final bool approved;

  RespondPriceAdjustmentRequest({
    required this.approved,
  });

  factory RespondPriceAdjustmentRequest.fromJson(Map<String, dynamic> json) =>
      _$RespondPriceAdjustmentRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RespondPriceAdjustmentRequestToJson(this);
}
