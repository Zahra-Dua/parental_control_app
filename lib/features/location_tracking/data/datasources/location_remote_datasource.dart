import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parental_control_app/features/location_tracking/data/models/child_location_model.dart';
import 'package:parental_control_app/core/errors/exceptions.dart';

abstract class LocationRemoteDataSource {
  /// Stream real-time location updates for a specific child
  Stream<ChildLocationModel> streamChildLocation(String childId);

  /// Get the last known location for a child
  Future<ChildLocationModel?> getLastKnownLocation(String childId);

  /// Update child's location (typically called from child device)
  Future<void> updateChildLocation(ChildLocationModel location);

  /// Get location history for a child within a date range
  Future<List<ChildLocationModel>> getLocationHistory({
    required String childId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Stop location tracking for a child
  Future<void> stopLocationTracking(String childId);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final FirebaseFirestore firestore;

  LocationRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<ChildLocationModel> streamChildLocation(String childId) {
    return firestore
        .collection('children')
        .doc(childId)
        .collection('locations')
        .doc('lastLocation')
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) {
        throw const CacheException('No location data found');
      }
      
      return ChildLocationModel.fromFirestore(doc.data()!, childId);
    });
  }

  @override
  Future<ChildLocationModel?> getLastKnownLocation(String childId) async {
    try {
      final doc = await firestore
          .collection('children')
          .doc(childId)
          .collection('locations')
          .doc('lastLocation')
          .get();

      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return ChildLocationModel.fromFirestore(doc.data()!, childId);
    } catch (e) {
      throw ServerException('Failed to get last known location: ${e.toString()}');
    }
  }

  @override
  Future<void> updateChildLocation(ChildLocationModel location) async {
    try {
      final batch = firestore.batch();

      // Update last location document
      final lastLocationRef = firestore
          .collection('children')
          .doc(location.childId)
          .collection('locations')
          .doc('lastLocation');
      
      batch.set(lastLocationRef, location.toFirestore());

      // Also add to history collection for tracking
      final historyRef = firestore
          .collection('children')
          .doc(location.childId)
          .collection('locations')
          .doc('history')
          .collection('entries')
          .doc();

      batch.set(historyRef, {
        ...location.toFirestore(),
        'id': historyRef.id,
      });

      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to update child location: ${e.toString()}');
    }
  }

  @override
  Future<List<ChildLocationModel>> getLocationHistory({
    required String childId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final query = await firestore
          .collection('children')
          .doc(childId)
          .collection('locations')
          .doc('history')
          .collection('entries')
          .where('timestamp', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
          .where('timestamp', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
          .orderBy('timestamp', descending: true)
          .limit(1000)
          .get();

      return query.docs.map((doc) {
        return ChildLocationModel.fromFirestore(doc.data(), childId);
      }).toList();
    } catch (e) {
      throw ServerException('Failed to get location history: ${e.toString()}');
    }
  }

  @override
  Future<void> stopLocationTracking(String childId) async {
    try {
      // Mark the child's location as inactive
      final lastLocationRef = firestore
          .collection('children')
          .doc(childId)
          .collection('locations')
          .doc('lastLocation');

      await lastLocationRef.update({
        'isActive': false,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw ServerException('Failed to stop location tracking: ${e.toString()}');
    }
  }
}