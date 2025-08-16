import 'package:parental_control_app/features/location_tracking/domain/entities/child_location.dart';

abstract class LocationRepository {
  Future<ChildLocation?> getLastLocation({required String parentId, required String childId});
  Stream<ChildLocation?> streamLastLocation({required String parentId, required String childId});
}