import '../../domain/entities/zone_event.dart';

class ZoneEventModel extends ZoneEvent {
  const ZoneEventModel({
    required super.id,
    required super.zoneId,
    required super.type,
    required super.occurredAt,
  });

  factory ZoneEventModel.fromMap(String id, Map<String, dynamic> map) {
    return ZoneEventModel(
      id: id,
      zoneId: map['zoneId'] as String? ?? '',
      type: map['type'] as String? ?? 'enter',
      occurredAt: DateTime.fromMillisecondsSinceEpoch((map['occurredAt'] as num).toInt()),
    );
  }
}