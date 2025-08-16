import 'package:parental_control_app/features/location_tracking/domain/entities/child_location.dart';
import 'package:parental_control_app/features/location_tracking/domain/entities/geofence_zone.dart';

abstract class MapState {}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapLoaded extends MapState {
  final ChildLocation? lastLocation;
  final List<GeofenceZone> geofences;
  MapLoaded({required this.lastLocation, required this.geofences});
}

class MapError extends MapState {
  final String message;
  MapError(this.message);
}