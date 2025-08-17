import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parental_control_app/features/location_tracking/data/models/geofence_zone_model.dart';
import 'package:parental_control_app/features/location_tracking/data/models/zone_event_model.dart';
import 'package:parental_control_app/core/errors/exceptions.dart';

abstract class GeofenceRemoteDataSource {
  /// Create a new geofence zone for a child
  Future<GeofenceZoneModel> createGeofenceZone(GeofenceZoneModel zone);

  /// Get all geofence zones for a specific child
  Future<List<GeofenceZoneModel>> getGeofenceZones(String childId);

  /// Stream geofence zones for real-time updates
  Stream<List<GeofenceZoneModel>> streamGeofenceZones(String childId);

  /// Update an existing geofence zone
  Future<GeofenceZoneModel> updateGeofenceZone(GeofenceZoneModel zone);

  /// Delete a geofence zone
  Future<void> deleteGeofenceZone(String zoneId);

  /// Validate if a geofence zone is within acceptable limits
  Future<bool> validateGeofenceZone(GeofenceZoneModel zone);

  /// Create a zone event (entry/exit)
  Future<ZoneEventModel> createZoneEvent(ZoneEventModel event);

  /// Stream zone events for notifications
  Stream<List<ZoneEventModel>> streamZoneEvents(String childId);

  /// Get zone event history
  Future<List<ZoneEventModel>> getZoneEventHistory({
    required String childId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Mark zone event as notified
  Future<void> markEventAsNotified(String eventId);
}

class GeofenceRemoteDataSourceImpl implements GeofenceRemoteDataSource {
  final FirebaseFirestore firestore;

  GeofenceRemoteDataSourceImpl({required this.firestore});

  @override
  Future<GeofenceZoneModel> createGeofenceZone(GeofenceZoneModel zone) async {
    try {
      final docRef = firestore
          .collection('children')
          .doc(zone.childId)
          .collection('geofences')
          .doc();

      final zoneWithId = zone.copyWith(id: docRef.id);
      await docRef.set(zoneWithId.toFirestore());
      
      return zoneWithId;
    } catch (e) {
      throw ServerException('Failed to create geofence zone: ${e.toString()}');
    }
  }

  @override
  Future<List<GeofenceZoneModel>> getGeofenceZones(String childId) async {
    try {
      final querySnapshot = await firestore
          .collection('children')
          .doc(childId)
          .collection('geofences')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        return GeofenceZoneModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw ServerException('Failed to get geofence zones: ${e.toString()}');
    }
  }

  @override
  Stream<List<GeofenceZoneModel>> streamGeofenceZones(String childId) {
    return firestore
        .collection('children')
        .doc(childId)
        .collection('geofences')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return GeofenceZoneModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<GeofenceZoneModel> updateGeofenceZone(GeofenceZoneModel zone) async {
    try {
      final docRef = firestore
          .collection('children')
          .doc(zone.childId)
          .collection('geofences')
          .doc(zone.id);

      final updatedZone = zone.copyWith(updatedAt: DateTime.now());
      await docRef.update(updatedZone.toFirestore());
      
      return updatedZone;
    } catch (e) {
      throw ServerException('Failed to update geofence zone: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteGeofenceZone(String zoneId) async {
    try {
      // First, get the zone to find the childId
      final zoneQuery = await firestore
          .collectionGroup('geofences')
          .where(FieldPath.documentId, isEqualTo: zoneId)
          .get();

      if (zoneQuery.docs.isEmpty) {
        throw const ServerException('Geofence zone not found');
      }

      final zoneDoc = zoneQuery.docs.first;
      
      // Soft delete by marking as inactive
      await zoneDoc.reference.update({
        'isActive': false,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw ServerException('Failed to delete geofence zone: ${e.toString()}');
    }
  }

  @override
  Future<bool> validateGeofenceZone(GeofenceZoneModel zone) async {
    try {
      // Basic validation rules
      const double minRadius = 50.0; // 50 meters minimum
      const double maxRadius = 10000.0; // 10km maximum
      
      if (zone.radiusMeters < minRadius || zone.radiusMeters > maxRadius) {
        return false;
      }

      // Validate coordinates
      if (zone.centerLatitude < -90 || zone.centerLatitude > 90) {
        return false;
      }
      
      if (zone.centerLongitude < -180 || zone.centerLongitude > 180) {
        return false;
      }

      // Additional validations can be added here
      // e.g., check if zone overlaps with restricted areas
      
      return true;
    } catch (e) {
      throw ValidationException('Failed to validate geofence zone: ${e.toString()}');
    }
  }

  @override
  Future<ZoneEventModel> createZoneEvent(ZoneEventModel event) async {
    try {
      final docRef = firestore
          .collection('children')
          .doc(event.childId)
          .collection('zoneEvents')
          .doc();

      final eventWithId = event.copyWith(id: docRef.id);
      await docRef.set(eventWithId.toFirestore());
      
      return eventWithId;
    } catch (e) {
      throw ServerException('Failed to create zone event: ${e.toString()}');
    }
  }

  @override
  Stream<List<ZoneEventModel>> streamZoneEvents(String childId) {
    return firestore
        .collection('children')
        .doc(childId)
        .collection('zoneEvents')
        .orderBy('occurredAt', descending: true)
        .limit(50) // Limit recent events for performance
        .snapshots()
        .map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return ZoneEventModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<List<ZoneEventModel>> getZoneEventHistory({
    required String childId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final querySnapshot = await firestore
          .collection('children')
          .doc(childId)
          .collection('zoneEvents')
          .where('occurredAt', isGreaterThanOrEqualTo: startDate.millisecondsSinceEpoch)
          .where('occurredAt', isLessThanOrEqualTo: endDate.millisecondsSinceEpoch)
          .orderBy('occurredAt', descending: true)
          .limit(1000)
          .get();

      return querySnapshot.docs.map((doc) {
        return ZoneEventModel.fromFirestore(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      throw ServerException('Failed to get zone event history: ${e.toString()}');
    }
  }

  @override
  Future<void> markEventAsNotified(String eventId) async {
    try {
      // Find the event across all children (using collection group query)
      final eventQuery = await firestore
          .collectionGroup('zoneEvents')
          .where(FieldPath.documentId, isEqualTo: eventId)
          .get();

      if (eventQuery.docs.isEmpty) {
        throw const ServerException('Zone event not found');
      }

      final eventDoc = eventQuery.docs.first;
      await eventDoc.reference.update({
        'isNotified': true,
      });
    } catch (e) {
      throw ServerException('Failed to mark event as notified: ${e.toString()}');
    }
  }
}