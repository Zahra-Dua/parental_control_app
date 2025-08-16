abstract class MapEvent {}

class MapStarted extends MapEvent {
  final String parentId;
  final String childId;
  MapStarted({required this.parentId, required this.childId});
}

class MapChildChanged extends MapEvent {
  final String childId;
  MapChildChanged(this.childId);
}