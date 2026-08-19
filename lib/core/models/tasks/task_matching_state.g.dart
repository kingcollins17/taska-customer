// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_matching_state.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TaskMatchingState _$TaskMatchingStateFromJson(Map<String, dynamic> json) =>
    _TaskMatchingState(
      status:
          $enumDecodeNullable(_$MatchingStatusEnumMap, json['status']) ??
          MatchingStatus.pending,
      taskId: json['taskId'] as String?,
      task: json['task'] == null
          ? null
          : Task.fromJson(json['task'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$TaskMatchingStateToJson(_TaskMatchingState instance) =>
    <String, dynamic>{
      'status': _$MatchingStatusEnumMap[instance.status]!,
      'taskId': instance.taskId,
      'task': instance.task,
    };

const _$MatchingStatusEnumMap = {
  MatchingStatus.pending: 'pending',
  MatchingStatus.success: 'success',
  MatchingStatus.cancelled: 'cancelled',
};
