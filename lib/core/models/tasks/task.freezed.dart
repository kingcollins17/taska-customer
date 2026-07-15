// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreateTaskLocationRequest {

@JsonKey(name: 'location_type') String? get locationType; double? get latitude; double? get longitude; String? get address; String? get city; String? get state; String? get country;
/// Create a copy of CreateTaskLocationRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateTaskLocationRequestCopyWith<CreateTaskLocationRequest> get copyWith => _$CreateTaskLocationRequestCopyWithImpl<CreateTaskLocationRequest>(this as CreateTaskLocationRequest, _$identity);

  /// Serializes this CreateTaskLocationRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateTaskLocationRequest&&(identical(other.locationType, locationType) || other.locationType == locationType)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.country, country) || other.country == country));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,locationType,latitude,longitude,address,city,state,country);

@override
String toString() {
  return 'CreateTaskLocationRequest(locationType: $locationType, latitude: $latitude, longitude: $longitude, address: $address, city: $city, state: $state, country: $country)';
}


}

/// @nodoc
abstract mixin class $CreateTaskLocationRequestCopyWith<$Res>  {
  factory $CreateTaskLocationRequestCopyWith(CreateTaskLocationRequest value, $Res Function(CreateTaskLocationRequest) _then) = _$CreateTaskLocationRequestCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'location_type') String? locationType, double? latitude, double? longitude, String? address, String? city, String? state, String? country
});




}
/// @nodoc
class _$CreateTaskLocationRequestCopyWithImpl<$Res>
    implements $CreateTaskLocationRequestCopyWith<$Res> {
  _$CreateTaskLocationRequestCopyWithImpl(this._self, this._then);

  final CreateTaskLocationRequest _self;
  final $Res Function(CreateTaskLocationRequest) _then;

/// Create a copy of CreateTaskLocationRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? locationType = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? address = freezed,Object? city = freezed,Object? state = freezed,Object? country = freezed,}) {
  return _then(_self.copyWith(
locationType: freezed == locationType ? _self.locationType : locationType // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateTaskLocationRequest].
extension CreateTaskLocationRequestPatterns on CreateTaskLocationRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateTaskLocationRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateTaskLocationRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateTaskLocationRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateTaskLocationRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateTaskLocationRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateTaskLocationRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'location_type')  String? locationType,  double? latitude,  double? longitude,  String? address,  String? city,  String? state,  String? country)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateTaskLocationRequest() when $default != null:
return $default(_that.locationType,_that.latitude,_that.longitude,_that.address,_that.city,_that.state,_that.country);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'location_type')  String? locationType,  double? latitude,  double? longitude,  String? address,  String? city,  String? state,  String? country)  $default,) {final _that = this;
switch (_that) {
case _CreateTaskLocationRequest():
return $default(_that.locationType,_that.latitude,_that.longitude,_that.address,_that.city,_that.state,_that.country);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'location_type')  String? locationType,  double? latitude,  double? longitude,  String? address,  String? city,  String? state,  String? country)?  $default,) {final _that = this;
switch (_that) {
case _CreateTaskLocationRequest() when $default != null:
return $default(_that.locationType,_that.latitude,_that.longitude,_that.address,_that.city,_that.state,_that.country);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _CreateTaskLocationRequest implements CreateTaskLocationRequest {
  const _CreateTaskLocationRequest({@JsonKey(name: 'location_type') this.locationType, this.latitude, this.longitude, this.address, this.city, this.state, this.country});
  factory _CreateTaskLocationRequest.fromJson(Map<String, dynamic> json) => _$CreateTaskLocationRequestFromJson(json);

@override@JsonKey(name: 'location_type') final  String? locationType;
@override final  double? latitude;
@override final  double? longitude;
@override final  String? address;
@override final  String? city;
@override final  String? state;
@override final  String? country;

/// Create a copy of CreateTaskLocationRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateTaskLocationRequestCopyWith<_CreateTaskLocationRequest> get copyWith => __$CreateTaskLocationRequestCopyWithImpl<_CreateTaskLocationRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateTaskLocationRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateTaskLocationRequest&&(identical(other.locationType, locationType) || other.locationType == locationType)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.address, address) || other.address == address)&&(identical(other.city, city) || other.city == city)&&(identical(other.state, state) || other.state == state)&&(identical(other.country, country) || other.country == country));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,locationType,latitude,longitude,address,city,state,country);

@override
String toString() {
  return 'CreateTaskLocationRequest(locationType: $locationType, latitude: $latitude, longitude: $longitude, address: $address, city: $city, state: $state, country: $country)';
}


}

/// @nodoc
abstract mixin class _$CreateTaskLocationRequestCopyWith<$Res> implements $CreateTaskLocationRequestCopyWith<$Res> {
  factory _$CreateTaskLocationRequestCopyWith(_CreateTaskLocationRequest value, $Res Function(_CreateTaskLocationRequest) _then) = __$CreateTaskLocationRequestCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'location_type') String? locationType, double? latitude, double? longitude, String? address, String? city, String? state, String? country
});




}
/// @nodoc
class __$CreateTaskLocationRequestCopyWithImpl<$Res>
    implements _$CreateTaskLocationRequestCopyWith<$Res> {
  __$CreateTaskLocationRequestCopyWithImpl(this._self, this._then);

  final _CreateTaskLocationRequest _self;
  final $Res Function(_CreateTaskLocationRequest) _then;

/// Create a copy of CreateTaskLocationRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? locationType = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? address = freezed,Object? city = freezed,Object? state = freezed,Object? country = freezed,}) {
  return _then(_CreateTaskLocationRequest(
locationType: freezed == locationType ? _self.locationType : locationType // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,state: freezed == state ? _self.state : state // ignore: cast_nullable_to_non_nullable
as String?,country: freezed == country ? _self.country : country // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreateTaskRequest {

 String? get title; String? get description;@JsonKey(name: 'category_id') String? get categoryId;@JsonKey(name: 'service_id') String? get serviceId;@JsonKey(name: 'budget_min') double? get budgetMin;@JsonKey(name: 'budget_max') double? get budgetMax;@JsonKey(name: 'pricing_model') String? get pricingModel;@JsonKey(name: 'expires_at') DateTime? get expiresAt;@JsonKey(name: 'scheduled_start_at') DateTime? get scheduledStartAt; List<CreateTaskLocationRequest>? get locations;
/// Create a copy of CreateTaskRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateTaskRequestCopyWith<CreateTaskRequest> get copyWith => _$CreateTaskRequestCopyWithImpl<CreateTaskRequest>(this as CreateTaskRequest, _$identity);

  /// Serializes this CreateTaskRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateTaskRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.budgetMin, budgetMin) || other.budgetMin == budgetMin)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax)&&(identical(other.pricingModel, pricingModel) || other.pricingModel == pricingModel)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.scheduledStartAt, scheduledStartAt) || other.scheduledStartAt == scheduledStartAt)&&const DeepCollectionEquality().equals(other.locations, locations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,categoryId,serviceId,budgetMin,budgetMax,pricingModel,expiresAt,scheduledStartAt,const DeepCollectionEquality().hash(locations));

@override
String toString() {
  return 'CreateTaskRequest(title: $title, description: $description, categoryId: $categoryId, serviceId: $serviceId, budgetMin: $budgetMin, budgetMax: $budgetMax, pricingModel: $pricingModel, expiresAt: $expiresAt, scheduledStartAt: $scheduledStartAt, locations: $locations)';
}


}

/// @nodoc
abstract mixin class $CreateTaskRequestCopyWith<$Res>  {
  factory $CreateTaskRequestCopyWith(CreateTaskRequest value, $Res Function(CreateTaskRequest) _then) = _$CreateTaskRequestCopyWithImpl;
@useResult
$Res call({
 String? title, String? description,@JsonKey(name: 'category_id') String? categoryId,@JsonKey(name: 'service_id') String? serviceId,@JsonKey(name: 'budget_min') double? budgetMin,@JsonKey(name: 'budget_max') double? budgetMax,@JsonKey(name: 'pricing_model') String? pricingModel,@JsonKey(name: 'expires_at') DateTime? expiresAt,@JsonKey(name: 'scheduled_start_at') DateTime? scheduledStartAt, List<CreateTaskLocationRequest>? locations
});




}
/// @nodoc
class _$CreateTaskRequestCopyWithImpl<$Res>
    implements $CreateTaskRequestCopyWith<$Res> {
  _$CreateTaskRequestCopyWithImpl(this._self, this._then);

  final CreateTaskRequest _self;
  final $Res Function(CreateTaskRequest) _then;

/// Create a copy of CreateTaskRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? description = freezed,Object? categoryId = freezed,Object? serviceId = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? pricingModel = freezed,Object? expiresAt = freezed,Object? scheduledStartAt = freezed,Object? locations = freezed,}) {
  return _then(_self.copyWith(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,serviceId: freezed == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as double?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as double?,pricingModel: freezed == pricingModel ? _self.pricingModel : pricingModel // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledStartAt: freezed == scheduledStartAt ? _self.scheduledStartAt : scheduledStartAt // ignore: cast_nullable_to_non_nullable
as DateTime?,locations: freezed == locations ? _self.locations : locations // ignore: cast_nullable_to_non_nullable
as List<CreateTaskLocationRequest>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateTaskRequest].
extension CreateTaskRequestPatterns on CreateTaskRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateTaskRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateTaskRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateTaskRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateTaskRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateTaskRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateTaskRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title,  String? description, @JsonKey(name: 'category_id')  String? categoryId, @JsonKey(name: 'service_id')  String? serviceId, @JsonKey(name: 'budget_min')  double? budgetMin, @JsonKey(name: 'budget_max')  double? budgetMax, @JsonKey(name: 'pricing_model')  String? pricingModel, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'scheduled_start_at')  DateTime? scheduledStartAt,  List<CreateTaskLocationRequest>? locations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateTaskRequest() when $default != null:
return $default(_that.title,_that.description,_that.categoryId,_that.serviceId,_that.budgetMin,_that.budgetMax,_that.pricingModel,_that.expiresAt,_that.scheduledStartAt,_that.locations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title,  String? description, @JsonKey(name: 'category_id')  String? categoryId, @JsonKey(name: 'service_id')  String? serviceId, @JsonKey(name: 'budget_min')  double? budgetMin, @JsonKey(name: 'budget_max')  double? budgetMax, @JsonKey(name: 'pricing_model')  String? pricingModel, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'scheduled_start_at')  DateTime? scheduledStartAt,  List<CreateTaskLocationRequest>? locations)  $default,) {final _that = this;
switch (_that) {
case _CreateTaskRequest():
return $default(_that.title,_that.description,_that.categoryId,_that.serviceId,_that.budgetMin,_that.budgetMax,_that.pricingModel,_that.expiresAt,_that.scheduledStartAt,_that.locations);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title,  String? description, @JsonKey(name: 'category_id')  String? categoryId, @JsonKey(name: 'service_id')  String? serviceId, @JsonKey(name: 'budget_min')  double? budgetMin, @JsonKey(name: 'budget_max')  double? budgetMax, @JsonKey(name: 'pricing_model')  String? pricingModel, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'scheduled_start_at')  DateTime? scheduledStartAt,  List<CreateTaskLocationRequest>? locations)?  $default,) {final _that = this;
switch (_that) {
case _CreateTaskRequest() when $default != null:
return $default(_that.title,_that.description,_that.categoryId,_that.serviceId,_that.budgetMin,_that.budgetMax,_that.pricingModel,_that.expiresAt,_that.scheduledStartAt,_that.locations);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _CreateTaskRequest implements CreateTaskRequest {
  const _CreateTaskRequest({this.title, this.description, @JsonKey(name: 'category_id') this.categoryId, @JsonKey(name: 'service_id') this.serviceId, @JsonKey(name: 'budget_min') this.budgetMin, @JsonKey(name: 'budget_max') this.budgetMax, @JsonKey(name: 'pricing_model') this.pricingModel, @JsonKey(name: 'expires_at') this.expiresAt, @JsonKey(name: 'scheduled_start_at') this.scheduledStartAt, final  List<CreateTaskLocationRequest>? locations}): _locations = locations;
  factory _CreateTaskRequest.fromJson(Map<String, dynamic> json) => _$CreateTaskRequestFromJson(json);

@override final  String? title;
@override final  String? description;
@override@JsonKey(name: 'category_id') final  String? categoryId;
@override@JsonKey(name: 'service_id') final  String? serviceId;
@override@JsonKey(name: 'budget_min') final  double? budgetMin;
@override@JsonKey(name: 'budget_max') final  double? budgetMax;
@override@JsonKey(name: 'pricing_model') final  String? pricingModel;
@override@JsonKey(name: 'expires_at') final  DateTime? expiresAt;
@override@JsonKey(name: 'scheduled_start_at') final  DateTime? scheduledStartAt;
 final  List<CreateTaskLocationRequest>? _locations;
@override List<CreateTaskLocationRequest>? get locations {
  final value = _locations;
  if (value == null) return null;
  if (_locations is EqualUnmodifiableListView) return _locations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of CreateTaskRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateTaskRequestCopyWith<_CreateTaskRequest> get copyWith => __$CreateTaskRequestCopyWithImpl<_CreateTaskRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateTaskRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateTaskRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.budgetMin, budgetMin) || other.budgetMin == budgetMin)&&(identical(other.budgetMax, budgetMax) || other.budgetMax == budgetMax)&&(identical(other.pricingModel, pricingModel) || other.pricingModel == pricingModel)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.scheduledStartAt, scheduledStartAt) || other.scheduledStartAt == scheduledStartAt)&&const DeepCollectionEquality().equals(other._locations, _locations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,categoryId,serviceId,budgetMin,budgetMax,pricingModel,expiresAt,scheduledStartAt,const DeepCollectionEquality().hash(_locations));

@override
String toString() {
  return 'CreateTaskRequest(title: $title, description: $description, categoryId: $categoryId, serviceId: $serviceId, budgetMin: $budgetMin, budgetMax: $budgetMax, pricingModel: $pricingModel, expiresAt: $expiresAt, scheduledStartAt: $scheduledStartAt, locations: $locations)';
}


}

/// @nodoc
abstract mixin class _$CreateTaskRequestCopyWith<$Res> implements $CreateTaskRequestCopyWith<$Res> {
  factory _$CreateTaskRequestCopyWith(_CreateTaskRequest value, $Res Function(_CreateTaskRequest) _then) = __$CreateTaskRequestCopyWithImpl;
@override @useResult
$Res call({
 String? title, String? description,@JsonKey(name: 'category_id') String? categoryId,@JsonKey(name: 'service_id') String? serviceId,@JsonKey(name: 'budget_min') double? budgetMin,@JsonKey(name: 'budget_max') double? budgetMax,@JsonKey(name: 'pricing_model') String? pricingModel,@JsonKey(name: 'expires_at') DateTime? expiresAt,@JsonKey(name: 'scheduled_start_at') DateTime? scheduledStartAt, List<CreateTaskLocationRequest>? locations
});




}
/// @nodoc
class __$CreateTaskRequestCopyWithImpl<$Res>
    implements _$CreateTaskRequestCopyWith<$Res> {
  __$CreateTaskRequestCopyWithImpl(this._self, this._then);

  final _CreateTaskRequest _self;
  final $Res Function(_CreateTaskRequest) _then;

/// Create a copy of CreateTaskRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? description = freezed,Object? categoryId = freezed,Object? serviceId = freezed,Object? budgetMin = freezed,Object? budgetMax = freezed,Object? pricingModel = freezed,Object? expiresAt = freezed,Object? scheduledStartAt = freezed,Object? locations = freezed,}) {
  return _then(_CreateTaskRequest(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,serviceId: freezed == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String?,budgetMin: freezed == budgetMin ? _self.budgetMin : budgetMin // ignore: cast_nullable_to_non_nullable
as double?,budgetMax: freezed == budgetMax ? _self.budgetMax : budgetMax // ignore: cast_nullable_to_non_nullable
as double?,pricingModel: freezed == pricingModel ? _self.pricingModel : pricingModel // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledStartAt: freezed == scheduledStartAt ? _self.scheduledStartAt : scheduledStartAt // ignore: cast_nullable_to_non_nullable
as DateTime?,locations: freezed == locations ? _self._locations : locations // ignore: cast_nullable_to_non_nullable
as List<CreateTaskLocationRequest>?,
  ));
}


}

// dart format on
