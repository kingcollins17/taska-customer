import 'package:freezed_annotation/freezed_annotation.dart';
import 'task.dart';

part 'task_matching_state.freezed.dart';
part 'task_matching_state.g.dart';

enum MatchingStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('success')
  success,
  @JsonValue('cancelled')
  cancelled,
}

@freezed
abstract class TaskMatchingState with _$TaskMatchingState {
  const factory TaskMatchingState({
    @Default(MatchingStatus.pending) MatchingStatus status,
    String? taskId,
    Task? task,
  }) = _TaskMatchingState;

  factory TaskMatchingState.fromJson(Map<String, dynamic> json) =>
      _$TaskMatchingStateFromJson(json);
}
