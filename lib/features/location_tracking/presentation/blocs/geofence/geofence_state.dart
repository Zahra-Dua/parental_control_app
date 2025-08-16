import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class GeofenceState {}

class GeofenceInitial extends GeofenceState {}

class GeofenceLoading extends GeofenceState {}

class GeofenceReady extends GeofenceState {
  final LatLng suggestedCenter;
  GeofenceReady({required this.suggestedCenter});
}

class GeofenceSaving extends GeofenceState {}

class GeofenceSaved extends GeofenceState {}

class GeofenceError extends GeofenceState {
  final String message;
  GeofenceError(this.message);
}