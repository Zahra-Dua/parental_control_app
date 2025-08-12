import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:parental_control_app/core/di/service_locator.dart';
import 'package:parental_control_app/features/user_management/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'core/constants/app_colors.dart';
import 'core/di/service_locator.dart' as di;
import 'features/user_management/presentation/pages/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await di.initServiceLocator(); // Initialize GetIt service locator
  runApp(const SafeNestApp());
}

class SafeNestApp extends StatelessWidget {
  const SafeNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<AuthBloc>()),
        // Add other BlocProviders here if you have them
      ],
      child: MaterialApp(
        title: 'SafeNest',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.offWhite,
          primaryColor: AppColors.darkCyan,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.lightCyan,
            elevation: 0,
            iconTheme: const IconThemeData(color: AppColors.black),
          ),
          textTheme: const TextTheme(
            bodyMedium: TextStyle(color: Colors.black),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
