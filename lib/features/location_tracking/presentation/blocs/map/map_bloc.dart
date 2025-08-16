import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parental_control_app/features/location_tracking/domain/entities/child_location.dart';
import 'package:parental_control_app/features/location_tracking/domain/entities/geofence_zone.dart';
import 'package:parental_control_app/features/location_tracking/domain/usecases/stream_child_location_usecase.dart';
import 'package:parental_control_app/features/location_tracking/domain/usecases/stream_geofences_usecase.dart';
import 'map_event.dart';
import 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  final StreamChildLocationUseCase streamChildLocationUseCase;
  final StreamGeofencesUseCase streamGeofencesUseCase;

  StreamSubscription<ChildLocation?>? _locationSub;
  StreamSubscription<List<GeofenceZone>>? _geofenceSub;
  String? _parentId;
  String? _childId;

  MapBloc({
    required this.streamChildLocationUseCase,
    required this.streamGeofencesUseCase,
  }) : super(MapInitial()) {
    on<MapStarted>(_onStarted);
    on<MapChildChanged>(_onChildChanged);
  }

  Future<void> _onStarted(MapStarted event, Emitter<MapState> emit) async {
    _parentId = event.parentId;
    _childId = event.childId;
    emit(MapLoading());
    _bindStreams(emit);
  }

  Future<void> _onChildChanged(MapChildChanged event, Emitter<MapState> emit) async {
    _childId = event.childId;
    emit(MapLoading());
    await _cancelSubs();
    _bindStreams(emit);
  }

  void _bindStreams(Emitter<MapState> emit) {
    final parentId = _parentId!;
    final childId = _childId!;

    _locationSub = streamChildLocationUseCase(parentId: parentId, childId: childId).listen((loc) {
      final currentState = state;
      if (currentState is MapLoaded) {
        emit(MapLoaded(lastLocation: loc, geofences: currentState.geofences));
      } else {
        emit(MapLoaded(lastLocation: loc, geofences: const []));
      }
    }, onError: (e) {
      emit(MapError(e.toString()));
    });

    _geofenceSub = streamGeofencesUseCase(parentId: parentId, childId: childId).listen((zones) {
      final currentState = state;
      if (currentState is MapLoaded) {
        emit(MapLoaded(lastLocation: currentState.lastLocation, geofences: zones));
      } else {
        emit(MapLoaded(lastLocation: null, geofences: zones));
      }
    }, onError: (e) {
      emit(MapError(e.toString()));
    });
  }

  Future<void> _cancelSubs() async {
    await _locationSub?.cancel();
    await _geofenceSub?.cancel();
  }

  @override
  Future<void> close() async {
    await _cancelSubs();
    return super.close();
  }
}