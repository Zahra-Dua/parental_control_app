import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:parental_control_app/core/constants/app_colors.dart';
import 'package:parental_control_app/core/utils/media_query_helpers.dart';
import 'package:parental_control_app/core/di/service_locator.dart';
import 'package:parental_control_app/features/user_management/domain/usecases/generate_parent_qr_usecase.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ParentQRScreen extends StatefulWidget {
  const ParentQRScreen({Key? key}) : super(key: key);

  @override
  State<ParentQRScreen> createState() => _ParentQRScreenState();
}

class _ParentQRScreenState extends State<ParentQRScreen> {
  String? _qrData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _generateQRCode();
  }

  Future<void> _generateQRCode() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _error = 'User not authenticated';
          _isLoading = false;
        });
        return;
      }

      final usecase = sl<GenerateParentQRUseCase>();
      final parentUid = await usecase(parentUid: currentUser.uid);

      setState(() {
        _qrData = parentUid; // Use parentUid as QR content
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error generating QR code: $e';
        _isLoading = false;
      });
    }
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
        title: const Text('Your QR Code'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(mq.w(0.06)),
          child: Column(
            children: [
              Text(
                'Share Your QR Code',
                style: TextStyle(
                  fontSize: mq.sp(0.06),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: mq.h(0.02)),
              Text(
                'Let your child scan this QR code to join your family',
                style: TextStyle(fontSize: mq.sp(0.04)),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: mq.h(0.04)),
              
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_error != null)
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      SizedBox(height: mq.h(0.02)),
                      Text(
                        _error!,
                        style: TextStyle(fontSize: mq.sp(0.04)),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: mq.h(0.02)),
                      ElevatedButton(
                        onPressed: _generateQRCode,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              else if (_qrData != null)
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(mq.w(0.04)),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: QrImageView(
                          data: _qrData!,
                          version: QrVersions.auto,
                          size: mq.w(0.6),
                          backgroundColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: mq.h(0.04)),
                      Text(
                        'Parent ID: ${_qrData!.substring(0, 8)}...',
                        style: TextStyle(
                          fontSize: mq.sp(0.035),
                          fontFamily: 'monospace',
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: mq.h(0.04)),
                      Container(
                        padding: EdgeInsets.all(mq.w(0.04)),
                        decoration: BoxDecoration(
                          color: AppColors.darkCyan.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.darkCyan.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.darkCyan,
                              size: 24,
                            ),
                            SizedBox(height: mq.h(0.01)),
                            Text(
                              'Instructions',
                              style: TextStyle(
                                fontSize: mq.sp(0.04),
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkCyan,
                              ),
                            ),
                            SizedBox(height: mq.h(0.01)),
                            Text(
                              '1. Open SafeNest on your child\'s device\n'
                              '2. Select "Child" account type\n'
                              '3. Scan this QR code\n'
                              '4. Enter child\'s name when prompted',
                              style: TextStyle(fontSize: mq.sp(0.035)),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              SizedBox(height: mq.h(0.04)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _generateQRCode,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Add functionality to share QR code
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share functionality coming soon')),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
