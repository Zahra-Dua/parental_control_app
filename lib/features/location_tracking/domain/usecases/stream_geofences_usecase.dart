import '../entities/geofence_zone.dart';
import '../repositories/geofence_repository.dart';

class StreamGeofencesUseCase {
  final GeofenceRepository repository;
  StreamGeofencesUseCase(this.repository);

  Stream<List<GeofenceZone>> call({required String parentId, required String childId}) {
    return repository.streamGeofences(parentId: parentId, childId: childId);
  }
}