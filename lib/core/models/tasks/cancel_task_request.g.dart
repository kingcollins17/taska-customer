// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cancel_task_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CancelTaskRequest _$CancelTaskRequestFromJson(Map<String, dynamic> json) =>
    CancelTaskRequest(
      cancellationReason: json['cancellation_reason'] as String?,
      cancellationPin: json['cancellation_pin'] as String?,
    );

Map<String, dynamic> _$CancelTaskRequestToJson(CancelTaskRequest instance) =>
    <String, dynamic>{
      'cancellation_reason': ?instance.cancellationReason,
      'cancellation_pin': ?instance.cancellationPin,
    };
