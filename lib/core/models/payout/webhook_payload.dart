import 'package:json_annotation/json_annotation.dart';

part 'webhook_payload.g.dart';
//  final eg={
//       "event": "charge.success",
//       "data": {
//         "reference": "chrg_succ_12345",
//         "amount": 3025,
//         "status": "success",
//         "metadata": {
//           "type": "task_payment",
//           "user_id": "7bced38a-e96b-44b9-a812-b35881948a81",
//           "task_id": "4060dcb4-ce45-4014-97d3-5061da1bc62f"
          
//         }
//       }
//     };
@JsonSerializable(explicitToJson: true)
class WebhookPayload {
  WebhookPayload({this.event, this.data});

  final String? event;

  final WebhookPayloadData? data;

  static WebhookPayload transfer(int amount, {String? userId, String? taskId}) {
    return WebhookPayload(
      event: 'transfer.success',
      data: WebhookPayloadData(
        reference: 'tx_transfer_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        status: 'success',
        metadata: WebhookPayloadMeta(userId: userId, taskId: taskId),
      ),
    );
  }

  static WebhookPayload payment(int amount, {String? userId, String? taskId}) {
    return WebhookPayload(
      event: 'charge.success',
      data: WebhookPayloadData(
        reference: 'tx_payment_${DateTime.now().millisecondsSinceEpoch}',
        amount: amount,
        status: 'success',
        metadata: WebhookPayloadMeta(userId: userId, taskId: taskId),
      ),
    );
  }

  WebhookPayload copyWith({String? event, WebhookPayloadData? data}) {
    return WebhookPayload(event: event ?? this.event, data: data ?? this.data);
  }

  factory WebhookPayload.fromJson(Map<String, dynamic> json) =>
      _$WebhookPayloadFromJson(json);

  Map<String, dynamic> toJson() => _$WebhookPayloadToJson(this);
}

@JsonSerializable(explicitToJson: true)
class WebhookPayloadData {

  WebhookPayloadData({this.reference, this.amount, this.status, this.metadata});

  final String? reference;

  final int? amount;

  final String? status;

  final WebhookPayloadMeta? metadata;

  WebhookPayloadData copyWith({
    String? reference,
    int? amount,
    String? status,
    WebhookPayloadMeta? metadata,
  }) {
    return WebhookPayloadData(
      reference: reference ?? this.reference,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      metadata: metadata ?? this.metadata,
    );
  }

  factory WebhookPayloadData.fromJson(Map<String, dynamic> json) =>
      _$WebhookPayloadDataFromJson(json);

  Map<String, dynamic> toJson() => _$WebhookPayloadDataToJson(this);
}

@JsonSerializable()
class WebhookPayloadMeta {
  WebhookPayloadMeta({this.userId, this.taskId, this.type='task_payment'});

  @JsonKey(name: 'user_id')
  final String? userId;

  @JsonKey(name: 'task_id')
  final String? taskId;

  final String? type;

  WebhookPayloadMeta copyWith({String? userId, String? taskId}) {
    return WebhookPayloadMeta(
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
    );
  }

  factory WebhookPayloadMeta.fromJson(Map<String, dynamic> json) =>
      _$WebhookPayloadMetaFromJson(json);

  Map<String, dynamic> toJson() => _$WebhookPayloadMetaToJson(this);
}
