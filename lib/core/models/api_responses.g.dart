// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_responses.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GenericResponse<T> _$GenericResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => GenericResponse<T>(
  detail: json['detail'] as String?,
  statusCode: (json['statusCode'] as num?)?.toInt(),
  data: _$nullableGenericFromJson(json['data'], fromJsonT),
);

Map<String, dynamic> _$GenericResponseToJson<T>(
  GenericResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'detail': instance.detail,
  'statusCode': instance.statusCode,
  'data': _$nullableGenericToJson(instance.data, toJsonT),
};

T? _$nullableGenericFromJson<T>(
  Object? input,
  T Function(Object? json) fromJson,
) => input == null ? null : fromJson(input);

Object? _$nullableGenericToJson<T>(
  T? input,
  Object? Function(T value) toJson,
) => input == null ? null : toJson(input);

PaginatedResponse<T> _$PaginatedResponseFromJson<T>(
  Map<String, dynamic> json,
  T Function(Object? json) fromJsonT,
) => PaginatedResponse<T>(
  items: (json['items'] as List<dynamic>?)?.map(fromJsonT).toList(),
  total: (json['total'] as num?)?.toInt(),
  page: (json['page'] as num?)?.toInt(),
  perPage: (json['perPage'] as num?)?.toInt(),
);

Map<String, dynamic> _$PaginatedResponseToJson<T>(
  PaginatedResponse<T> instance,
  Object? Function(T value) toJsonT,
) => <String, dynamic>{
  'items': instance.items?.map(toJsonT).toList(),
  'total': instance.total,
  'page': instance.page,
  'perPage': instance.perPage,
};
