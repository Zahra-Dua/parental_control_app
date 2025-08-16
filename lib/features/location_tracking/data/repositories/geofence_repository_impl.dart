import '../../domain/entities/geofence_zone.dart';
import '../../domain/entities/zone_event.dart';
import '../../domain/repositories/geofence_repository.dart';
import '../datasources/geofence_remote_datasource.dart';
import '../models/geofence_zone_model.dart';

class GeofenceRepositoryImpl implements GeofenceRepository {
  final GeofenceRemoteDataSource remote;
  GeofenceRepositoryImpl({required this.remote});

  @override
  Future<void> deleteGeofence({required String parentId, required String childId, required String zoneId}) {
    return remote.deleteGeofence(parentId: parentId, childId: childId, zoneId: zoneId);
  }

  @override
  Future<void> setGeofence({required String parentId, required String childId, required GeofenceZone zone}) {
    final model = GeofenceZoneModel(
      id: zone.id,
      name: zone.name,
      centerLat: zone.centerLat,
      centerLng: zone.centerLng,
      radiusMeters: zone.radiusMeters,
      active: zone.active,
    );
    return remote.setGeofence(parentId: parentId, childId: childId, zone: model);
  }

  @override
  Stream<List<GeofenceZone>> streamGeofences({required String parentId, required String childId}) {
    return remote.streamGeofences(parentId: parentId, childId: childId);
  }

  @override
  Stream<List<ZoneEvent>> streamZoneEvents({required String parentId, required String childId}) {
    return remote.streamZoneEvents(parentId: parentId, childId: childId);
  }
}