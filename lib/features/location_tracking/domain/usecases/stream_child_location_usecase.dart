import '../entities/child_location.dart';
import '../repositories/location_repository.dart';

class StreamChildLocationUseCase {
  final LocationRepository repository;
  StreamChildLocationUseCase(this.repository);

  Stream<ChildLocation?> call({required String parentId, required String childId}) {
    return repository.streamLastLocation(parentId: parentId, childId: childId);
  }
}