import 'package:flutter/material.dart';
import 'package:parental_control_app/core/constants/app_colors.dart';
import 'package:parental_control_app/core/utils/media_query_helpers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/user_type_card.dart';
import '../widgets/responsive_logo.dart';
import 'dummy_child_screen.dart';
import 'login_screen.dart'; // We'll create a placeholder login screen (simple) below.

class UserTypeSelectionScreen extends StatelessWidget {
  const UserTypeSelectionScreen({super.key});

  Future<void> _saveUserType(String type) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_type', type);
  }

  @override
  Widget build(BuildContext context) {
    final mq = MQ(context);

    return Scaffold(
      backgroundColor: AppColors.lightCyan,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: mq.w(0.06)),
          child: Column(
            children: [
              SizedBox(height: mq.h(0.04)),
              ResponsiveLogo(sizeFactor: 0.20),
              SizedBox(height: mq.h(0.02)),
              Text(
                'SafeNest',
                style: TextStyle(
                  fontSize: mq.sp(0.09),
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              SizedBox(height: mq.h(0.01)),
              Text(
                'Choose Your Account Type',
                style: TextStyle(
                  fontSize: mq.sp(0.043),
                  color: AppColors.darkCyan,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: mq.h(0.01)),
              Text(
                "Select whether you're a parent managing family safety or a child joining your family's SafeNest.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: mq.sp(0.034),
                  color: AppColors.black.withOpacity(0.7),
                ),
              ),
              SizedBox(height: mq.h(0.04)),

              // Parent Card
              UserTypeCard(
                icon: Icons.family_restroom,
                title: 'Parent',
                subtitle: 'Family Safety Manager',
                description:
                    "Manage and monitor your family's digital safety with comprehensive parental controls.",
                features: const [
                  "Monitor children's activities",
                  "Set screen time limits",
                  "Block inappropriate content",
                  "Track location & send alerts",
                  "Create family safety rules",
                ],
                buttonText: 'Continue as PARENT',
                onPressed: () async {
                  await _saveUserType('parent');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
              SizedBox(height: mq.h(0.03)),
              // Child Card
              UserTypeCard(
                icon: Icons.child_friendly,
                title: 'Child',
                subtitle: 'Protected Family Member',
                description:
                    "Join your family's SafeNest and stay connected with built-in safety features.",
                features: const [
                  "Emergency SOS button",
                  "View your screen time",
                  "Receive parent notifications",
                  "Safe browsing protection",
                  "Family location sharing",
                ],
                buttonText: 'Continue as CHILD',
                onPressed: () async {
                  await _saveUserType('child');
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DummyChildScreen()),
                  );
                },
              ),
              SizedBox(height: mq.h(0.03)),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Need help? Contact support',
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
              SizedBox(height: mq.h(0.02)),
            ],
          ),
        ),
      ),
    );
  }
}
