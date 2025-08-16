import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/geofence_zone_model.dart';
import '../models/zone_event_model.dart';

abstract class GeofenceRemoteDataSource {
  Stream<List<GeofenceZoneModel>> streamGeofences({required String parentId, required String childId});
  Future<void> setGeofence({required String parentId, required String childId, required GeofenceZoneModel zone});
  Future<void> deleteGeofence({required String parentId, required String childId, required String zoneId});
  Stream<List<ZoneEventModel>> streamZoneEvents({required String parentId, required String childId});
}

class GeofenceRemoteDataSourceImpl implements GeofenceRemoteDataSource {
  final FirebaseFirestore firestore;
  GeofenceRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> _zones(String parentId, String childId) {
    return firestore.collection('users').doc(parentId)
      .collection('children').doc(childId)
      .collection('geofences');
  }

  CollectionReference<Map<String, dynamic>> _events(String parentId, String childId) {
    return firestore.collection('users').doc(parentId)
      .collection('children').doc(childId)
      .collection('zoneEvents');
  }

  @override
  Stream<List<GeofenceZoneModel>> streamGeofences({required String parentId, required String childId}) {
    return _zones(parentId, childId).snapshots().map((snap) => snap.docs
      .map((d) => GeofenceZoneModel.fromMap(d.id, d.data()))
      .toList());
  }

  @override
  Future<void> setGeofence({required String parentId, required String childId, required GeofenceZoneModel zone}) async {
    final doc = _zones(parentId, childId).doc(zone.id);
    await doc.set(zone.toMap(), SetOptions(merge: true));
  }

  @override
  Future<void> deleteGeofence({required String parentId, required String childId, required String zoneId}) {
    return _zones(parentId, childId).doc(zoneId).delete();
  }

  @override
  Stream<List<ZoneEventModel>> streamZoneEvents({required String parentId, required String childId}) {
    return _events(parentId, childId)
      .orderBy('occurredAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snap) => snap.docs.map((d) => ZoneEventModel.fromMap(d.id, d.data())).toList());
  }
}