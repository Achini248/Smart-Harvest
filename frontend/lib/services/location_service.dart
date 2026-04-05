// lib/services/location_service.dart
// Smart Harvest — Location helper with web support.
// On web the browser Geolocation API is used transparently by the geolocator
// package. No special handling needed here — just wrap the call.

import 'package:flutter/foundation.dart' show kIsWeb;

/// Returns a string representation of the user's current location,
/// or a fallback default (Colombo, LK) if permission is denied or unavailable.
///
/// Actual GPS calls are handled inside the weather feature datasource.
/// This service is a placeholder for any cross-cutting location logic.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  /// Default location used as fallback (Colombo, Sri Lanka).
  static const double defaultLat = 6.9271;
  static const double defaultLng = 79.8612;
  static const String defaultCity = 'Colombo';

  bool get isWebPlatform => kIsWeb;
}
