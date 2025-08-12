import 'package:flutter/material.dart';
import 'package:parental_control_app/core/constants/app_colors.dart';
import 'package:parental_control_app/core/utils/media_query_helpers.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:parental_control_app/core/di/service_locator.dart';
import 'package:parental_control_app/features/user_management/domain/usecases/create_child_and_qr_usecase.dart';

class AddChildScreen extends StatefulWidget {
  final String parentUid;
  const AddChildScreen({Key? key, required this.parentUid}) : super(key: key);

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _nameC = TextEditingController();
  final _ageC = TextEditingController();
  String? _childId;
  String? _pairingCode;
  String? _qrPayload;
  bool _showQR = false;

  Future<void> _createChildAndGenerateQR() async {
    final name = _nameC.text.trim();
    final age = int.tryParse(_ageC.text.trim()) ?? 0;
    if (name.isEmpty) return;

    final usecase = sl<CreateChildAndQrUseCase>();
    final res = await usecase(
      parentUid: widget.parentUid,
      name: name,
      age: age,
    );

    setState(() {
      _childId = res.childId;
      _pairingCode = res.pairingCode;
      _qrPayload = res.qrPayload;
      _showQR = true;
    });
  }


  @override
  void dispose() {
    _nameC.dispose();
    _ageC.dispose();
    super.dispose();
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
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: mq.w(0.06)),
          child: Column(
            children: [
              SizedBox(height: mq.h(0.03)),
              Text(
                'Add Child',
                style: TextStyle(
                  fontSize: mq.sp(0.07),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: mq.h(0.02)),
              TextField(
                controller: _nameC,
                decoration: const InputDecoration(labelText: 'Child name'),
              ),
              SizedBox(height: mq.h(0.015)),
              TextField(
                controller: _ageC,
                decoration: const InputDecoration(labelText: 'Child age'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: mq.h(0.02)),
              ElevatedButton(
                onPressed: _createChildAndGenerateQR,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkCyan,
                  padding: EdgeInsets.symmetric(vertical: mq.h(0.018)),
                ),
                child: const Text('Create and Generate QR'),
              ),
              SizedBox(height: mq.h(0.03)),
              if (_showQR && _childId != null && _pairingCode != null)
                Column(
                  children: [
                    Text(
                      'Show this QR to the child device to scan',
                      style: TextStyle(fontSize: mq.sp(0.035)),
                    ),
                    SizedBox(height: mq.h(0.02)),
                    Container(
                      padding: EdgeInsets.all(mq.w(0.03)),
                      color: AppColors.white,
                                             child: QrImageView(
                         data: _qrPayload ?? '',
                         version: QrVersions.auto,
                         size: mq.w(0.6),
                         gapless: true,
                       ),
                    ),
                    SizedBox(height: mq.h(0.02)),
                    Text(
                      'Pairing code: $_pairingCode',
                      style: TextStyle(
                        fontSize: mq.sp(0.038),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: mq.h(0.01)),
                    ElevatedButton(
                      onPressed: () {
                        // optionally snapshot/share QR
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brightTeal,
                      ),
                      child: const Text('Share QR'),
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
