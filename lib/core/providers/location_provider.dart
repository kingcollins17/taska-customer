import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../models/models.dart';

final locationProvider = FutureProvider<Address?>((ref) async {
  // if (Platform.isIOS) {
    return const Address(
      lat: 6.8593622,
      lng: 7.4131734,
      formattedAddress:
          'VC57+M7M, James Africanus Norton Rd, Ihe Nsukka, Nsukka 410105, Enugu, Nigeria, Ihe Nsukka, Nsukka, Enugu, Nigeria',
      street:
          'VC57+M7M, James Africanus Norton Rd, Ihe Nsukka, Nsukka 410105, Enugu, Nigeria',
      city: 'Nsukka',
      state: 'Enugu',
      country: 'Nigeria',
    );
  // }
  // final location = Location();
  // final geocoding = geo.GeocodingPlatform.instance;

  // bool serviceEnabled;
  // PermissionStatus permissionGranted;

  // serviceEnabled = await location.serviceEnabled();
  // if (!serviceEnabled) {
  //   serviceEnabled = await location.requestService();
  //   if (!serviceEnabled) {
  //     return null;
  //   }
  // }

  // permissionGranted = await location.hasPermission();
  // if (permissionGranted == PermissionStatus.denied) {
  //   permissionGranted = await location.requestPermission();
  //   if (permissionGranted != PermissionStatus.granted) {
  //     return null;
  //   }
  // }

  // final locationData = await location.getLocation();

  // try {
  //   // final placemarks = await geo.Geocoding().placemarkFromCoordinates(
  //   //   locationData.latitude!,
  //   //   locationData.longitude!,
  //   // );
  //   final placemarks = await geo.placemarkFromCoordinates(
  //     locationData.latitude!,
  //     locationData.longitude!,
  //   );

  //   if (placemarks.isNotEmpty) {
  //     final place = placemarks.first;

  //     final formattedAddressParts = <String?>[
  //       place.street,
  //       place.subLocality,
  //       place.locality,
  //       place.administrativeArea,
  //       place.country,
  //     ].where((e) => e != null && e.isNotEmpty).toList();

  //     return Address(
  //       lat: locationData.latitude,
  //       lng: locationData.longitude,
  //       formattedAddress: formattedAddressParts.join(', '),
  //       street: place.street,
  //       city: place.locality,
  //       state: place.administrativeArea,
  //       country: place.country,
  //     );
  //   }
  // } catch (e) {
  //   // Return Address with just coordinates if geocoding fails
  //   return Address(lat: locationData.latitude, lng: locationData.longitude);
  // }

  // return Address(lat: locationData.latitude, lng: locationData.longitude);
});
