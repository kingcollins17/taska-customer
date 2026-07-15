import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geo;
import '../models/models.dart';

final locationProvider = FutureProvider<Address?>((ref) async {
  final location = Location();
  final geo.Geocoding geocoding = geo.Geocoding();

  bool serviceEnabled;
  PermissionStatus permissionGranted;

  serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      return null;
    }
  }

  permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      return null;
    }
  }

  final locationData = await location.getLocation();

  if (locationData.latitude == null || locationData.longitude == null) {
    return null;
  }

  try {
    final placemarks = await geocoding.placemarkFromCoordinates(
      locationData.latitude!,
      locationData.longitude!,
    );

    if (placemarks.isNotEmpty) {
      final place = placemarks.first;

      final formattedAddressParts = <String?>[
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.country,
      ].where((e) => e != null && e.isNotEmpty).toList();

      return Address(
        lat: locationData.latitude,
        lng: locationData.longitude,
        formattedAddress: formattedAddressParts.join(', '),
        street: place.street,
        city: place.locality,
        state: place.administrativeArea,
        country: place.country,
      );
    }
  } catch (e) {
    // Return Address with just coordinates if geocoding fails
    return Address(lat: locationData.latitude, lng: locationData.longitude);
  }

  return Address(lat: locationData.latitude, lng: locationData.longitude);
});
