import 'package:json_annotation/json_annotation.dart';

part 'cancel_task_request.g.dart';

@JsonSerializable(includeIfNull: false)
class CancelTaskRequest {
  @JsonKey(name: 'cancellation_reason')
  final String? cancellationReason;
  @JsonKey(name: 'cancellation_pin')
  final String? cancellationPin;

  CancelTaskRequest({
    this.cancellationReason,
    this.cancellationPin,
  });

  factory CancelTaskRequest.fromJson(Map<String, dynamic> json) =>
      _$CancelTaskRequestFromJson(json);

  Map<String, dynamic> toJson() => _$CancelTaskRequestToJson(this);
}
