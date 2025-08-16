import '../entities/zone_event.dart';
import '../repositories/geofence_repository.dart';

class StreamZoneEventsUseCase {
  final GeofenceRepository repository;
  StreamZoneEventsUseCase(this.repository);

  Stream<List<ZoneEvent>> call({required String parentId, required String childId}) {
    return repository.streamZoneEvents(parentId: parentId, childId: childId);
  }
}