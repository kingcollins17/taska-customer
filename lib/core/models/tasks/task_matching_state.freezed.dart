// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task_matching_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TaskMatchingState {

 MatchingStatus get status; String? get taskId; Task? get task;
/// Create a copy of TaskMatchingState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TaskMatchingStateCopyWith<TaskMatchingState> get copyWith => _$TaskMatchingStateCopyWithImpl<TaskMatchingState>(this as TaskMatchingState, _$identity);

  /// Serializes this TaskMatchingState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TaskMatchingState&&(identical(other.status, status) || other.status == status)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.task, task) || other.task == task));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,taskId,task);

@override
String toString() {
  return 'TaskMatchingState(status: $status, taskId: $taskId, task: $task)';
}


}

/// @nodoc
abstract mixin class $TaskMatchingStateCopyWith<$Res>  {
  factory $TaskMatchingStateCopyWith(TaskMatchingState value, $Res Function(TaskMatchingState) _then) = _$TaskMatchingStateCopyWithImpl;
@useResult
$Res call({
 MatchingStatus status, String? taskId, Task? task
});




}
/// @nodoc
class _$TaskMatchingStateCopyWithImpl<$Res>
    implements $TaskMatchingStateCopyWith<$Res> {
  _$TaskMatchingStateCopyWithImpl(this._self, this._then);

  final TaskMatchingState _self;
  final $Res Function(TaskMatchingState) _then;

/// Create a copy of TaskMatchingState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? taskId = freezed,Object? task = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MatchingStatus,taskId: freezed == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String?,task: freezed == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as Task?,
  ));
}

}


/// Adds pattern-matching-related methods to [TaskMatchingState].
extension TaskMatchingStatePatterns on TaskMatchingState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TaskMatchingState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TaskMatchingState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TaskMatchingState value)  $default,){
final _that = this;
switch (_that) {
case _TaskMatchingState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TaskMatchingState value)?  $default,){
final _that = this;
switch (_that) {
case _TaskMatchingState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MatchingStatus status,  String? taskId,  Task? task)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TaskMatchingState() when $default != null:
return $default(_that.status,_that.taskId,_that.task);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MatchingStatus status,  String? taskId,  Task? task)  $default,) {final _that = this;
switch (_that) {
case _TaskMatchingState():
return $default(_that.status,_that.taskId,_that.task);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MatchingStatus status,  String? taskId,  Task? task)?  $default,) {final _that = this;
switch (_that) {
case _TaskMatchingState() when $default != null:
return $default(_that.status,_that.taskId,_that.task);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TaskMatchingState implements TaskMatchingState {
  const _TaskMatchingState({this.status = MatchingStatus.pending, this.taskId, this.task});
  factory _TaskMatchingState.fromJson(Map<String, dynamic> json) => _$TaskMatchingStateFromJson(json);

@override@JsonKey() final  MatchingStatus status;
@override final  String? taskId;
@override final  Task? task;

/// Create a copy of TaskMatchingState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TaskMatchingStateCopyWith<_TaskMatchingState> get copyWith => __$TaskMatchingStateCopyWithImpl<_TaskMatchingState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TaskMatchingStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TaskMatchingState&&(identical(other.status, status) || other.status == status)&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.task, task) || other.task == task));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,taskId,task);

@override
String toString() {
  return 'TaskMatchingState(status: $status, taskId: $taskId, task: $task)';
}


}

/// @nodoc
abstract mixin class _$TaskMatchingStateCopyWith<$Res> implements $TaskMatchingStateCopyWith<$Res> {
  factory _$TaskMatchingStateCopyWith(_TaskMatchingState value, $Res Function(_TaskMatchingState) _then) = __$TaskMatchingStateCopyWithImpl;
@override @useResult
$Res call({
 MatchingStatus status, String? taskId, Task? task
});




}
/// @nodoc
class __$TaskMatchingStateCopyWithImpl<$Res>
    implements _$TaskMatchingStateCopyWith<$Res> {
  __$TaskMatchingStateCopyWithImpl(this._self, this._then);

  final _TaskMatchingState _self;
  final $Res Function(_TaskMatchingState) _then;

/// Create a copy of TaskMatchingState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? taskId = freezed,Object? task = freezed,}) {
  return _then(_TaskMatchingState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MatchingStatus,taskId: freezed == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String?,task: freezed == task ? _self.task : task // ignore: cast_nullable_to_non_nullable
as Task?,
  ));
}


}

// dart format on
