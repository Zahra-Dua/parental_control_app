import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/child_location_model.dart';

abstract class LocationRemoteDataSource {
  Future<ChildLocationModel?> getLastLocation({required String parentId, required String childId});
  Stream<ChildLocationModel?> streamLastLocation({required String parentId, required String childId});
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final FirebaseFirestore firestore;
  LocationRemoteDataSourceImpl({required this.firestore});

  DocumentReference<Map<String, dynamic>> _lastLocationDoc(String parentId, String childId) {
    return firestore.collection('users').doc(parentId)
      .collection('children').doc(childId)
      .doc('lastLocation');
  }

  @override
  Future<ChildLocationModel?> getLastLocation({required String parentId, required String childId}) async {
    final doc = await _lastLocationDoc(parentId, childId).get();
    if (!doc.exists) return null;
    final data = doc.data();
    if (data == null) return null;
    return ChildLocationModel.fromMap(data);
    }

  @override
  Stream<ChildLocationModel?> streamLastLocation({required String parentId, required String childId}) {
    return _lastLocationDoc(parentId, childId).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      final data = snapshot.data();
      if (data == null) return null;
      return ChildLocationModel.fromMap(data);
    });
  }
}