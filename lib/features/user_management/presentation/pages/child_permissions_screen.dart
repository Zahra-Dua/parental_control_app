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
  final Map<Permission, bool> _permissionsStatus = {
    Permission.phone: false,
    Permission.sms: false,
    Permission.location: false,
    Permission.notification: false,
  };

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    for (final permission in _permissionsStatus.keys) {
      final status = await permission.status;
      _permissionsStatus[permission] = status.isGranted;
    }
    if (mounted) setState(() {});
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    _permissionsStatus[permission] = status.isGranted;
    if (mounted) setState(() {});
  }

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
                        'Location',
                        'Track device location for safety (enable background for geofencing)',
                        Icons.location_on,
                        Permission.location,
                      ),
                      const Divider(),
                      _buildPermissionItem(
                        'Notifications',
                        'Used to alert on geofence entry/exit',
                        Icons.notifications,
                        Permission.notification,
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

  Widget _buildPermissionItem(String title, String subtitle, IconData icon, Permission permission) {
    final granted = _permissionsStatus[permission] ?? false;
    return Card(
      child: ListTile(
        leading: Icon(icon, color: AppColors.darkCyan),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(
          value: granted,
          onChanged: (_) => _requestPermission(permission),
        ),
      ),
    );
  }

  Future<void> _handleContinue() async {
    // Request permissions that are enabled
    for (final entry in _permissionsStatus.entries) {
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
