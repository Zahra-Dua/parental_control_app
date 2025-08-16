import '../../domain/entities/child_location.dart';

class ChildLocationModel extends ChildLocation {
  const ChildLocationModel({
    required super.latitude,
    required super.longitude,
    required super.accuracyMeters,
    required super.timestamp,
    required super.source,
    super.speedMetersPerSecond,
  });

  factory ChildLocationModel.fromMap(Map<String, dynamic> map) {
    return ChildLocationModel(
      latitude: (map['lat'] ?? map['latitude']).toDouble(),
      longitude: (map['lng'] ?? map['longitude']).toDouble(),
      accuracyMeters: (map['accuracy'] ?? map['accuracyMeters'] ?? 0).toDouble(),
      speedMetersPerSecond: map['speed'] != null ? (map['speed'] as num).toDouble() : null,
      timestamp: DateTime.fromMillisecondsSinceEpoch((map['timestamp'] as num).toInt()),
      source: (map['source'] ?? 'device') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lat': latitude,
      'lng': longitude,
      'accuracy': accuracyMeters,
      'speed': speedMetersPerSecond,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'source': source,
    };
  }
}