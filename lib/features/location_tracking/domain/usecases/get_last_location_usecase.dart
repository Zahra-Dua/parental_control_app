import '../entities/child_location.dart';
import '../repositories/location_repository.dart';

class GetLastLocationUseCase {
  final LocationRepository repository;
  GetLastLocationUseCase(this.repository);

  Future<ChildLocation?> call({required String parentId, required String childId}) {
    return repository.getLastLocation(parentId: parentId, childId: childId);
  }
}