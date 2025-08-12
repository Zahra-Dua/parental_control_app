import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:parental_control_app/features/user_management/data/datasources/user_remote_datasource.dart';
import 'package:parental_control_app/features/user_management/data/repositories/user_repository_impl.dart';
import 'package:parental_control_app/features/user_management/domain/repositories/user_repository.dart';
import 'package:parental_control_app/features/user_management/domain/usecases/login_usecase.dart';
import 'package:parental_control_app/features/user_management/domain/usecases/reset_password_usecase.dart';
import 'package:parental_control_app/features/user_management/domain/usecases/signup_usecase.dart';
import 'package:parental_control_app/features/user_management/presentation/blocs/auth_bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // Firebase instances
  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Data source
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(auth: sl(), firestore: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => ResetPasswordUseCase(sl()));

  // Bloc (factory so new instance per screen if needed)
  sl.registerFactory(
    () => AuthBloc(
      signUpUseCase: sl(),
      signInUseCase: sl(),
      resetPasswordUseCase: sl(),
    ),
  );
}
