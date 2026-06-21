import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Location state
class LocationState {
  final bool isLoading;
  final Position? position;
  final String? error;
  final String? city;
  final String? country;

  const LocationState({
    required this.isLoading,
    this.position,
    this.error,
    this.city,
    this.country,
  });

  factory LocationState.initial() {
    return const LocationState(isLoading: false);
  }

  factory LocationState.loading() {
    return const LocationState(isLoading: true);
  }

  factory LocationState.success(Position position, {String? city, String? country}) {
    return LocationState(
      isLoading: false,
      position: position,
      city: city,
      country: country,
    );
  }

  factory LocationState.error(String message) {
    return LocationState(isLoading: false, error: message);
  }
}

/// Location notifier
class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(LocationState.initial());

  /// Request location permission and get current position
  Future<void> getCurrentLocation() async {
    try {
      state = LocationState.loading();

      // Check location service
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = LocationState.error('Location services are disabled');
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = LocationState.error('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = LocationState.error('Location permissions are permanently denied');
        return;
      }

      // Get position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Reverse geocode to get city
      final addresses = await Geolocator.placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String? city;
      String? country;
      if (addresses.isNotEmpty) {
        city = addresses.first.locality;
        country = addresses.first.country;
      }

      state = LocationState.success(position, city: city, country: country);
    } catch (e) {
      state = LocationState.error(e.toString());
    }
  }

  /// Get distance between two points in kilometers
  double getDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2) / 1000;
  }
}

/// Location provider
final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});

/// Deals provider - fetches nearby deals
final nearbyDealsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  final locationState = ref.watch(locationProvider);
  
  if (locationState.position == null) {
    return const Stream.empty();
  }

  final position = locationState.position!;
  
  // Query deals within radius
  return FirebaseFirestore.instance
      .collection('deals')
      .where('isActive', isEqualTo: true)
      .where('expiryDate', isGreaterThan: Timestamp.now())
      .orderBy('expiryDate')
      .limit(20)
      .snapshots()
      .map((snapshot) {
    return snapshot.docs.map((doc) => doc.data()).toList();
  });
});
