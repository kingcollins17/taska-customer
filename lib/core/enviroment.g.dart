// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'enviroment.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Environment _$EnvironmentFromJson(Map<String, dynamic> json) => _Environment(
  baseUrl: json['baseUrl'] as String,
  baseDomain: json['baseDomain'] as String,
  appEnv:
      $enumDecodeNullable(_$AppEnvironmentEnumMap, json['appEnv']) ??
      AppEnvironment.local,
);

Map<String, dynamic> _$EnvironmentToJson(_Environment instance) =>
    <String, dynamic>{
      'baseUrl': instance.baseUrl,
      'baseDomain': instance.baseDomain,
      'appEnv': _$AppEnvironmentEnumMap[instance.appEnv]!,
    };

const _$AppEnvironmentEnumMap = {
  AppEnvironment.local: 'local',
  AppEnvironment.staging: 'staging',
  AppEnvironment.production: 'production',
};
