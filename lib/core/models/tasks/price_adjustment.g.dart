// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_adjustment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceAdjustment _$PriceAdjustmentFromJson(Map<String, dynamic> json) =>
    PriceAdjustment(
      id: json['id'] as String?,
      taskId: json['task_id'] as String?,
      description: json['description'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      requestedBy: json['requested_by'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$PriceAdjustmentToJson(PriceAdjustment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'task_id': instance.taskId,
      'description': instance.description,
      'amount': instance.amount,
      'requested_by': instance.requestedBy,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
    };

RespondPriceAdjustmentRequest _$RespondPriceAdjustmentRequestFromJson(
  Map<String, dynamic> json,
) => RespondPriceAdjustmentRequest(approved: json['approved'] as bool);

Map<String, dynamic> _$RespondPriceAdjustmentRequestToJson(
  RespondPriceAdjustmentRequest instance,
) => <String, dynamic>{'approved': instance.approved};
