import '../repositories/geofence_repository.dart';

class DeleteGeofenceUseCase {
  final GeofenceRepository repository;
  DeleteGeofenceUseCase(this.repository);

  Future<void> call({
    required String parentId,
    required String childId,
    required String zoneId,
  }) {
    return repository.deleteGeofence(parentId: parentId, childId: childId, zoneId: zoneId);
  }
}