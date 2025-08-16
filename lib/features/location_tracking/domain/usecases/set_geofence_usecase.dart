import '../entities/geofence_zone.dart';
import '../repositories/geofence_repository.dart';

class SetGeofenceUseCase {
  final GeofenceRepository repository;
  SetGeofenceUseCase(this.repository);

  Future<void> call({
    required String parentId,
    required String childId,
    required GeofenceZone zone,
  }) {
    return repository.setGeofence(parentId: parentId, childId: childId, zone: zone);
  }
}