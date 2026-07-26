import 'package:json_annotation/json_annotation.dart';

part 'webhook_payload.g.dart';

@JsonSerializable()
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

@JsonSerializable()
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
  WebhookPayloadMeta({this.userId, this.taskId, this.bidId});

  @JsonKey(name: 'user_id')
  final String? userId;

  @JsonKey(name: 'task_id')
  final String? taskId;

  @JsonKey(name: 'bid_id')
  final String? bidId;

  WebhookPayloadMeta copyWith({String? userId, String? taskId, String? bidId}) {
    return WebhookPayloadMeta(
      userId: userId ?? this.userId,
      taskId: taskId ?? this.taskId,
      bidId: bidId ?? this.bidId,
    );
  }

  factory WebhookPayloadMeta.fromJson(Map<String, dynamic> json) =>
      _$WebhookPayloadMetaFromJson(json);

  Map<String, dynamic> toJson() => _$WebhookPayloadMetaToJson(this);
}
