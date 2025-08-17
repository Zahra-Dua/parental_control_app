import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:parental_control_app/features/user_management/data/datasources/user_remote_datasource.dart';
import 'package:parental_control_app/features/user_management/data/datasources/pairing_remote_datasource.dart';
import 'package:parental_control_app/features/user_management/data/repositories/user_repository_impl.dart';
import 'package:parental_control_app/features/user_management/data/repositories/pairing_repository_impl.dart';
import 'package:parental_control_app/features/user_management/domain/repositories/user_repository.dart';
import 'package:parental_control_app/features/user_management/domain/repositories/pairing_repository.dart';
import 'package:parental_control_app/features/user_management/domain/usecases/login_usecase.dart';
import 'package:parental_control_app/features/user_management/domain/usecases/signup_usecase.dart';
import 'package:parental_control_app/features/user_management/domain/usecases/reset_password_usecase.dart';
import 'package:parental_control_app/features/user_management/domain/usecases/generate_parent_qr_usecase.dart';
import 'package:parental_control_app/features/user_management/domain/usecases/link_child_to_parent_usecase.dart';
import 'package:parental_control_app/features/user_management/domain/usecases/get_parent_children_usecase.dart';
import 'package:parental_control_app/features/user_management/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:parental_control_app/features/location_tracking/data/datasources/geofence_remote_datasource.dart';
import 'package:parental_control_app/features/location_tracking/data/datasources/location_remote_datasource.dart';
import 'package:parental_control_app/features/location_tracking/data/repositories/geofence_repository_impl.dart';
import 'package:parental_control_app/features/location_tracking/data/repositories/location_repository_impl.dart';
import 'package:parental_control_app/features/location_tracking/domain/repositories/geofence_repository.dart';
import 'package:parental_control_app/features/location_tracking/domain/repositories/location_repository.dart';
import 'package:parental_control_app/features/location_tracking/domain/usecases/get_last_location_usecase.dart';
import 'package:parental_control_app/features/location_tracking/domain/usecases/stream_child_location_usecase.dart';
import 'package:parental_control_app/features/location_tracking/domain/usecases/stream_geofences_usecase.dart';
import 'package:parental_control_app/features/location_tracking/domain/usecases/set_geofence_usecase.dart';
import 'package:parental_control_app/features/location_tracking/domain/usecases/delete_geofence_usecase.dart';
import 'package:parental_control_app/features/location_tracking/domain/usecases/stream_zone_events_usecase.dart';
import 'package:parental_control_app/features/location_tracking/presentation/blocs/map/map_bloc.dart';
import 'package:parental_control_app/features/location_tracking/presentation/blocs/geofence/geofence_bloc.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Firebase instances
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Data source
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(auth: sl(), firestore: sl()),
  );
  sl.registerLazySingleton<PairingRemoteDataSource>(
    () => PairingRemoteDataSourceImpl(firestore: sl(), auth: sl()),
  );

  // Location & geofence data sources
  sl.registerLazySingleton<LocationRemoteDataSource>(
    () => LocationRemoteDataSourceImpl(firestore: sl()),
  );
  sl.registerLazySingleton<GeofenceRemoteDataSource>(
    () => GeofenceRemoteDataSourceImpl(firestore: sl()),
  );

  // Repository
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton<PairingRepository>(
    () => PairingRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(remote: sl()),
  );
  sl.registerLazySingleton<GeofenceRepository>(
    () => GeofenceRepositoryImpl(remote: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => SignupUseCase(sl()));
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));
  sl.registerLazySingleton(() => GenerateParentQRUseCase(sl()));
  sl.registerLazySingleton(() => LinkChildToParentUseCase(sl()));
  sl.registerLazySingleton(() => GetParentChildrenUseCase(sl()));

  // Location / geofence use cases
  sl.registerLazySingleton(() => GetLastLocationUseCase(sl()));
  sl.registerLazySingleton(() => StreamChildLocationUseCase(sl()));
  sl.registerLazySingleton(() => StreamGeofencesUseCase(sl()));
  sl.registerLazySingleton(() => SetGeofenceUseCase(sl()));
  sl.registerLazySingleton(() => DeleteGeofenceUseCase(sl()));
  sl.registerLazySingleton(() => StreamZoneEventsUseCase(sl()));

  // Bloc (factory so new instance per screen if needed)
  sl.registerFactory(
    () => AuthBloc(
      signUpUseCase: sl<SignupUseCase>(),
      signInUseCase: sl<LoginUseCase>(),
      resetPasswordUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => MapBloc(
      streamChildLocationUseCase: sl(),
      streamGeofencesUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => GeofenceBloc(
      setGeofenceUseCase: sl(),
      deleteGeofenceUseCase: sl(),
      getLastLocationUseCase: sl(),
    ),
  );
}
