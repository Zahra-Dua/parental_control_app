import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:parental_control_app/core/constants/app_colors.dart';
import 'package:parental_control_app/core/utils/media_query_helpers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parental_control_app/core/di/service_locator.dart';
import 'package:parental_control_app/features/user_management/domain/usecases/link_child_to_parent_usecase.dart';
import 'package:parental_control_app/features/user_management/domain/usecases/get_parent_children_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:parental_control_app/features/user_management/presentation/pages/child_permissions_screen.dart';

class ChildScanQRScreen extends StatefulWidget {
  const ChildScanQRScreen({Key? key}) : super(key: key);

  @override
  State<ChildScanQRScreen> createState() => _ChildScanQRScreenState();
}

class _ChildScanQRScreenState extends State<ChildScanQRScreen> {
  bool _scanning = true;
  bool _isCheckingLink = true;
  MobileScannerController cameraController = MobileScannerController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGender = 'Male';
  final List<String> _selectedHobbies = [];
  
  final List<String> _availableHobbies = [
    'Reading', 'Sports', 'Music', 'Art', 'Gaming', 
    'Cooking', 'Dancing', 'Swimming', 'Cycling', 'Photography'
  ];

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyLinked();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _checkIfAlreadyLinked() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final usecase = sl<GetParentChildrenUseCase>();
        // Check if this child is already linked by looking for their UID in any parent's childrenIds
        // This is a simplified check - in a real app, you'd want to store the parentId in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final parentUid = prefs.getString('parent_uid');
        
        if (parentUid != null) {
          // Child is already linked, go directly to home screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const ChildHomeScreen()),
          );
          return;
        }
      }
    } catch (e) {
      // If there's an error checking, continue with normal flow
    }
    
    setState(() {
      _isCheckingLink = false;
    });
    _handlePermissions();
  }

  Future<void> _handlePermissions() async {
    final cameraStatus = await Permission.camera.request();
    if (cameraStatus.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Camera Permission Required'),
          content: const Text('Please enable camera permission in app settings to scan QR codes.'),
          actions: [
            TextButton(
              onPressed: () => openAppSettings(),
              child: const Text('Open Settings'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _linkChildToParent(String parentUid) async {
    final childData = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildChildProfileDialog(),
    );

    if (childData == null) {
      setState(() { _scanning = true; });
      return;
    }

    try {
      final usecase = sl<LinkChildToParentUseCase>();
      await usecase(
        parentUid: parentUid,
        childName: childData['name'],
        age: childData['age'],
        gender: childData['gender'],
        hobbies: childData['hobbies'],
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_type', 'child');
      await prefs.setString('child_name', childData['name']);
      await prefs.setString('parent_uid', parentUid);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully linked to parent!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ChildPermissionsScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error linking to parent: $e')),
      );
      setState(() { _scanning = true; });
    }
  }

  Widget _buildChildProfileDialog() {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        return AlertDialog(
          title: const Text('Let\'s setup SafeNest for your Child'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Upload Photo Placeholder
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 40, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                const Text('Upload Photo', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 16),
                
                // Name Field
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Age Field
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Gender Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Male', 'Female', 'Other'].map((gender) {
                    return DropdownMenuItem(
                      value: gender,
                      child: Text(gender),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      _selectedGender = value!;
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // Hobbies Section
                const Text('Hobbies', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _availableHobbies.map((hobby) {
                    final isSelected = _selectedHobbies.contains(hobby);
                    return FilterChip(
                      label: Text(hobby),
                      selected: isSelected,
                      onSelected: (selected) {
                        setDialogState(() {
                          if (selected) {
                            _selectedHobbies.add(hobby);
                          } else {
                            _selectedHobbies.remove(hobby);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.trim().isEmpty ||
                    _ageController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all required fields')),
                  );
                  return;
                }
                
                final age = int.tryParse(_ageController.text.trim());
                if (age == null || age < 1 || age > 18) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid age (1-18)')),
                  );
                  return;
                }
                
                Navigator.pop(context, {
                  'name': _nameController.text.trim(),
                  'age': age,
                  'gender': _selectedGender,
                  'hobbies': List<String>.from(_selectedHobbies),
                });
              },
              child: const Text('Generate QR Code'),
            ),
          ],
        );
      },
    );
  }

  void _onDetect(BarcodeCapture capture) async {
    if (!_scanning) return;
    
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    final raw = barcodes.first.rawValue ?? '';
    if (raw.isEmpty) return;

    setState(() { _scanning = false; });
    
    try {
      final payload = jsonDecode(raw) as Map<String, dynamic>;
      final parentUid = payload['parentId'] as String?;
      
      if (parentUid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid QR code format')),
        );
        setState(() { _scanning = true; });
        return;
      }
      
      await _linkChildToParent(parentUid);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error scanning QR: $e')),
      );
      setState(() { _scanning = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mq = MQ(context);
    
    if (_isCheckingLink) {
      return Scaffold(
        backgroundColor: AppColors.lightCyan,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Parent QR Code'),
        backgroundColor: AppColors.lightCyan,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: cameraController,
              onDetect: _onDetect,
            ),
          ),
          Container(
            padding: EdgeInsets.all(mq.w(0.04)),
            color: AppColors.lightCyan,
            child: Column(
              children: [
                Text(
                  'Scan your parent\'s QR code to join the family',
                  style: TextStyle(
                    fontSize: mq.sp(0.04),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: mq.h(0.02)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => cameraController.toggleTorch(),
                      icon: const Icon(Icons.flash_on),
                      label: const Text('Flash'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkCyan,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => cameraController.switchCamera(),
                      icon: const Icon(Icons.flip_camera_ios),
                      label: const Text('Switch'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkCyan,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChildHomeScreen extends StatelessWidget {
  const ChildHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mq = MQ(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Dashboard'),
        backgroundColor: AppColors.lightCyan,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(mq.w(0.04)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: mq.sp(0.06),
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              SizedBox(height: mq.h(0.02)),
              Text(
                'You are now connected to your parent\'s account.',
                style: TextStyle(
                  fontSize: mq.sp(0.04),
                  color: AppColors.textLight,
                ),
              ),
              SizedBox(height: mq.h(0.04)),
              
              // Feature Cards
              Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule, color: AppColors.darkCyan),
                  title: const Text('Screen Time'),
                  subtitle: const Text('View your daily usage'),
                  onTap: () {
                    // TODO: Implement screen time feature
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on, color: AppColors.darkCyan),
                  title: const Text('Location'),
                  subtitle: const Text('Share location with parent'),
                  onTap: () {
                    // TODO: Implement location feature
                  },
                ),
              ),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.emergency, color: AppColors.darkCyan),
                  title: const Text('SOS'),
                  subtitle: const Text('Emergency contact'),
                  onTap: () {
                    // TODO: Implement SOS feature
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
