import '../../domain/entities/child_location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_remote_datasource.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource remote;
  LocationRepositoryImpl({required this.remote});

  @override
  Future<ChildLocation?> getLastLocation({required String parentId, required String childId}) {
    return remote.getLastLocation(parentId: parentId, childId: childId);
  }

  @override
  Stream<ChildLocation?> streamLastLocation({required String parentId, required String childId}) {
    return remote.streamLastLocation(parentId: parentId, childId: childId);
  }
}