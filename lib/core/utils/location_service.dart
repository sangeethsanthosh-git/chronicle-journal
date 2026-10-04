import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String displayName;

  const LocationResult({
    required this.latitude,
    required this.longitude,
    required this.displayName,
  });
}

class LocationService {
  static Future<LocationResult?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final latStr = position.latitude.toStringAsFixed(2);
      final lonStr = position.longitude.toStringAsFixed(2);
      final displayName = '$latStr°, $lonStr°';

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        displayName: displayName,
      );
    } catch (_) {
      return null;
    }
  }
}
