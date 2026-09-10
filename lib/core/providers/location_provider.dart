import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart';
import 'package:seeker_app/core/core.dart';
import '../models/models.dart';

/// StateProvider for toggling between live location and mock location.
/// Default value is set to `false` (mock).
final useLiveLocationProvider = StateProvider<bool>((ref) => false);

const mockLocationAddress = Address(
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

final locationProvider = FutureProvider<Address?>((ref) async {
  final useLive = ref.watch(useLiveLocationProvider);

  if (!useLive) {
    'Using Mock Location'.debugLog();
    mockLocationAddress.toJson().debugLog();
    return mockLocationAddress;
  }

  'Fetching Live Location...'.debugLog();
  final location = Location();

  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) {
      'Location service disabled; falling back to mock location'.debugLog(type: LogType.warn);
      mockLocationAddress.toJson().debugLog();
      return mockLocationAddress;
    }
  }

  PermissionStatus permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) {
      'Location permission denied; falling back to mock location'.debugLog(type: LogType.warn);
      mockLocationAddress.toJson().debugLog();
      return mockLocationAddress;
    }
  }

  final locationData = await location.getLocation();

  try {
    final placemarks = await geo.placemarkFromCoordinates(
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

      final address = Address(
        lat: locationData.latitude,
        lng: locationData.longitude,
        formattedAddress: formattedAddressParts.join(', '),
        street: place.street,
        city: place.locality,
        state: place.administrativeArea,
        country: place.country,
      );
      'Live Location (Geocoded)'.debugLog();
      address.toJson().debugLog();
      return address;
    }
  } catch (e) {
    AppErrorHandler.instance.handleError(e);
    final address = Address(lat: locationData.latitude, lng: locationData.longitude);
    'Live Location (Geocoding error, coordinates only)'.debugLog(type: LogType.error);
    address.toJson().debugLog();
    return address;
  }

  final fallbackAddress = Address(lat: locationData.latitude, lng: locationData.longitude);
  'Live Location (Coordinates only)'.debugLog();
  fallbackAddress.toJson().debugLog();
  return fallbackAddress;
});
