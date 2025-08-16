import '../../domain/entities/geofence_zone.dart';

class GeofenceZoneModel extends GeofenceZone {
  const GeofenceZoneModel({
    required super.id,
    required super.name,
    required super.centerLat,
    required super.centerLng,
    required super.radiusMeters,
    required super.active,
  });

  factory GeofenceZoneModel.fromMap(String id, Map<String, dynamic> map) {
    final center = map['center'] as Map<String, dynamic>? ?? {};
    return GeofenceZoneModel(
      id: id,
      name: map['name'] as String? ?? 'Zone',
      centerLat: (center['lat'] ?? map['lat']).toDouble(),
      centerLng: (center['lng'] ?? map['lng']).toDouble(),
      radiusMeters: (map['radiusMeters'] ?? map['radius'] ?? 100).toDouble(),
      active: (map['active'] as bool?) ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'center': {
        'lat': centerLat,
        'lng': centerLng,
      },
      'radiusMeters': radiusMeters,
      'active': active,
    };
  }
}