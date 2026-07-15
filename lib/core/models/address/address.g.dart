// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Address _$AddressFromJson(Map<String, dynamic> json) => _Address(
  lat: (json['lat'] as num?)?.toDouble(),
  lng: (json['lng'] as num?)?.toDouble(),
  formattedAddress: json['formattedAddress'] as String?,
  street: json['street'] as String?,
  city: json['city'] as String?,
  state: json['state'] as String?,
  country: json['country'] as String?,
);

Map<String, dynamic> _$AddressToJson(_Address instance) => <String, dynamic>{
  'lat': instance.lat,
  'lng': instance.lng,
  'formattedAddress': instance.formattedAddress,
  'street': instance.street,
  'city': instance.city,
  'state': instance.state,
  'country': instance.country,
};
