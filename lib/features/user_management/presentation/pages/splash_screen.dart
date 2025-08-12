import 'dart:async';
import 'package:flutter/material.dart';
import 'package:parental_control_app/core/constants/app_colors.dart';
import 'package:parental_control_app/core/utils/media_query_helpers.dart';
import '../widgets/responsive_logo.dart';
import 'user_type_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // show splash for 1.6 seconds then navigate
    Timer(const Duration(milliseconds: 1600), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserTypeSelectionScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final mq = MQ(context);
    return Scaffold(
      backgroundColor: AppColors.lightCyan,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ResponsiveLogo(sizeFactor: 0.25),
              SizedBox(height: mq.h(0.03)),
              Text(
                'SafeNest',
                style: TextStyle(
                  fontSize: mq.sp(0.08),
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: mq.h(0.01)),
              Text(
                'Family digital safety made simple',
                style: TextStyle(
                  fontSize: mq.sp(0.035),
                  color: AppColors.deepTeal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
