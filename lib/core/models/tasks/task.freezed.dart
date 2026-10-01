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
@JsonSerializable()

class _CreateTaskLocationRequest implements CreateTaskLocationRequest {
  const _CreateTaskLocationRequest({@JsonKey(name: 'location_type') this.locationType = 'SERVICE', this.latitude, this.longitude, this.address, this.city, this.state, this.country});
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
mixin _$CreateTaskAttachmentRequest {

 String? get url;@JsonKey(name: 'storage_key') String? get storageKey;@JsonKey(name: 'file_name') String? get fileName;@JsonKey(name: 'file_size') int? get fileSize;@JsonKey(name: 'mime_type') String? get mimeType; String? get type;
/// Create a copy of CreateTaskAttachmentRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateTaskAttachmentRequestCopyWith<CreateTaskAttachmentRequest> get copyWith => _$CreateTaskAttachmentRequestCopyWithImpl<CreateTaskAttachmentRequest>(this as CreateTaskAttachmentRequest, _$identity);

  /// Serializes this CreateTaskAttachmentRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateTaskAttachmentRequest&&(identical(other.url, url) || other.url == url)&&(identical(other.storageKey, storageKey) || other.storageKey == storageKey)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,storageKey,fileName,fileSize,mimeType,type);

@override
String toString() {
  return 'CreateTaskAttachmentRequest(url: $url, storageKey: $storageKey, fileName: $fileName, fileSize: $fileSize, mimeType: $mimeType, type: $type)';
}


}

/// @nodoc
abstract mixin class $CreateTaskAttachmentRequestCopyWith<$Res>  {
  factory $CreateTaskAttachmentRequestCopyWith(CreateTaskAttachmentRequest value, $Res Function(CreateTaskAttachmentRequest) _then) = _$CreateTaskAttachmentRequestCopyWithImpl;
@useResult
$Res call({
 String? url,@JsonKey(name: 'storage_key') String? storageKey,@JsonKey(name: 'file_name') String? fileName,@JsonKey(name: 'file_size') int? fileSize,@JsonKey(name: 'mime_type') String? mimeType, String? type
});




}
/// @nodoc
class _$CreateTaskAttachmentRequestCopyWithImpl<$Res>
    implements $CreateTaskAttachmentRequestCopyWith<$Res> {
  _$CreateTaskAttachmentRequestCopyWithImpl(this._self, this._then);

  final CreateTaskAttachmentRequest _self;
  final $Res Function(CreateTaskAttachmentRequest) _then;

/// Create a copy of CreateTaskAttachmentRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = freezed,Object? storageKey = freezed,Object? fileName = freezed,Object? fileSize = freezed,Object? mimeType = freezed,Object? type = freezed,}) {
  return _then(_self.copyWith(
url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,storageKey: freezed == storageKey ? _self.storageKey : storageKey // ignore: cast_nullable_to_non_nullable
as String?,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateTaskAttachmentRequest].
extension CreateTaskAttachmentRequestPatterns on CreateTaskAttachmentRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateTaskAttachmentRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateTaskAttachmentRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateTaskAttachmentRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateTaskAttachmentRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateTaskAttachmentRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateTaskAttachmentRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? url, @JsonKey(name: 'storage_key')  String? storageKey, @JsonKey(name: 'file_name')  String? fileName, @JsonKey(name: 'file_size')  int? fileSize, @JsonKey(name: 'mime_type')  String? mimeType,  String? type)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateTaskAttachmentRequest() when $default != null:
return $default(_that.url,_that.storageKey,_that.fileName,_that.fileSize,_that.mimeType,_that.type);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? url, @JsonKey(name: 'storage_key')  String? storageKey, @JsonKey(name: 'file_name')  String? fileName, @JsonKey(name: 'file_size')  int? fileSize, @JsonKey(name: 'mime_type')  String? mimeType,  String? type)  $default,) {final _that = this;
switch (_that) {
case _CreateTaskAttachmentRequest():
return $default(_that.url,_that.storageKey,_that.fileName,_that.fileSize,_that.mimeType,_that.type);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? url, @JsonKey(name: 'storage_key')  String? storageKey, @JsonKey(name: 'file_name')  String? fileName, @JsonKey(name: 'file_size')  int? fileSize, @JsonKey(name: 'mime_type')  String? mimeType,  String? type)?  $default,) {final _that = this;
switch (_that) {
case _CreateTaskAttachmentRequest() when $default != null:
return $default(_that.url,_that.storageKey,_that.fileName,_that.fileSize,_that.mimeType,_that.type);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _CreateTaskAttachmentRequest implements CreateTaskAttachmentRequest {
  const _CreateTaskAttachmentRequest({this.url, @JsonKey(name: 'storage_key') this.storageKey, @JsonKey(name: 'file_name') this.fileName, @JsonKey(name: 'file_size') this.fileSize, @JsonKey(name: 'mime_type') this.mimeType, this.type});
  factory _CreateTaskAttachmentRequest.fromJson(Map<String, dynamic> json) => _$CreateTaskAttachmentRequestFromJson(json);

@override final  String? url;
@override@JsonKey(name: 'storage_key') final  String? storageKey;
@override@JsonKey(name: 'file_name') final  String? fileName;
@override@JsonKey(name: 'file_size') final  int? fileSize;
@override@JsonKey(name: 'mime_type') final  String? mimeType;
@override final  String? type;

/// Create a copy of CreateTaskAttachmentRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateTaskAttachmentRequestCopyWith<_CreateTaskAttachmentRequest> get copyWith => __$CreateTaskAttachmentRequestCopyWithImpl<_CreateTaskAttachmentRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateTaskAttachmentRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateTaskAttachmentRequest&&(identical(other.url, url) || other.url == url)&&(identical(other.storageKey, storageKey) || other.storageKey == storageKey)&&(identical(other.fileName, fileName) || other.fileName == fileName)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.type, type) || other.type == type));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,storageKey,fileName,fileSize,mimeType,type);

@override
String toString() {
  return 'CreateTaskAttachmentRequest(url: $url, storageKey: $storageKey, fileName: $fileName, fileSize: $fileSize, mimeType: $mimeType, type: $type)';
}


}

/// @nodoc
abstract mixin class _$CreateTaskAttachmentRequestCopyWith<$Res> implements $CreateTaskAttachmentRequestCopyWith<$Res> {
  factory _$CreateTaskAttachmentRequestCopyWith(_CreateTaskAttachmentRequest value, $Res Function(_CreateTaskAttachmentRequest) _then) = __$CreateTaskAttachmentRequestCopyWithImpl;
@override @useResult
$Res call({
 String? url,@JsonKey(name: 'storage_key') String? storageKey,@JsonKey(name: 'file_name') String? fileName,@JsonKey(name: 'file_size') int? fileSize,@JsonKey(name: 'mime_type') String? mimeType, String? type
});




}
/// @nodoc
class __$CreateTaskAttachmentRequestCopyWithImpl<$Res>
    implements _$CreateTaskAttachmentRequestCopyWith<$Res> {
  __$CreateTaskAttachmentRequestCopyWithImpl(this._self, this._then);

  final _CreateTaskAttachmentRequest _self;
  final $Res Function(_CreateTaskAttachmentRequest) _then;

/// Create a copy of CreateTaskAttachmentRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = freezed,Object? storageKey = freezed,Object? fileName = freezed,Object? fileSize = freezed,Object? mimeType = freezed,Object? type = freezed,}) {
  return _then(_CreateTaskAttachmentRequest(
url: freezed == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String?,storageKey: freezed == storageKey ? _self.storageKey : storageKey // ignore: cast_nullable_to_non_nullable
as String?,fileName: freezed == fileName ? _self.fileName : fileName // ignore: cast_nullable_to_non_nullable
as String?,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreateTaskRequest {

 String? get title; String? get description;@JsonKey(name: 'category_id') String? get categoryId;@JsonKey(name: 'service_id') String? get serviceId;@JsonKey(name: 'expires_at') DateTime? get expiresAt;@JsonKey(name: 'scheduled_start_at') DateTime? get scheduledStartAt; List<CreateTaskLocationRequest>? get locations; List<CreateTaskAttachmentRequest>? get attachments;
/// Create a copy of CreateTaskRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateTaskRequestCopyWith<CreateTaskRequest> get copyWith => _$CreateTaskRequestCopyWithImpl<CreateTaskRequest>(this as CreateTaskRequest, _$identity);

  /// Serializes this CreateTaskRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateTaskRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.scheduledStartAt, scheduledStartAt) || other.scheduledStartAt == scheduledStartAt)&&const DeepCollectionEquality().equals(other.locations, locations)&&const DeepCollectionEquality().equals(other.attachments, attachments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,categoryId,serviceId,expiresAt,scheduledStartAt,const DeepCollectionEquality().hash(locations),const DeepCollectionEquality().hash(attachments));

@override
String toString() {
  return 'CreateTaskRequest(title: $title, description: $description, categoryId: $categoryId, serviceId: $serviceId, expiresAt: $expiresAt, scheduledStartAt: $scheduledStartAt, locations: $locations, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class $CreateTaskRequestCopyWith<$Res>  {
  factory $CreateTaskRequestCopyWith(CreateTaskRequest value, $Res Function(CreateTaskRequest) _then) = _$CreateTaskRequestCopyWithImpl;
@useResult
$Res call({
 String? title, String? description,@JsonKey(name: 'category_id') String? categoryId,@JsonKey(name: 'service_id') String? serviceId,@JsonKey(name: 'expires_at') DateTime? expiresAt,@JsonKey(name: 'scheduled_start_at') DateTime? scheduledStartAt, List<CreateTaskLocationRequest>? locations, List<CreateTaskAttachmentRequest>? attachments
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
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? description = freezed,Object? categoryId = freezed,Object? serviceId = freezed,Object? expiresAt = freezed,Object? scheduledStartAt = freezed,Object? locations = freezed,Object? attachments = freezed,}) {
  return _then(_self.copyWith(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,serviceId: freezed == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledStartAt: freezed == scheduledStartAt ? _self.scheduledStartAt : scheduledStartAt // ignore: cast_nullable_to_non_nullable
as DateTime?,locations: freezed == locations ? _self.locations : locations // ignore: cast_nullable_to_non_nullable
as List<CreateTaskLocationRequest>?,attachments: freezed == attachments ? _self.attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<CreateTaskAttachmentRequest>?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title,  String? description, @JsonKey(name: 'category_id')  String? categoryId, @JsonKey(name: 'service_id')  String? serviceId, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'scheduled_start_at')  DateTime? scheduledStartAt,  List<CreateTaskLocationRequest>? locations,  List<CreateTaskAttachmentRequest>? attachments)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateTaskRequest() when $default != null:
return $default(_that.title,_that.description,_that.categoryId,_that.serviceId,_that.expiresAt,_that.scheduledStartAt,_that.locations,_that.attachments);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title,  String? description, @JsonKey(name: 'category_id')  String? categoryId, @JsonKey(name: 'service_id')  String? serviceId, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'scheduled_start_at')  DateTime? scheduledStartAt,  List<CreateTaskLocationRequest>? locations,  List<CreateTaskAttachmentRequest>? attachments)  $default,) {final _that = this;
switch (_that) {
case _CreateTaskRequest():
return $default(_that.title,_that.description,_that.categoryId,_that.serviceId,_that.expiresAt,_that.scheduledStartAt,_that.locations,_that.attachments);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title,  String? description, @JsonKey(name: 'category_id')  String? categoryId, @JsonKey(name: 'service_id')  String? serviceId, @JsonKey(name: 'expires_at')  DateTime? expiresAt, @JsonKey(name: 'scheduled_start_at')  DateTime? scheduledStartAt,  List<CreateTaskLocationRequest>? locations,  List<CreateTaskAttachmentRequest>? attachments)?  $default,) {final _that = this;
switch (_that) {
case _CreateTaskRequest() when $default != null:
return $default(_that.title,_that.description,_that.categoryId,_that.serviceId,_that.expiresAt,_that.scheduledStartAt,_that.locations,_that.attachments);case _:
  return null;

}
}

}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _CreateTaskRequest implements CreateTaskRequest {
  const _CreateTaskRequest({this.title, this.description, @JsonKey(name: 'category_id') this.categoryId, @JsonKey(name: 'service_id') this.serviceId, @JsonKey(name: 'expires_at') this.expiresAt, @JsonKey(name: 'scheduled_start_at') this.scheduledStartAt, final  List<CreateTaskLocationRequest>? locations, final  List<CreateTaskAttachmentRequest>? attachments}): _locations = locations,_attachments = attachments;
  factory _CreateTaskRequest.fromJson(Map<String, dynamic> json) => _$CreateTaskRequestFromJson(json);

@override final  String? title;
@override final  String? description;
@override@JsonKey(name: 'category_id') final  String? categoryId;
@override@JsonKey(name: 'service_id') final  String? serviceId;
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

 final  List<CreateTaskAttachmentRequest>? _attachments;
@override List<CreateTaskAttachmentRequest>? get attachments {
  final value = _attachments;
  if (value == null) return null;
  if (_attachments is EqualUnmodifiableListView) return _attachments;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateTaskRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.categoryId, categoryId) || other.categoryId == categoryId)&&(identical(other.serviceId, serviceId) || other.serviceId == serviceId)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.scheduledStartAt, scheduledStartAt) || other.scheduledStartAt == scheduledStartAt)&&const DeepCollectionEquality().equals(other._locations, _locations)&&const DeepCollectionEquality().equals(other._attachments, _attachments));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,categoryId,serviceId,expiresAt,scheduledStartAt,const DeepCollectionEquality().hash(_locations),const DeepCollectionEquality().hash(_attachments));

@override
String toString() {
  return 'CreateTaskRequest(title: $title, description: $description, categoryId: $categoryId, serviceId: $serviceId, expiresAt: $expiresAt, scheduledStartAt: $scheduledStartAt, locations: $locations, attachments: $attachments)';
}


}

/// @nodoc
abstract mixin class _$CreateTaskRequestCopyWith<$Res> implements $CreateTaskRequestCopyWith<$Res> {
  factory _$CreateTaskRequestCopyWith(_CreateTaskRequest value, $Res Function(_CreateTaskRequest) _then) = __$CreateTaskRequestCopyWithImpl;
@override @useResult
$Res call({
 String? title, String? description,@JsonKey(name: 'category_id') String? categoryId,@JsonKey(name: 'service_id') String? serviceId,@JsonKey(name: 'expires_at') DateTime? expiresAt,@JsonKey(name: 'scheduled_start_at') DateTime? scheduledStartAt, List<CreateTaskLocationRequest>? locations, List<CreateTaskAttachmentRequest>? attachments
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
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? description = freezed,Object? categoryId = freezed,Object? serviceId = freezed,Object? expiresAt = freezed,Object? scheduledStartAt = freezed,Object? locations = freezed,Object? attachments = freezed,}) {
  return _then(_CreateTaskRequest(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,categoryId: freezed == categoryId ? _self.categoryId : categoryId // ignore: cast_nullable_to_non_nullable
as String?,serviceId: freezed == serviceId ? _self.serviceId : serviceId // ignore: cast_nullable_to_non_nullable
as String?,expiresAt: freezed == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledStartAt: freezed == scheduledStartAt ? _self.scheduledStartAt : scheduledStartAt // ignore: cast_nullable_to_non_nullable
as DateTime?,locations: freezed == locations ? _self._locations : locations // ignore: cast_nullable_to_non_nullable
as List<CreateTaskLocationRequest>?,attachments: freezed == attachments ? _self._attachments : attachments // ignore: cast_nullable_to_non_nullable
as List<CreateTaskAttachmentRequest>?,
  ));
}


}

// dart format on
