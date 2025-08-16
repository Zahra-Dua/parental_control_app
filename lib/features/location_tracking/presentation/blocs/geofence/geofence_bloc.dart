import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:parental_control_app/features/location_tracking/domain/entities/geofence_zone.dart';
import 'package:parental_control_app/features/location_tracking/domain/usecases/get_last_location_usecase.dart';
import 'package:parental_control_app/features/location_tracking/domain/usecases/set_geofence_usecase.dart';
import 'package:parental_control_app/features/location_tracking/domain/usecases/delete_geofence_usecase.dart';
import 'geofence_event.dart';
import 'geofence_state.dart';

class GeofenceBloc extends Bloc<GeofenceEvent, GeofenceState> {
  final SetGeofenceUseCase setGeofenceUseCase;
  final DeleteGeofenceUseCase deleteGeofenceUseCase;
  final GetLastLocationUseCase getLastLocationUseCase;

  GeofenceBloc({
    required this.setGeofenceUseCase,
    required this.deleteGeofenceUseCase,
    required this.getLastLocationUseCase,
  }) : super(GeofenceInitial()) {
    on<GeofenceInitForChild>(_onInit);
    on<GeofenceSavePressed>(_onSave);
    on<GeofenceDeletePressed>(_onDelete);
  }

  Future<void> _onInit(GeofenceInitForChild event, Emitter<GeofenceState> emit) async {
    emit(GeofenceLoading());
    try {
      final last = await getLastLocationUseCase(parentId: event.parentId, childId: event.childId);
      if (last != null) {
        emit(GeofenceReady(suggestedCenter: LatLng(last.latitude, last.longitude)));
      } else {
        emit(GeofenceReady(suggestedCenter: const LatLng(33.6844, 73.0479)));
      }
    } catch (e) {
      emit(GeofenceError(e.toString()));
    }
  }

  Future<void> _onSave(GeofenceSavePressed event, Emitter<GeofenceState> emit) async {
    emit(GeofenceSaving());
    try {
      final id = event.zoneId.isEmpty ? const Uuid().v4() : event.zoneId;
      final zone = GeofenceZone(
        id: id,
        name: event.name,
        centerLat: event.center.latitude,
        centerLng: event.center.longitude,
        radiusMeters: event.radiusMeters,
        active: event.active,
      );
      await setGeofenceUseCase(parentId: event.parentId, childId: event.childId, zone: zone);
      emit(GeofenceSaved());
    } catch (e) {
      emit(GeofenceError(e.toString()));
    }
  }

  Future<void> _onDelete(GeofenceDeletePressed event, Emitter<GeofenceState> emit) async {
    emit(GeofenceSaving());
    try {
      await deleteGeofenceUseCase(parentId: event.parentId, childId: event.childId, zoneId: event.zoneId);
      emit(GeofenceSaved());
    } catch (e) {
      emit(GeofenceError(e.toString()));
    }
  }
}