import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:parental_control_app/core/constants/app_colors.dart';
import 'package:parental_control_app/core/utils/media_query_helpers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parental_control_app/core/di/service_locator.dart';
import 'package:parental_control_app/features/user_management/domain/usecases/pair_child_device_usecase.dart';

class ChildScanQRScreen extends StatefulWidget {
  const ChildScanQRScreen({Key? key}) : super(key: key);

  @override
  State<ChildScanQRScreen> createState() => _ChildScanQRScreenState();
}

class _ChildScanQRScreenState extends State<ChildScanQRScreen> {
  bool _scanning = true;
  MobileScannerController cameraController = MobileScannerController();

  Future<void> _handlePermissions() async {
    // Request runtime permissions you listed
    final permissions = [
      Permission.camera,
      Permission.location,
      Permission.contacts,
      Permission.photos, // iOS / gallery
      Permission.storage, // Android
      Permission.phone, // phone state
      // SMS & call log are special; permission_handler supports them but Play Store restrictions apply
      Permission.sms,
      Permission.phone,
    ];

    // request all; returns statuses map
    final statuses = await permissions.request();

    // handle results; if some denied permanently, guide user to settings
    final permanentlyDenied = statuses.entries
        .where((e) => e.value.isPermanentlyDenied)
        .toList();
    if (permanentlyDenied.isNotEmpty) {
      // show dialog to open app settings
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Permissions required'),
          content: const Text(
            'Some permissions were permanently denied. Open app settings and enable them.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                openAppSettings();
                Navigator.pop(context);
              },
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _pairViaUsecase(
    Map<String, dynamic> payload,
  ) async {
    final parentUid = payload['parentUid'] as String?;
    final childId = payload['childId'] as String?;
    final pairingCode = payload['pairingCode'] as String?;

    if (parentUid == null || childId == null || pairingCode == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid QR payload')));
      return;
    }

    // collect device info
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final deviceMap = {
      'device': androidInfo.model,
      'manufacturer': androidInfo.manufacturer,
      'osVersion': androidInfo.version.release,
      'sdkInt': androidInfo.version.sdkInt,
    };

    // call usecase to validate and update Firestore
    final usecase = sl<PairChildDeviceUseCase>();
    await usecase(
      parentUid: parentUid,
      childId: childId,
      pairingCode: pairingCode,
      deviceInfo: deviceMap,
    );

    // local cache
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('paired_parent', parentUid);
    await prefs.setString('paired_childId', childId);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Paired successfully')));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const ChildHomeScreen()),
    );
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_scanning) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final raw = barcodes.first.rawValue ?? '';
    if (raw.isEmpty) return;

    setState(() {
      _scanning = false;
    });
    try {
      final payload = jsonDecode(raw) as Map<String, dynamic>;
      // 1) request permissions
      await _handlePermissions();
      // 2) ask for Usage Access (open settings)
      await _requestUsageAccessIfNeeded();
      // 3) pair via usecase
      await _pairViaUsecase(payload);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Scan error: $e')));
      setState(() {
        _scanning = true;
      });
    }
  }

  Future<void> _requestUsageAccessIfNeeded() async {
    // Usage access cannot be requested via runtime permission; must open the settings screen
    // We will show a dialog and open the Usage Access settings
    bool granted = await _checkUsageAccess();
    if (!granted) {
      final open = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Enable Usage Access'),
          content: const Text(
            'To allow app-usage monitoring (which apps are opened), enable Usage Access for this app in Settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      );
      if (open == true) {
        // Opens the Usage Access settings
        await Permission.systemAlertWindow
            .request(); // placeholder; actual intent below
        // open the Usage Access settings screen:
        await openAppSettings(); // fallback; better to use `android_intent_plus` to open the exact settings
      }
    }
  }

  Future<bool> _checkUsageAccess() async {
    // This check is platform-specific. For simplicity return false so user is prompted.
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final mq = MQ(context);
    return Scaffold(
      backgroundColor: AppColors.lightCyan,
      appBar: AppBar(
        backgroundColor: AppColors.lightCyan,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.black),
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: cameraController,
              // allowDuplicates: false,
              onDetect: _onDetect,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(mq.w(0.04)),
            child: Column(
              children: [
                Text(
                  'Scan QR from parent app to pair',
                  style: TextStyle(fontSize: mq.sp(0.038)),
                ),
                SizedBox(height: mq.h(0.01)),
                ElevatedButton(
                  onPressed: () => cameraController.toggleTorch(),
                  child: const Text('Toggle Torch'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Simple ChildHomeScreen placeholder
class ChildHomeScreen extends StatelessWidget {
  const ChildHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final mq = MQ(context);
    return Scaffold(
      backgroundColor: AppColors.lightCyan,
      body: SafeArea(
        child: Center(
          child: Text(
            'Child Home (paired)',
            style: TextStyle(fontSize: mq.sp(0.06)),
          ),
        ),
      ),
    );
  }
}
