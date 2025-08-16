import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:parental_control_app/core/constants/app_colors.dart';
import 'package:parental_control_app/core/utils/media_query_helpers.dart';
import 'package:parental_control_app/features/user_management/presentation/pages/child_scan_qr_screen.dart';

class ChildPermissionsScreen extends StatefulWidget {
  const ChildPermissionsScreen({Key? key}) : super(key: key);

  @override
  State<ChildPermissionsScreen> createState() => _ChildPermissionsScreenState();
}

class _ChildPermissionsScreenState extends State<ChildPermissionsScreen> {
  final Map<Permission, bool> _permissions = {
    Permission.contacts: false,
    Permission.phone: false,
    Permission.sms: false,
    Permission.location: false,
  };

  // For app usage, we'll use a custom permission since it's not directly available
  bool _appUsagePermission = false;

  @override
  Widget build(BuildContext context) {
    final mq = MQ(context);
    
    return Scaffold(
      backgroundColor: AppColors.lightCyan,
      appBar: AppBar(
        backgroundColor: AppColors.lightCyan,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.black),
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 30,
              width: 30,
            ),
            const SizedBox(width: 8),
            const Text(
              'SafeNest',
              style: TextStyle(
                color: AppColors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(mq.w(0.06)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: mq.h(0.02)),
              Text(
                'Allow Access',
                style: TextStyle(
                  fontSize: mq.sp(0.07),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: mq.h(0.02)),
              Text(
                'To enable SafeNest\'s features allow access to your child\'s data for monitoring.',
                style: TextStyle(
                  fontSize: mq.sp(0.04),
                  color: AppColors.textLight,
                ),
              ),
              SizedBox(height: mq.h(0.04)),
              
              // Permissions List
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(mq.w(0.04)),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildPermissionItem(
                        'Contacts',
                        'Access to contact list for emergency calls',
                        Icons.contacts,
                        Permission.contacts,
                      ),
                      const Divider(),
                      _buildPermissionItem(
                        'Phone Calls',
                        'Monitor incoming and outgoing calls',
                        Icons.phone,
                        Permission.phone,
                      ),
                      const Divider(),
                      _buildPermissionItem(
                        'Messages',
                        'Monitor SMS and messaging apps',
                        Icons.message,
                        Permission.sms,
                      ),
                      const Divider(),
                      _buildPermissionItem(
                        'App Usage',
                        'Track which apps are being used',
                        Icons.apps,
                        null, // Custom permission
                        isCustom: true,
                      ),
                      const Divider(),
                      _buildPermissionItem(
                        'Location',
                        'Track device location for safety',
                        Icons.location_on,
                        Permission.location,
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: mq.h(0.04)),
              
              // Continue Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkCyan,
                    padding: EdgeInsets.symmetric(vertical: mq.h(0.018)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: mq.sp(0.04),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionItem(
    String title,
    String description,
    IconData icon,
    Permission? permission, {
    bool isCustom = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.darkCyan, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isCustom 
                ? _appUsagePermission 
                : _permissions[permission!] ?? false,
            onChanged: (value) {
              setState(() {
                if (isCustom) {
                  _appUsagePermission = value;
                } else {
                  _permissions[permission!] = value;
                }
              });
            },
            activeColor: AppColors.darkCyan,
          ),
        ],
      ),
    );
  }

  Future<void> _handleContinue() async {
    // Request permissions that are enabled
    for (final entry in _permissions.entries) {
      if (entry.value) {
        await entry.key.request();
      }
    }

    // Show success message and navigate to child home
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Permissions configured successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate to child home screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ChildHomeScreen()),
    );
  }
}
