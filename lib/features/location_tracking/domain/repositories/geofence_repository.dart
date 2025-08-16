import '../entities/geofence_zone.dart';
import '../entities/zone_event.dart';

abstract class GeofenceRepository {
  Stream<List<GeofenceZone>> streamGeofences({required String parentId, required String childId});
  Future<void> setGeofence({
    required String parentId,
    required String childId,
    required GeofenceZone zone,
  });
  Future<void> deleteGeofence({
    required String parentId,
    required String childId,
    required String zoneId,
  });
  Stream<List<ZoneEvent>> streamZoneEvents({required String parentId, required String childId});
}