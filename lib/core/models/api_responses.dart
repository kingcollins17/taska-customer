import 'package:json_annotation/json_annotation.dart';

part 'api_responses.g.dart';

@JsonSerializable(genericArgumentFactories: true)
class GenericResponse<T> {
  final String? detail;
  final int? statusCode;
  final T? data;

  GenericResponse({this.detail, this.statusCode, this.data});

  factory GenericResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$GenericResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$GenericResponseToJson(this, toJsonT);

  bool get success =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;
}

@JsonSerializable(genericArgumentFactories: true)
class PaginatedResponse<T> {
  final List<T>? items;
  final int? total;
  final int? page;
  final int? perPage;

  PaginatedResponse({this.items, this.total, this.page, this.perPage});

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) => _$PaginatedResponseFromJson(json, fromJsonT);

  Map<String, dynamic> toJson(Object? Function(T value) toJsonT) =>
      _$PaginatedResponseToJson(this, toJsonT);
}
