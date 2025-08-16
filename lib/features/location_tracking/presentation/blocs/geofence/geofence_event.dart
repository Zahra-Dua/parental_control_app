import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class GeofenceEvent {}

class GeofenceInitForChild extends GeofenceEvent {
  final String parentId;
  final String childId;
  GeofenceInitForChild({required this.parentId, required this.childId});
}

class GeofenceSavePressed extends GeofenceEvent {
  final String parentId;
  final String childId;
  final String zoneId; // if editing provide id, else new id
  final String name;
  final LatLng center;
  final double radiusMeters;
  final bool active;
  GeofenceSavePressed({
    required this.parentId,
    required this.childId,
    required this.zoneId,
    required this.name,
    required this.center,
    required this.radiusMeters,
    required this.active,
  });
}

class GeofenceDeletePressed extends GeofenceEvent {
  final String parentId;
  final String childId;
  final String zoneId;
  GeofenceDeletePressed({required this.parentId, required this.childId, required this.zoneId});
}