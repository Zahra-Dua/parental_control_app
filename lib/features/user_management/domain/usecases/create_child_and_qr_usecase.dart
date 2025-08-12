import 'dart:convert';
import 'package:parental_control_app/features/user_management/domain/repositories/pairing_repository.dart';

class CreateChildAndQrUseCase {
  final PairingRepository repository;
  CreateChildAndQrUseCase(this.repository);

  Future<({String childId, String pairingCode, String qrPayload})> call({
    required String parentUid,
    required String name,
    required int age,
  }) async {
    final result = await repository.createChildAndGenerateCode(
      parentUid: parentUid,
      name: name,
      age: age,
    );
    final childId = result['childId']!;
    final pairingCode = result['pairingCode']!;
    final payload = jsonEncode({
      'parentUid': parentUid,
      'childId': childId,
      'pairingCode': pairingCode,
      'ts': DateTime.now().toIso8601String(),
    });
    return (childId: childId, pairingCode: pairingCode, qrPayload: payload);
    }
}