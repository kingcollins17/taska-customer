// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webhook_payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebhookPayload _$WebhookPayloadFromJson(Map<String, dynamic> json) =>
    WebhookPayload(
      event: json['event'] as String?,
      data: json['data'] == null
          ? null
          : WebhookPayloadData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$WebhookPayloadToJson(WebhookPayload instance) =>
    <String, dynamic>{'event': instance.event, 'data': instance.data?.toJson()};

WebhookPayloadData _$WebhookPayloadDataFromJson(Map<String, dynamic> json) =>
    WebhookPayloadData(
      reference: json['reference'] as String?,
      amount: (json['amount'] as num?)?.toDouble(),
      status: json['status'] as String?,
      metadata: json['metadata'] == null
          ? null
          : WebhookPayloadMeta.fromJson(
              json['metadata'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$WebhookPayloadDataToJson(WebhookPayloadData instance) =>
    <String, dynamic>{
      'reference': instance.reference,
      'amount': instance.amount,
      'status': instance.status,
      'metadata': instance.metadata?.toJson(),
    };

WebhookPayloadMeta _$WebhookPayloadMetaFromJson(Map<String, dynamic> json) =>
    WebhookPayloadMeta(
      userId: json['user_id'] as String?,
      taskId: json['task_id'] as String?,
      type: json['type'] as String? ?? 'task_payment',
    );

Map<String, dynamic> _$WebhookPayloadMetaToJson(WebhookPayloadMeta instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'task_id': instance.taskId,
      'type': instance.type,
    };
